require 'buildsystems/meson'

class Dia < Meson
  description 'Dia Diagram Editor is free Open Source drawing software for Windows, Mac OS X and Linux.'
  homepage 'http://dia-installer.de/'
  version '0.97.3-85304ca'
  license 'GPL-2'
  compatibility 'aarch64 armv7l x86_64'
  source_url 'https://gitlab.gnome.org/GNOME/dia.git'
  git_hashtag '85304cac0b3eeba03313733d4a9586411040a0b2'
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: 'fa093818bb8c13c1388c38c0e37835633356c263b247e6abe17c7735a66796b6',
     armv7l: 'fa093818bb8c13c1388c38c0e37835633356c263b247e6abe17c7735a66796b6',
     x86_64: '1ef2a1327268136743c131ed379fda0667c4b23bfceebf7e38e4304e390c05e8'
  })

  depends_on 'cairo' # R
  depends_on 'desktop_file_utils' # L
  depends_on 'gcc_lib' # R
  depends_on 'gdk_pixbuf' # R
  depends_on 'glibc' # R
  depends_on 'glib' # R
  depends_on 'graphene' # R
  depends_on 'gtk3' # R
  depends_on 'harfbuzz' # R
  depends_on 'libart' => :build
  depends_on 'libpng' => :build
  depends_on 'libwmf' => :build
  depends_on 'libxml2' # R
  depends_on 'libxslt' # R
  depends_on 'optipng' => :build
  depends_on 'pango' # R
  depends_on 'poppler' # R
  depends_on 'py3_pygobject' # R
  depends_on 'py3_six' => :build
  depends_on 'python3' # R
  depends_on 'swig1' => :build
  depends_on 'zlib' # R

  gnome

  meson_options '-Ddoc=false'
end
