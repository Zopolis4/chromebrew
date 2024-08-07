require 'buildsystems/autotools'

class Aircrack_ng < Autotools
  description 'Key cracker for the 802.11 WEP and WPA-PSK protocols.'
  homepage 'https://www.aircrack-ng.org'
  version '1.7-b2985bf'
  license 'GPL-2'
  compatibility 'all'
  source_url 'https://github.com/aircrack-ng/aircrack-ng.git'
  git_hashtag 'b2985bf1a3ba6cd5842ceebae806ce4ba4441460'
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
     armv7l: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
       i686: 'iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
     x86_64: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  })

  depends_on 'libnl3'
  depends_on 'libpcap'
  depends_on 'rfkill'

  # https://github.com/aircrack-ng/aircrack-ng/issues/773
  def self.patch
    system "sed -i 's|/etc/aircrack-ng|#{CREW_PREFIX}/aircrack-ng|' scripts/airodump-ng-oui-update"
  end

  # https://github.com/aircrack-ng/aircrack-ng/issues/2623
  pre_configure_options 'CFLAGS=-Wno-error=implicit-function-declaration'
  run_tests
end
