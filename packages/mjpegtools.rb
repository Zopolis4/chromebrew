require 'package'

class Mjpegtools < Package
  description 'Video capture, editing, playback, and compression to MPEG of MJPEG video'
  homepage 'https://mjpeg.sourceforge.io/'
  version '2.2.1'
  license 'GPL-2'
  compatibility 'aarch64 armv7l x86_64'
  source_url 'https://sourceforge.net/projects/mjpeg/files/mjpegtools/2.2.1/mjpegtools-2.2.1.tar.gz'
  source_sha256 'b180536d7d9960b05e0023a197b00dcb100929a49aab71d19d55f4a1b210f49a'
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: '769cff6f2acf252ff998f56f0d5e9c8fc9ed2a3e33f7639c4919675e783ee3ad',
     armv7l: '769cff6f2acf252ff998f56f0d5e9c8fc9ed2a3e33f7639c4919675e783ee3ad',
     x86_64: '967ddfd9c3024f040cdc9044e6f30d66812f5e6e5aa7c8d9982d99b88cc5f579'
  })

  depends_on 'libdv'
  depends_on 'libjpeg_turbo'
  depends_on 'libpng'
  depends_on 'libsdl'
  depends_on 'libsdl2'
  depends_on 'libx11'
  depends_on 'v4l_utils' => :build
  depends_on 'at_spi2_core' # R
  depends_on 'expat' # R
  depends_on 'freetype' # R
  depends_on 'gcc_lib' # R
  depends_on 'gdk_pixbuf' # R
  depends_on 'glib' # R
  depends_on 'glibc' # R
  depends_on 'gstreamer' # R
  depends_on 'gtk2' # R
  depends_on 'harfbuzz' # R
  depends_on 'libbsd' # R
  depends_on 'libmd' # R
  depends_on 'libxau' # R
  depends_on 'libxcb' # R
  depends_on 'libxdmcp' # R
  depends_on 'pango' # R
  depends_on 'zlib' # R

  def self.build
    system '[ -x configure ] || ./autogen.sh'
    system "./configure #{CREW_CONFIGURE_OPTIONS}"
    system 'make'
  end

  def self.install
    system "make DESTDIR=#{CREW_DEST_DIR} install"
  end
end
