require 'buildsystems/cmake'

class Blender < CMake
  description 'Blender is the free and open source 3D creation suite.'
  homepage 'https://www.blender.org'
  version '4.2.1'
  license 'GPLv3+'
  compatibility 'x86_64'
  source_url "https://download.blender.org/source/blender-#{version}.tar.xz"
  source_sha256 'e0b7e070ff706d23666ba90eb99a85badb8dfa80b848dae8d3351bf25d47aff9'
  binary_compression 'tar.zst'

  binary_sha256({
     x86_64: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  })

  depends_on 'audaspace'
  depends_on 'boost' # R
  depends_on 'eigen'
  depends_on 'embree'
  depends_on 'ffmpeg'
  depends_on 'freetype'
  depends_on 'gmp' # R
  depends_on 'jack' # R
  depends_on 'libepoxy'
  depends_on 'libjpeg_turbo'
  depends_on 'libpng'
  depends_on 'libsdl2' # R
  depends_on 'libsndfile' # R
  depends_on 'libtiff'
  depends_on 'libwebp' # R
  depends_on 'libx11' # R
  depends_on 'libxfixes' # R
  depends_on 'libxi' # R
  depends_on 'libxkbcommon' # R
  depends_on 'libxrender' # R
  depends_on 'libxxf86vm' # R
  depends_on 'openal' # R
  depends_on 'openexr' # R
  depends_on 'openimageio'
  depends_on 'openjpeg' # R
  depends_on 'pipewire' # R
  depends_on 'pugixml' # R
  depends_on 'pulseaudio' # R
  depends_on 'py3_numpy'
  depends_on 'py3_requests'
  depends_on 'python3'
  depends_on 'tbb' # R
  depends_on 'zlib'
  depends_on 'zstd'

  # Blender needs the single-precision build of fftw, which we do not provide.
  # WITH_INSTALL_PORTABLE needs to be disabled to get a a FHS-compatible install.
  cmake_options '-DWITH_FFTW3=OFF -DWITH_SYSTEM_AUDASPACE=ON -DWITH_SYSTEM_EIGEN3=ON -DPYTHON_VERSION=3.12 -DWITH_PYTHON_INSTALL=OFF -DWITH_INSTALL_PORTABLE=OFF'
end
