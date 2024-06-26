require 'buildsystems/cmake'

class Evolution_data_server < CMake
  description 'Centralized access to appointments and contacts'
  homepage 'https://wiki.gnome.org/Apps/Evolution'
  version '3.52.0'
  license 'LGPL-2 or LGPL-3, BSD and Sleepycat'
  compatibility 'x86_64 aarch64 armv7l'
  source_url 'https://gitlab.gnome.org/GNOME/evolution-data-server.git'
  git_hashtag version
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: '3f7032d95995a85d6c5873fc77936228ea269cecf33c2ea0f8b3edb64d373589',
     armv7l: '3f7032d95995a85d6c5873fc77936228ea269cecf33c2ea0f8b3edb64d373589',
    x86_64: 'd25bfa3f764b50d9b50de1650f7b31d5e0e119b8098fe5dae5d37ed07fc2694c'
  })

  depends_on 'at_spi2_core' # R
  depends_on 'cairo' # R
  depends_on 'e2fsprogs' # R
  depends_on 'gcc_lib' # R
  depends_on 'gcr_3' # R
  depends_on 'gdk_pixbuf' # R
  depends_on 'glibc' # R
  depends_on 'glib' # R
  depends_on 'gobject_introspection' => :build
  depends_on 'graphene' # R
  depends_on 'gtk3' # R
  depends_on 'gtk4' # R
  depends_on 'gtk_doc' => :build
  depends_on 'harfbuzz' # R
  depends_on 'icu4c' # R
  depends_on 'json_glib' # R
  depends_on 'krb5' # R
  depends_on 'libdb' # R
  depends_on 'libical' # R
  depends_on 'libsecret' # R
  depends_on 'libsoup'
  depends_on 'libsoup2' # R
  depends_on 'libxml2' # R
  depends_on 'nss' # R
  depends_on 'p11kit' # R
  depends_on 'pango' # R
  depends_on 'sqlite' # R
  depends_on 'vala' => :build
  depends_on 'vulkan_headers' => :build
  depends_on 'vulkan_icd_loader' # R
  depends_on 'webkit2gtk_4_1' # R
  depends_on 'webkitgtk_6' # R
  depends_on 'zlibpkg' # R

  gnome

  cmake_options "-DCMAKE_VERBOSE_MAKEFILE=ON \
    -DENABLE_CANBERRA=OFF \
    -DENABLE_EXAMPLES=OFF \
    -DENABLE_GOA=OFF \
    -DENABLE_GOOGLE=OFF \
    -DENABLE_GTK_DOC=OFF \
    -DENABLE_INTROSPECTION=OFF \
    -DENABLE_OAUTH2=OFF \
    -DENABLE_VALA_BINDINGS=OFF \
    -DENABLE_WEATHER=OFF \
    -DWITH_NSPR_INCLUDES=#{CREW_PREFIX}/include/nspr \
    -DWITH_NSS_INCLUDES=#{CREW_PREFIX}/include/nss \
    -DWITH_OPENLDAP=OFF \
    -DWITH_PHONENUMBER=OFF"
end
