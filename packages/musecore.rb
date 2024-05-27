require 'buildsystems/cmake'

class Musecore < CMake
  description 'MuseScore is an open source and free music notation software.'
  homepage 'https://musescore.org'
  version '4.3.0'
  license 'GPL-3'
  compatibility 'x86_64 aarch64 armv7l'
  source_url 'https://github.com/musescore/MuseScore.git'
  git_hashtag "v#{version}"
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
     armv7l: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
     x86_64: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  })

  depends_on 'qt5_base'
  depends_on 'qt5_declarative'
  depends_on 'qt5_networkauth'
  depends_on 'qt5_svg'
  depends_on 'qt5_tools'
  depends_on 'qt5_xmlpatterns'

  run_tests
end
