#!/usr/bin/env ruby
# getrealdeps version 1.5 (for Chromebrew)
# Author: Satadru Pramanik (satmandu) satadru at gmail dot com
require 'fileutils'
require_relative '../commands/whatprovides'
require_relative '../lib/color'
require_relative '../lib/const'
require_relative '../lib/package'
require_relative '../lib/package_utils'


# Add >LOCAL< lib to LOAD_PATH so that packages can be loaded
$LOAD_PATH.unshift File.join(CREW_LIB_PATH, 'lib')

if ARGV.include?('--use-crew-dest-dir')
  ARGV.delete('--use-crew-dest-dir')
  @opt_use_crew_dest_dir = true
end

# Exit quickly if an invalid package name is given.
if ARGV[0].nil? || ARGV[0].empty? || ARGV[0].include?('#')
  puts 'Getrealdeps checks for the runtime dependencies of a package.'
  puts 'The runtime dependencies are added if the package file is missing them.'
  puts 'Usage: getrealdeps.rb [--use_crew_dest_dir] <packagename>'
  exit 1
end

# Search for which packages have a needed library in CREW_LIB_PREFIX.
# This is a subset of what crew whatprovides gives.
def whatprovidesfxn(pkgdepslcl)
  return Command.whatprovides("#{CREW_LIB_PREFIX}/#{pkgdepslcl}", true).to_s.lines.flat_map {|element| element.gsub(/\e\[\d+m/, '').sub(/:.*/, '').chomp! }.uniq
end

def main(pkg)
  puts "Checking for the runtime dependencies of #{pkg}..."

  if @opt_use_crew_dest_dir
    define_singleton_method('pkgfilelist') { File.join(CREW_DEST_DIR, 'filelist') }
    abort('Pkg was not built.') unless File.exist?(pkgfilelist)
  else
    define_singleton_method('pkgfilelist') { "#{CREW_PREFIX}/etc/crew/meta/#{pkg}.filelist" }
    # Package needs to be installed for package filelist to be populated.
    unless File.exist?(pkgfilelist)
      puts "Installing #{pkg} because it is not installed."
      system("yes | crew install #{pkg}")
    end
    abort("Package #{pkg} either does not exist or does not contain any libraries.") unless File.exist?(pkgfilelist)
  end
  # Gawk is needed for adding dependencies.
  unless system('gawk -W version > /dev/null 2>&1')
    puts "\nThe inplace replacement functionality of gawk is used to add missing dependencies to package files."
    system('crew install gawk')
  end

  # upx is needed to expand compressed binaries to check for dependencies.
  unless PackageUtils.installed?('upx')
    puts "upx is not installed.".lightred
    puts "Please run 'crew install upx'".orange
    return
  end

  # What files does the package provide.
  pkgfiles = File.read(pkgfilelist).split("\n").uniq

  # Look at files in CREW_DEST_DIR instead of assuming the package is
  # normally installed, which lets us avoid installing the package if it
  # was just built.
  pkgfiles.map! { |item| item.prepend(CREW_DEST_DIR) } if @opt_use_crew_dest_dir

  FileUtils.rm_rf("/tmp/deps/#{pkg}")
  # Remove files we don't care about, such as man files and non-binaries.
  pkgfiles = pkgfiles.reject { |i| !File.file?(i.chomp) || File.read(i.chomp, 4) != "\x7FELF" || i.include?('.zst') }

  # Use readelf to determine library dependencies, as
  # this doesn't almost run a program like using ldd would.
  pkgdepsfiles = pkgfiles.map do |i|
    system("upx -d #{i} > /dev/null 2>&1")
    FileUtils.mkdir_p("/tmp/deps/#{pkg}/")
    `readelf -d "#{i}" 2>/dev/null | grep NEEDED | awk '{print $5}' | sed 's/\\[//g' | sed 's/\\]//g' | awk '!x[$0]++' | tee /tmp/deps/#{pkg}/#{File.basename(i)}`
  end
  pkgdepsfiles = pkgdepsfiles.map do |filedeps|
    filedeps.split("\n")
  end.flatten.compact.uniq

  # Figure out which Chromebrew packages provide the relevant deps.
  pkgdeps = pkgdepsfiles.flat_map { |file| whatprovidesfxn(file) }.sort
  puts pkgdeps

  # Massage the glibc entries in the dependency list.
  pkgdeps = pkgdeps.map { |i| i.sub(/glibc_build.*/, 'glibc') }.uniq
  pkgdeps = pkgdeps.map { |i| i.sub(/glibc_lib.*/, 'glibc_lib') }.uniq.compact

  # Look for missing runtime dependencies.
  missingpkgdeps = pkgdeps.reject { |i| File.read("#{CREW_PREFIX}/lib/crew/packages/#{pkg}.rb").include?("depends_on '#{i}'") unless File.read("#{CREW_PREFIX}/lib/crew/packages/#{pkg}.rb").include?("depends_on '#{i}' => :build") }

  puts "\nPackage #{pkg} has runtime library dependencies on these packages:"
  pkgdeps.each do |i|
    puts "  depends_on '#{i}' # R"
  end

  if missingpkgdeps.length.positive?
    puts "\nPackage file #{pkg}.rb is missing these runtime library dependencies:"
    missingpkgdeps.each do |i|
      puts "  depends_on '#{i}' # R"
    end
  end

  # Add missing dependencies to the package.
  missingpkgdeps.each do |adddep|
    puts "\n Adding deps: #{adddep}"
    gawk_cmd = if File.foreach("#{CREW_PREFIX}/lib/crew/packages/#{pkg}.rb").grep(/depends_on/).any?
                 # This files contains dependencies already, so add new deps after existing dependencies.
                 "gawk -i inplace -v dep=\"  depends_on '#{adddep}' # R\" 'FNR==NR{ if (/depends_on/) p=NR; next} 1; FNR==p{ print dep }' #{CREW_PREFIX}/lib/crew/packages/#{pkg}.rb #{CREW_PREFIX}/lib/crew/packages/#{pkg}.rb"
               else
                 # This files doesn't contain deps, so just add new deps.
                 "gawk -i inplace -v dep=\"  depends_on '#{adddep}' # R\" 'FNR==NR{ if (/})/) p=NR; next} 1; FNR==p{ print \"\\n\" dep }' #{CREW_PREFIX}/lib/crew/packages/#{pkg}.rb #{CREW_PREFIX}/lib/crew/packages/#{pkg}.rb"
               end
    system(gawk_cmd)
  end
end

ARGV.each do |package|
  main(package.chomp('rb'))
end
