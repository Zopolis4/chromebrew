require 'package'

class Webrtc_audio_processing < Package
  description 'AudioProcessing library based on Googles implementation of WebRTC'
  homepage 'https://freedesktop.org/software/pulseaudio/webrtc-audio-processing/'
  version '0.3.1'
  license 'BSD'
  compatibility 'all'
  source_url 'https://gitlab.freedesktop.org/pulseaudio/webrtc-audio-processing/-/archive/v0.3.1/webrtc-audio-processing-v0.3.1.tar.bz2'
  source_sha256 '70d56051f73e8e4ac95fb392ce15de6c633b2c3ae492359aecc72fc663c9bdda'
  binary_compression 'tar.xz'

  binary_sha256({
    aarch64: 'dd57ac67021298092cd969fc347a277158662a2aeff1dd4f0f21dfa2f8d52f8f',
     armv7l: 'dd57ac67021298092cd969fc347a277158662a2aeff1dd4f0f21dfa2f8d52f8f',
       i686: 'c03f83448134a4c6b9a647a1ac10d14455c3500b8b661d506265ba3ecf1364c0',
     x86_64: 'c18e97b21ba7472d92e2746da7c377e21198da23a01f218ec268241742ee5820'
  })

  depends_on 'abseil_cpp'

  def self.build
    system 'NOCONFIGURE=1 ./autogen.sh'
    system 'filefix'
    system "env CFLAGS='-flto=auto' CXXFLAGS='-flto=auto -std=c++17' \
     LDFLAGS='-flto=auto' \
     ./configure \
     #{CREW_CONFIGURE_OPTIONS}"
    system 'make'
  end

  def self.install
    system "make DESTDIR=#{CREW_DEST_DIR} install"
  end
end
