require 'package'

class Rtaudio < Package
  description 'RtAudio is a set of C++ classes that provide a common API (Application Programming Interface) for realtime audio input/output'
  homepage 'http://www.music.mcgill.ca/~gary/rtaudio/'
  version '5.1.0'
  license 'MIT'
  compatibility 'aarch64 armv7l x86_64'
  source_url 'http://www.music.mcgill.ca/~gary/rtaudio/release/rtaudio-5.1.0.tar.gz'
  source_sha256 'ff138b2b6ed2b700b04b406be718df213052d4c952190280cf4e2fab4b61fe09'
  binary_compression 'tar.xz'

  binary_sha256({
    aarch64: '41cb81dbff61759c229705a92299c6e53329c8958d4d6381ea9d450750896e5d',
     armv7l: '41cb81dbff61759c229705a92299c6e53329c8958d4d6381ea9d450750896e5d',
     x86_64: '78bd93817203d87bfe03d8d203b8f0ac792339b5214b08bc1ccbcc842499793b'
  })

  depends_on 'alsa_lib'
  depends_on 'jack'
  depends_on 'pulseaudio'

  def self.build
    system './configure',
           "--prefix=#{CREW_PREFIX}",
           "--libdir=#{CREW_LIB_PREFIX}",
           '--disable-maintainer-mode',
           '--with-alsa',
           '--with-jack',
           '--with-pulse'
    system 'make'
  end

  # def self.check
  #  system 'make', 'check'
  # end

  def self.install
    system 'make', "DESTDIR=#{CREW_DEST_DIR}", 'install'
  end
end
