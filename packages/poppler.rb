require 'package'

class Poppler < Package
  description 'Poppler is a PDF rendering library based on the xpdf-3.0 code base.'
  homepage 'https://poppler.freedesktop.org/'
  version '23.07.0'
  license 'GPL-2'
  compatibility 'aarch64 armv7l x86_64'
  source_url "https://poppler.freedesktop.org/poppler-#{version}.tar.xz"
  source_sha256 'f29b4b4bf47572611176454c8f21506d71d27eca5011a39aa44038b30b957db0'
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: 'e39e1c03ca0339dfdff0131682fef27fab627bac0c51328be21be8edf7eb3fe2',
     armv7l: 'e39e1c03ca0339dfdff0131682fef27fab627bac0c51328be21be8edf7eb3fe2',
     x86_64: '656fd64a7a0dfee54933e293331f3df1b1b4dec3497bf66820fc06e9483f352d'
  })

  depends_on 'boost' => :build
  depends_on 'cairo' # R
  depends_on 'curl' # R
  depends_on 'fontconfig'
  depends_on 'freetype' # R
  depends_on 'gcc_lib' # R
  depends_on 'glibc' # R
  depends_on 'glib' # R
  depends_on 'harfbuzz' # R
  depends_on 'lcms' # R
  depends_on 'libjpeg_turbo' # R
  depends_on 'libpng' # R
  depends_on 'libtiff' # R
  depends_on 'nss' => :build
  depends_on 'nss' # R
  depends_on 'openjpeg' # R
  depends_on 'poppler_data' => :build
  depends_on 'qt5_base' # R
  depends_on 'zlib' # R

  def self.build
    system "cmake -B builddir #{CREW_CMAKE_OPTIONS} \
        -DENABLE_UNSTABLE_API_ABI_HEADERS=ON \
        -Wno-dev \
        -G Ninja"
    system "#{CREW_NINJA} -C builddir"
  end

  def self.install
    system "DESTDIR=#{CREW_DEST_DIR} #{CREW_NINJA} -C builddir install"
  end
end
