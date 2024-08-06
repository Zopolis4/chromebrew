require 'buildsystems/autotools'

class Attr < Autotools
  description 'Commands for Manipulating Filesystem Extended Attributes.'
  homepage 'https://savannah.nongnu.org/projects/attr'
  version '2.5.2'
  license 'LGPL-2.1'
  compatibility 'all'
  source_url 'https://git.savannah.gnu.org/git/attr.git'
  git_hashtag "v#{version}"
  binary_compression 'tar.xz'

  binary_sha256({
    aarch64: '327ef709fcbdae70f8b48a9bb7de07acc9df0013030b01c28639454b732dbe21',
     armv7l: '327ef709fcbdae70f8b48a9bb7de07acc9df0013030b01c28639454b732dbe21',
       i686: '85bc6ad138cd6dd706917669bc62ad029214cf29a1f18b9ff8509baf2f8aa785',
     x86_64: '22a9f8ca21ff2f3ecde4564e73a29005f45bb8de3c125a263129e907f0d1b246'
  })

  depends_on 'libcap' => :build

  no_zstd
  configure_options '--disable-nls'
end
