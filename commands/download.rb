require_relative '../lib/color'
require_relative '../lib/const'
require_relative '../lib/package'
if CREW_CACHE_ENABLED
  require_relative './download/cache_download'
else
  require_relative './download/download'
end

class Command
  def self.download(name, opt_source, opt_verbose)
    pkg = Package.load_package(File.join(CREW_PACKAGES_PATH, "#{name}.rb"))
    pkg.build_from_source = true if opt_source

    abort "No precompiled binary or source is available for #{ARCH}.".lightred unless url = pkg.get_url(ARCH.to_sym)
    abort "Unable to download fake package.".lightred if pkg.is_fake?

    if opt_source
      puts 'Downloading source...'
    elsif !source = pkg.is_source?(ARCH.to_sym)
      puts 'Precompiled binary available, downloading...'


    url = pkg.get_url(ARCH.to_sym)
    source = pkg.is_source?(ARCH.to_sym)
    filename = File.basename(url)
    sha256sum = pkg.get_sha256(ARCH.to_sym)
    extract_dir = "#{pkg.name}.#{Time.now.utc.strftime('%Y%m%d%H%M%S')}.dir"

    build_cachefile = File.join(CREW_CACHE_DIR, "#{pkg.name}-#{pkg.version}-build-#{ARCH}.tar.zst")
    return { source:, filename: } if CREW_CACHE_BUILD && File.file?(build_cachefile)

    if !url
      abort "No precompiled binary or source is available for #{ARCH}.".lightred
    elsif opt_source
      puts 'Downloading source...'
    elsif !source
      puts 'Precompiled binary available, downloading...'
    elsif url.casecmp?('SKIP')
      puts 'Skipping source download...'
    else
      puts 'No precompiled binary available for your platform, downloading source...'
    end

    Dir.chdir CREW_BREW_DIR do
      case File.basename(filename)
      when /\.zip$/i, /\.(tar(\.(gz|bz2|xz|lzma|lz|zst))?|tgz|tbz|tpxz|txz)$/i, /\.deb$/i, /\.AppImage$/i
        Download::url_download(name, url, sha256sum, filename, opt_verbose)
        Download::cache_downloaded_file(opt_verbose) if File.writable?(CREW_CACHE_DIR)
        return { source:, filename: }
      when /^SKIP$/i
        Dir.mkdir extract_dir
      when /\.git$/i # Source URLs which end with .git are git sources.
        Download::git_download(extract_dir)
        Download::cache_git_dir(extract_dir) if File.writable?(CREW_CACHE_DIR)
      else
        Dir.mkdir extract_dir
        downloader url, sha256sum, filename, opt_verbose

        puts "#{filename}: File downloaded.".lightgreen

        FileUtils.mv filename, "#{extract_dir}/#{filename}"
      end
    end
  end
end
