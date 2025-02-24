require 'buildsystems/cmake'

class Opencolorio < CMake
  description 'A color management framework for visual effects and animation.'
  homepage 'https://github.com/AcademySoftwareFoundation/OpenColorIO'
  version "2.5.0-#{CREW_PY_VER}"
  license 'BSD-3'
  compatibility 'aarch64 armv7l x86_64'
  source_url 'https://github.com/AcademySoftwareFoundation/OpenColorIO.git'
  git_hashtag "v#{version.split('-').first}"
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
     armv7l: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
     x86_64: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  })

  depends_on 'freeglut'
  depends_on 'glew'
  depends_on 'lcms'
  depends_on 'openexr'
  depends_on 'py3_pybind11'
  depends_on 'pystring'
  depends_on 'python3'
  depends_on 'yaml_cpp'

  # The vendored dependencies get confused by our build setup without this and end up installing into wildly incorrect directories.
  cmake_options "-D_EXT_DIST_ROOT=#{CREW_PREFIX}"
end
