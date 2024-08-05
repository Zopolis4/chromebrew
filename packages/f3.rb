require 'package'

class F3 < Package
  description "F3 is a simple tool that tests flash cards' capacity and performance to see if they live up to claimed specifications."
  homepage 'https://oss.digirati.com.br/f3/'
  version '8.0'
  license 'GPL-3+'
  compatibility 'all'
  source_url 'https://github.com/AltraMayor/f3.git'
  git_hashtag "v#{version}"
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
     armv7l: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
       i686: 'iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
     x86_64: '95da24c099336d1badc5102915193cec61efdabb26f6644a40f4c8992ff1f751'
  })

  depends_on 'parted'
  depends_on 'eudev'

  def self.build
    system 'make', "PREFIX=#{CREW_PREFIX}"
    system 'make', "PREFIX=#{CREW_PREFIX}", 'extra'
  end

  def self.install
    system 'make', "PREFIX=#{CREW_PREFIX}", "DESTDIR=#{CREW_DEST_DIR}", 'install'
    system 'make', "PREFIX=#{CREW_PREFIX}", "DESTDIR=#{CREW_DEST_DIR}", 'install-extra'
  end
end
