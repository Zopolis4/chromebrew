require 'buildsystems/autotools'

class Ugrep < Autotools
  description 'A more powerful, ultra fast, user-friendly, compatible grep'
  homepage 'https://ugrep.com/'
  version '7.4.0'
  license 'BSD-3 Clause'
  compatibility 'x86_64'
  source_url 'https://github.com/Genivia/ugrep.git'
  git_hashtag "v#{version}"
  binary_compression 'tar.zst'

  binary_sha256({
     x86_64: '74ab6380ba186b270b8c3fd75f1c421ffd14cec7ef46932cb5c7c263a4349a14'
  })

  depends_on 'brotli'
  depends_on 'bzip2'
  depends_on 'lz4'
  depends_on 'pcre2'
  depends_on 'xzutils'
  depends_on 'zlib'
  depends_on 'zstd'
  depends_on 'gcc_lib' # R
  depends_on 'glibc' # R

  def self.patch
    system 'autoreconf -f'
  end
end
