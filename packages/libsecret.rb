require 'package'

class Libsecret < Package
  description 'GObject based library for accessing the Secret Service API.'
  homepage 'https://github.com/GNOME/libsecret'
  version '0.20.5'
  license 'LGPL-2.1+ and Apache-2.0'
  compatibility 'all'
  source_url 'https://github.com/GNOME/libsecret/archive/0.20.5.tar.gz'
  source_sha256 'b33b9542222ea8866f6ff2d31c0ad373877c2277db546ca00cc7fdda9cbab1c3'
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: '0d9ac5b80df9e1fa0c09c790e1f50b715304ee88e0af7e9fe1f990f9e6d0457e',
     armv7l: '0d9ac5b80df9e1fa0c09c790e1f50b715304ee88e0af7e9fe1f990f9e6d0457e',
       i686: 'b95c5aafd5357157bf8cba2665ff5dda57df63846b695d717d984952645beb36',
     x86_64: '4b4595d60fae4c5b5b8c23c1976c9cbafe1f8a43341486c682854ddad9253440'
  })

  depends_on 'gobject_introspection' => :build
  depends_on 'libgcrypt' => :build
  depends_on 'vala' => :build
  depends_on 'glib' # R
  depends_on 'glibc' # R

  def self.build
    system "meson setup #{CREW_MESON_OPTIONS} \
      -Dgtk_doc=false \
      -Dmanpage=false \
      build"
    system 'meson configure build'
    system 'samu -C build'
  end

  def self.install
    system "DESTDIR=#{CREW_DEST_DIR} samu -C build install"
  end
end
