require_relative '../lib/const'
require_relative '../lib/color'
require_relative '../lib/package'
require_relative '../lib/package_utils'

class Command
  def self.whatprovides(regex, only_print_compatible = false)
    matched_list = `grep -ER "#{regex}" #{CREW_LIB_PATH}/manifest/#{ARCH}`.lines(chomp: true).flat_map do |result|
      # Split the grep results into two variables for the filelist and the matched file.
      filelist, matched_file = result.split(':', 2)
      # Take the package name from the returned filelist.
      pkg_name = File.basename(filelist, '.filelist')
      compatible = PackageUtils.compatible?(Package.load_package(File.join(CREW_PACKAGES_PATH, "#{pkg_name}.rb")))
      # If we aren't looking for compatible packages, then skip this package.
      next if only_print_compatible && !compatible
      # If the package is incompatible, mark it as red.
      pkg_name = pkg_name.lightred unless compatible
      # If the package is installed, mark it as green.
      pkg_name = pkg_name.lightgreen if PackageUtils.installed?(pkg_name)
      # Tie it all together and add the completed string to the array.
      "#{pkg_name}: #{matched_file}"
    end.compact

    return unless matched_list.any?
    return "#{matched_list}" + "\nTotal found: #{matched_list.length}".lightgreen
  end
end
