require 'json'
require 'net/http'
require 'ruby_libversion'

# Add >LOCAL< lib to LOAD_PATH
$LOAD_PATH.unshift '../lib'

require_relative '../lib/package'

def get_version(name, homepage)
  anitya_id = get_anitya_id(name, homepage)
  # If we weren't able to get an Anitya ID, return early here to save time and headaches
  return if anitya_id.nil?
  # Get the latest version of the package
  json = JSON.parse(Net::HTTP.get(URI("https://release-monitoring.org/api/v2/versions/?project_id=#{anitya_id}")))
  return json['latest_version']
end

def get_anitya_id(name, homepage)
  # Find out how many packages Anitya has with the provided name.
  json = JSON.parse(Net::HTTP.get(URI("https://release-monitoring.org/api/v2/projects/?name=#{name}")))
  number_of_packages = json['total_items']

  if number_of_packages == 1 # We assume we have the right package, take the ID and move on.
    return json['items'][0]['id']
  elsif number_of_packages == 0 # Anitya either doesn't have this package, or has it under a different name.
    # If it has it under a different name, check if it has the name used by Chromebrew.
    json2 = JSON.parse(Net::HTTP.get(URI("https://release-monitoring.org/api/v2/packages/?name=#{name}")))
    return if json2['total_items'] == 0

    for i in 0..json2['total_items']-1 do
      if json2['items'][i]['distribution'] == 'Chromebrew'
        if json2['items'][i]['name'] == name
          return get_anitya_id(json2['items'][i]['project'], homepage)
        end
      end
    end
  else # Anitya has more than one package with this exact name.
    candidates = []
    # First, we remove any candidates which are provided by language package managers, such as pip.
    # This is because Chromebrew does not repackage them (#7713), so they won't be what we're looking for.
    for i in 0..number_of_packages-1 do
      # If a package is not provided by a language package manager, the ecosystem will be set to the homepage.
      # https://release-monitoring.org/static/docs/api.html#get--api-v2-projects-
      if json['items'][i]['ecosystem'] == json['items'][i]['homepage']
        candidates.append(i)
      end
    end

    if candidates.length == 1 # If there's only one candidate left, we're done.
      return json['items'][candidates[0]]['id']
    elsif candidates.length == 0 # The package we're looking for is provided by a language package manager.
      # We probably shouldn't be providing this package.
      return
    else # There are still multiple candidates left.
      # This is where things get a little uncertain.
      # We check if the homepage Anitya has matches ours, but this really only works for Github projects.
      # For other projects, there's a lot more opinion involved in choosing the exact homepage.
      # Nevertheless, its our best shot at this point.
      candidates.each do |candidate|
        # We assume there is only one candidate with the same name and homepage as their crew counterpart.
        # Even if there are multiple candidates with the same name and homepage, its probably fine to treat them as identical.
        # If it isn't fine to treat them as identical, something has gone horribly wrong.
        if homepage == json['items'][candidate]['homepage']
          return json['items'][candidate]['id']
        end
      end

      # If we're still here, that means none of the candidates had the same homepage as their crew counterpart.
      # Not much we can do at this point to find the version, and its better to be cautious to avoid getting the wrong candidate.
      return
    end
  end
end

# There are a number of packages which we should ignore here for various reasons.
ignored_packages = [
  # Packages that provide a specific version of another package (i.e. gtk3)
  'atkmm16',
  'autoconf213',
  'cairomm_1_0',
  'cairomm_1_16',
  'docbook_xml412',
  'docbook_xml42',
  'docbook_xml43',
  'docbook_xml44',
  'docbook_xml45',
  'docbook_xml50',
  'docbook_xml51',
  'docbook_xsl_nons',
  'glibc_build223',
  'glibc_build227',
  'glibc_build232',
  'glibc_build233',
  'glibc_build235',
  'glibc_dev235',
  'glibc_lib235',
  'glibmm_2_4',
  'glibmm_2_68',
  'gtk2',
  'gtk3',
  'gtkmm2',
  'gtkmm3',
  'gtkmm4',
  'gtksourceview_3',
  'gtksourceview_4',
  'gtksourceview_5',
  'imagemagick6',
  'imagemagick7',
  'jdk11',
  'jdk17',
  'jdk18',
  'jdk8',
  'js102',
  'js78',
  'js91',
  'libsigcplusplus',
  'libsigcplusplus3',

  # Packages that are composed entirely of code embedded in the package file (i.e. clear_cache)
  'broadway',
  'clear_cache',
]

Dir.glob('../packages/*.rb').each do |filename|
  pkg = Package.load_package(filename)
  # Skip any of the packages in the ignored_packages list
  next if ignored_packages.any?(pkg.name)
  # Instead of typing out the name of every python package, we just use a regex here
  next if pkg.name.match?(/py3\S+/)
  # Skip fake packages
  next if pkg.is_fake?

  upstream_version = get_version(pkg.name.tr('_','-'), pkg.homepage)
  # Some packages don't work with this yet, so gracefully exit now rather than throwing false positives
  next if upstream_version.nil?

  if Libversion.version_compare2(pkg.version, upstream_version) < 0
    puts "#{pkg.name} is outdated."
    puts "Current version: #{pkg.version}"
    puts "Upstream version: #{upstream_version}"
  end
end
