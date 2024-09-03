require 'buildsystems/autotools'

class Parted < Autotools
  description 'Create, destroy, resize, check, copy partitions and file systems.'
  homepage 'https://www.gnu.org/software/parted/'
  version '3.6'
  license 'GPL-3'
  compatibility 'all'
  source_url "https://ftpmirror.gnu.org/parted/parted-#{version}.tar.xz"
  source_sha256 '3b43dbe33cca0f9a18601ebab56b7852b128ec1a3df3a9b30ccde5e73359e612'
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: '6be8029209205c8c41fc8e3169443c5b391c84143e52bb11c1e5b154ab891f65',
     armv7l: '6be8029209205c8c41fc8e3169443c5b391c84143e52bb11c1e5b154ab891f65',
       i686: 'c3f780c191b7b636306f18ee2919410c42816da3a87b80e154578ec98d2e06df',
     x86_64: 'b060ff1f8d8d4a6faffa794895d0018b1a70a0a98af663811cf99fc5f925be40'
  })

  depends_on 'glibc_lib' # R
  depends_on 'glibc' # R
  depends_on 'lvm2' # R
  depends_on 'ncurses' # R
  depends_on 'readline' # R
  depends_on 'util_linux' # R
end
