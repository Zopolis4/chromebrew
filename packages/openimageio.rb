require 'buildsystems/cmake'

class Openimageio < CMake
  description 'OpenImageIO is a toolset for reading, writing, and manipulating image files of any image file format relevant to VFX / animation via a format-agnostic API with a feature set, scalability, and robustness needed for feature film production.'
  homepage 'https://github.com/AcademySoftwareFoundation/OpenImageIO'
  version '2.5.15.0'
  license 'Apache-2.0'
  compatibility 'x86_64 aarch64 armv7l'
  source_url 'https://github.com/AcademySoftwareFoundation/OpenImageIO.git'
  git_hashtag "v#{version.split('-').first}"
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: 'e844c3135cefcb3c202b0771b156bf55ead373095eeede042d8fa229c9c4bc63',
     armv7l: 'e844c3135cefcb3c202b0771b156bf55ead373095eeede042d8fa229c9c4bc63',
     x86_64: 'ee3e836bd3f707b04fbb484cd57c07c17a952c661011de67cf69c5d043852320'
  })

  depends_on 'boost'
  depends_on 'bzip2' # R
  depends_on 'freetype' # R
  depends_on 'giflib' # R
  depends_on 'libfmt'
  depends_on 'libjpeg_turbo'
  depends_on 'libpng'
  depends_on 'libtiff'
  depends_on 'libwebp' # R
  depends_on 'openexr'
  depends_on 'pugixml'
  depends_on 'py3_pybind11'
  depends_on 'zlib' # R

  # The setup for finding pybind11 is custom, so it's hard to tell where exactly it breaks to fix it properly.
  cmake_options "-Dpybind11_ROOT=#{CREW_PREFIX}/lib/python3.12/site-packages/pybind11 -DOIIO_BUILD_TESTS=OFF"
end
