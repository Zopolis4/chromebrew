require 'buildsystems/meson'

class Geary < Meson
  description 'Geary is an email application built around conversations for the GNOME desktop.'
  homepage 'https://wiki.gnome.org/Apps/Geary'
  version '46.0'
  license 'GPL2+'
  compatibility 'x86_64 aarch64 armv7l'
  source_url 'https://gitlab.gnome.org/GNOME/geary.git'
  git_hashtag version
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: '2222222222222222222622222222222222222222222222222222222222222222',
     armv7l: '2222222222222222222622222222222222222222222222222222222222222222',
     x86_64: '8888888888888888888588888888888888888888888888888888888888888888'
  })

  depends_on 'appstream_glib'
  depends_on 'desktop_file_utils' => :build
  depends_on 'folks'
  depends_on 'freetype'
  depends_on 'gcr_3'
  depends_on 'gnome_online_accounts'
  depends_on 'gmime'
  depends_on 'gsound'
  depends_on 'gspell'
  depends_on 'gtk3'
  depends_on 'iso_codes'
  depends_on 'itstool' => :build
  depends_on 'libhandy'
  depends_on 'libpeas'
  depends_on 'sqlite'
  depends_on 'vala' => :build
  depends_on 'webkit2gtk_4_1'
  depends_on 'ytnef'

  gnome
end
