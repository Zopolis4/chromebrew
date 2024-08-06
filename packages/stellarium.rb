require 'buildsystems/cmake'

class Stellarium < CMake
  description 'Stellarium is a free open source planetarium for your computer.'
  homepage 'https://stellarium.org/'
  version '24.2'
  license 'GPL-2.0'
  compatibility 'aarch64 armv7l x86_64'
  source_url 'https://github.com/Stellarium/stellarium.git'
  git_hashtag "v#{version}"
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
     armv7l: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
     x86_64: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  })

  depends_on 'qt5_charts'
  depends_on 'qt5_location'
  depends_on 'qt5_multimedia'
  depends_on 'qt5_script'
  depends_on 'qt5_serialport'
  depends_on 'qt5_tools'
  depends_on 'qt5_wayland'

  def self.remove
    config_dir = "#{HOME}/.stellarium"
    if Dir.exist? config_dir
      print "Would you like to remove the config directory #{config_dir}? [y/N] "
      case $stdin.gets.chomp.downcase
      when 'y', 'yes'
        FileUtils.rm_rf config_dir
        puts "#{config_dir} removed.".lightred
      else
        puts "#{config_dir} saved.".lightgreen
      end
    end
  end

  cmake_options '-DENABLE_GPS=0'
end
