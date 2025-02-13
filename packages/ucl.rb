# Adapted from Arch Linux ucl PKGBUILD at:
# https://github.com/archlinux/svntogit-community/raw/packages/ucl/trunk/PKGBUILD

require 'package'

class Ucl < Package
  description 'Portable lossless data compression library written in ANSI C'
  homepage 'https://www.oberhumer.com/opensource/ucl/'
  version '1.03'
  license 'GPL-2+'
  compatibility 'all'
  source_url 'https://www.oberhumer.com/opensource/ucl/download/ucl-1.03.tar.gz'
  source_sha256 'b865299ffd45d73412293369c9754b07637680e5c826915f097577cd27350348'
  binary_compression 'tpxz'

  binary_sha256({
    aarch64: 'da7156b3f5c3def28ef1e276d4e24c9ba0bcb5f623c1856d0c4f886233d16676',
     armv7l: 'da7156b3f5c3def28ef1e276d4e24c9ba0bcb5f623c1856d0c4f886233d16676',
       i686: 'c69ddc889d2fbecf1b77b646fe0623565da9d11f7a6c71762fbebc5c77b27882',
     x86_64: '1d0c3cfc926a6e8c119794d253680044bc10d54a18438199409287d42f6f979f'
  })

  def self.build
    system "env CFLAGS='-pipe -std=gnu90 -fPIC -flto=auto' \
      ./configure #{CREW_CONFIGURE_OPTIONS} \
      --enable-shared \
      --enable-static"
    system 'make'
  end

  def self.install
    system "make DESTDIR=#{CREW_DEST_DIR} install"
  end
end
