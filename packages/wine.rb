require 'buildsystems/autotools'

class Wine < Autotools
  description 'Wine (originally an acronym for "Wine Is Not an Emulator") is a compatibility layer capable of running Microsoft Windows applications.'
  homepage 'https://www.winehq.org'
  version '9.13'
  license 'LGPL-2.1'
  compatibility 'x86_64'
  source_url 'https://gitlab.winehq.org/wine/wine.git'
  git_hashtag "wine-#{version}"
  binary_compression 'tar.zst'

  binary_sha256({
     x86_64: 'd772c75f222397fa78e5d037545cbe4c10395db3fb93860a5a07f15b06947fae'
  })

  depends_on 'alsa_lib' # R
  depends_on 'desktop_file_utils' => :build
  depends_on 'eudev' # R
  depends_on 'fontconfig' => :build
  depends_on 'giflib' => :build
  depends_on 'glib' # R
  depends_on 'gstreamer' # R
  depends_on 'lcms' => :build
  depends_on 'libfaudio' => :build
  depends_on 'libglu' => :build
  depends_on 'libgphoto' # R
  depends_on 'libjpeg_turbo' => :build
  depends_on 'libpcap' # R
  depends_on 'libpng' => :build
  depends_on 'libsm' => :build
  depends_on 'libunwind' # R
  depends_on 'libusb' # R
  depends_on 'libx11' # R
  depends_on 'libxcursor' => :build
  depends_on 'libxdamage' => :build
  depends_on 'libxext' # R
  depends_on 'libxi' => :build
  depends_on 'libxkbcommon' # R
  depends_on 'libxrandr' => :build
  depends_on 'llvm18_dev' => :build
  depends_on 'mesa' => :build
  depends_on 'mpg123' => :build
  depends_on 'openal' => :build
  depends_on 'opencl_headers' => :build
  depends_on 'opencl_icd_loader' # R
  depends_on 'openldap' => :build
  depends_on 'pulseaudio' # R
  depends_on 'sommelier' # L
  depends_on 'unixodbc' # R
  depends_on 'vkd3d' => :build
  depends_on 'wayland' # R
  depends_on 'xdg_base' => :build
  depends_on 'glibc' # R

  # Wine does not build with LTO: https://bugs.winehq.org/show_bug.cgi?id=41712
  no_lto

  # Enough of the tests fail and are marked as FIXME to the point that there's no point running them when packaging.
  configure_options '--enable-archs=i386,x86_64 --disable-tests'

  def self.postinstall
    ExitMessage.add 'To run an application with wine, type `wine path/to/myexecutable.exe` or `wine path/to/myinstaller.msi`.'.lightblue
  end

  def self.remove
    config_dir = "#{HOME}/.wine"
    if Dir.exist? config_dir
      print "Would you like to remove the #{config_dir} directory? [y/N] "
      case $stdin.gets.chomp.downcase
      when 'y', 'yes'
        FileUtils.rm_rf config_dir
        puts "#{config_dir} removed.".lightgreen
      else
        puts "#{config_dir} saved.".lightgreen
      end
    end
  end
end
