require 'package'

class Wxwidgets30 < Package
  description 'wxWidgets is a C++ library that lets developers create applications for Windows, macOS, Linux and other platforms with a single code base.'
  homepage 'https://www.wxwidgets.org/'
  @_ver = '3.0.5.1'
  version "#{@_ver}-2"
  license 'GPL-2'
  compatibility 'aarch64 armv7l x86_64'
  source_url 'https://github.com/wxWidgets/wxWidgets.git'
  git_hashtag "v#{@_ver}"
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: '4874ecb6f55a1285a88487428979b84985f938b740f534c75261f71f354d4fd0',
     armv7l: '4874ecb6f55a1285a88487428979b84985f938b740f534c75261f71f354d4fd0',
     x86_64: '220a47f3a3bb2b1df0005fd45a45a39e3c0f16b6e28ad3008b7807633a6d9dfa'
  })

  depends_on 'at_spi2_core' # R
  depends_on 'expat' # R
  depends_on 'fontconfig' => :build
  depends_on 'gcc_lib' # R
  depends_on 'gdk_pixbuf' # R
  depends_on 'glibc' # R
  depends_on 'glib' # R
  depends_on 'gstreamer' # R
  depends_on 'gtk3' # R
  depends_on 'harfbuzz' # R
  depends_on 'libglu' # R
  depends_on 'libglvnd' # R
  depends_on 'libjpeg_turbo' # R
  depends_on 'libnotify' # R
  depends_on 'libsdl' => :build
  depends_on 'libsecret' => :build
  depends_on 'libsm' # R
  depends_on 'libsoup2' # R
  depends_on 'libtiff' # R
  depends_on 'libx11' # R
  depends_on 'libxxf86vm' # R
  depends_on 'mesa' # R
  depends_on 'pango' # R
  depends_on 'webkit2gtk_4' # R
  depends_on 'zlib' # R

  def self.preflight
    %w[wxwidgets wxwidgets31].each do |wxw|
      next unless File.exist? "#{CREW_PREFIX}/etc/crew/meta/#{wxw}.filelist"

      puts "#{wxw} installed and conflicts with this version.".orange
      puts 'To install this version, execute the following:'.lightblue
      abort "crew remove #{wxw} && crew install wxwidgets30".lightblue
    end
  end

  def self.build
    system "./configure #{CREW_CONFIGURE_OPTIONS} \
      --with-gtk=3 \
      --with-opengl \
      --enable-unicode \
      --enable-graphics_ctx \
      --enable-mediactrl \
      --enable-webview \
      --with-regex=builtin \
      --with-libpng=builtin \
      --with-libjpeg=sys \
      --with-libtiff=sys \
      --without-gnomevfs \
      --disable-universal \
      --disable-precomp-headers"
    system 'make'
  end

  def self.install
    system 'make', "DESTDIR=#{CREW_DEST_DIR}", 'install'
    Dir.chdir "#{CREW_DEST_PREFIX}/bin" do
      FileUtils.ln_sf "#{CREW_LIB_PREFIX}/wx/config/gtk3-unicode-3.0", 'wx-config'
    end
  end
end
