require 'package'

class Xsetroot < Package
  description 'Root window parameter setting utility for X'
  homepage 'https://www.x.org/archive/X11R7.5/doc/man/man1/xsetroot.1.html'
  version '1.1.2'
  license 'MIT-with-advertising'
  compatibility 'aarch64 armv7l x86_64'
  source_url 'https://www.x.org/releases/individual/app/xsetroot-1.1.2.tar.bz2'
  source_sha256 '10c442ba23591fb5470cea477a0aa5f679371f4f879c8387a1d9d05637ae417c'
  binary_compression 'tar.xz'

  binary_sha256({
    aarch64: '370530cc44d12e66cf83faa17fbac1aec5e44abddcf09802d3ec83cd6863832c',
     armv7l: '370530cc44d12e66cf83faa17fbac1aec5e44abddcf09802d3ec83cd6863832c',
     x86_64: 'ebd15859bebe9ecfcf8bc954c1ae5072ff8d184b96398991478a70b3d38cd1e7'
  })

  depends_on 'xbitmaps'
  depends_on 'libxcursor'
  depends_on 'libxmu'

  def self.build
    system './configure', "--prefix=#{CREW_PREFIX}", "--libdir=#{CREW_LIB_PREFIX}"
    system 'make'
  end

  def self.install
    system 'make', "DESTDIR=#{CREW_DEST_DIR}", 'install'
  end
end
