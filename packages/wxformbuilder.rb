require 'package'

class Wxformbuilder < Package
  description 'RAD tool for wxWidgets GUI design'
  homepage 'https://github.com/wxFormBuilder/wxFormBuilder'
  version '3.9.0'
  license 'GPL-3'
  compatibility 'aarch64 armv7l x86_64'
  source_url 'https://github.com/wxFormBuilder/wxFormBuilder/archive/v3.9.0.tar.gz'
  source_sha256 'e63532e71828d5e168388380fe627225f997267495da4bf6c55ef592738bdc88'
  binary_compression 'tar.xz'

  binary_sha256({
    aarch64: '72919b2bd017609c541cdd137375e4f5b77ebbc575b64bf4c36f800ff9063acb',
     armv7l: '72919b2bd017609c541cdd137375e4f5b77ebbc575b64bf4c36f800ff9063acb',
     x86_64: 'f812d32fda14a1a379be8d8c98c291da84f0353bd7cefc6f07bad3f8ad89b4ad'
  })

  depends_on 'wxwidgets'
  depends_on 'sommelier'

  def self.build
    system 'git clone --recursive --depth=1 https://github.com/wxFormBuilder/wxFormBuilder'
    Dir.chdir 'wxFormBuilder' do
      system "meson _build --prefix #{CREW_PREFIX} --libdir #{CREW_LIB_PREFIX}"
    end
  end

  def self.install
    Dir.chdir 'wxFormBuilder' do
      system "DESTDIR=#{CREW_DEST_DIR} ninja -C _build install"
      if ARCH == 'x86_64'
        FileUtils.mkdir_p "#{CREW_DEST_PREFIX}/lib"
        FileUtils.ln_s "#{CREW_LIB_PREFIX}/wxformbuilder", "#{CREW_DEST_PREFIX}/lib/wxformbuilder"
      end
    end
  end
end
