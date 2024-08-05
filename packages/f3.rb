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
     x86_64: '4e5f76a2ff5157c5191bfe79673d0d4f842d901daac68cf2b4249535236249fe'
  })

  depends_on 'parted'
  depends_on 'eudev'
  depends_on 'glibc' # R

  def self.build
    system 'make', "PREFIX=#{CREW_PREFIX}"
    system 'make', "PREFIX=#{CREW_PREFIX}", 'extra'
  end

  def self.install
    system 'make', "PREFIX=#{CREW_PREFIX}", "DESTDIR=#{CREW_DEST_DIR}", 'install'
    system 'make', "PREFIX=#{CREW_PREFIX}", "DESTDIR=#{CREW_DEST_DIR}", 'install-extra'
  end
end
