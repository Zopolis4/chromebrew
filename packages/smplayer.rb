require 'package'

class Smplayer < Package
  description 'SMPlayer is a free media player for Windows and Linux with built-in codecs that can play virtually all video and audio formats.'
  homepage 'https://www.smplayer.info/'
  version '24.5.0.10283'
  license 'GPL-2'
  compatibility 'aarch64 armv7l x86_64'
  source_url 'https://github.com/smplayer-dev/smplayer.git'
  git_hashtag "v#{version}"
  binary_compression 'tar.zst'

  depends_on 'gdk_base'
  depends_on 'gtk3'
  depends_on 'jack'
  depends_on 'libthai'
  depends_on 'sommelier'

  def self.build
    system 'make', "PREFIX=#{CREW_PREFIX}"
  end

  def self.install
    system 'make', "PREFIX=#{CREW_PREFIX}", "DESTDIR=#{CREW_DEST_DIR}", 'install'
  end

  def self.postinstall
    ExitMessage.add <<~EOM

      Type 'smplayer' to get started.

      If you have trouble playing videos, try the steps below:
      Select Options > Preferences
      Click the 'Audio' tab
      Uncheck 'Use software volume control'
      Click OK
    EOM
  end

  def self.postremove
    config_dir = "#{CREW_PREFIX}/.config/smplayer"
    if Dir.exist? config_dir
      print "Would you like to remove the #{config_dir} directory? [y/N] "
      case $stdin.gets.chomp.downcase
      when 'y', 'yes'
        FileUtils.rm_rf config_dir
        puts "#{config_dir} removed.".lightgreen
      else
        puts "#{config_dir} saved.".lightgreen
      end
    end
  end
end
