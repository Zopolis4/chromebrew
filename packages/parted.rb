require 'buildsystems/autotools'

class Parted < Autotools
  description 'Create, destroy, resize, check, copy partitions and file systems.'
  homepage 'https://www.gnu.org/software/parted/'
  version '3.6'
  license 'GPL-3'
  compatibility 'all'
  source_url 'https://ftpmirror.gnu.org/parted/parted-3.6.tar.xz'
  source_sha256 '3b43dbe33cca0f9a18601ebab56b7852b128ec1a3df3a9b30ccde5e73359e612'
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: '2f0b6d37c1367564f63377968d99a9a9f4c8ab28d90d2e253c275b68013d8b63',
     armv7l: '2f0b6d37c1367564f63377968d99a9a9f4c8ab28d90d2e253c275b68013d8b63',
       i686: '9abdc8ef9de5ae67589218be10062e3012c784f305c189f0d984cf8880c430f9',
     x86_64: '01d8bdaf0944aa74d362c4fd00de3fbf2f0c006e74093afe391e4f99bdbb29ea'
  })

  depends_on 'lvm2'
  depends_on 'ncurses'
  depends_on 'readline'
end
