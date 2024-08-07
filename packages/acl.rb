require 'buildsystems/autotools'

class Acl < Autotools
  description 'Commands for Manipulating POSIX Access Control Lists.'
  homepage 'https://savannah.nongnu.org/projects/acl'
  version '2.3.2'
  license 'LGPL-2.1'
  compatibility 'all'
  source_url 'https://git.savannah.gnu.org/git/acl.git'
  git_hashtag "v#{version}"
  binary_compression 'tar.xz'

  binary_sha256({
    aarch64: 'a26e093dde82f22a16bdb773112224adca55ddf34b9dab0a30d8a3d516af0c5a',
     armv7l: 'a26e093dde82f22a16bdb773112224adca55ddf34b9dab0a30d8a3d516af0c5a',
       i686: '99aa7799ddb6386516c51289029a28ad8e121834fd969683503645adfd871ecc',
     x86_64: '9927be45944b3ce77db2169892349c3d894be10550edf3be0bd68f1dc17bdfff'
  })

  depends_on 'attr'

  no_zstd
  configure_options '--disable-nls'
end
