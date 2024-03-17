require 'digest/sha2'
require 'fileutils'
require_relative '../lib/color'
require_relative '../lib/const'
require_relative '../lib/downloader'
require_relative '../lib/package'

class Command
  def self.download(pkg, verbose)
    abort "No precompiled binary or source is available for #{ARCH}.".lightred unless url = pkg.get_url(ARCH.to_sym)
    abort "Unable to download fake package.".lightred if pkg.is_fake?

    filename = File.basename(url)
    sha256sum = pkg.get_sha256(ARCH.to_sym)
    extract_dir = "#{pkg.name}.#{Time.now.utc.strftime('%Y%m%d%H%M%S')}.dir"
    build_cachefile = File.join(CREW_CACHE_DIR, "#{pkg.name}-#{pkg.version}-build-#{ARCH}.tar.zst")

    return build_cachefile, extract_dir if CREW_CACHE_BUILD && File.file?(build_cachefile)

    if pkg.build_from_source
      puts 'Downloading source...'
    elsif pkg.binary?(ARCH.to_sym)
      puts 'Precompiled binary available, downloading...'
    elsif url == 'SKIP'
      puts 'Skipping source download...'
    else
      puts 'No precompiled binary available for your platform, downloading source...'
    end

    Dir.chdir CREW_BREW_DIR do
      Dir.mkdir extract_dir
      case filename
      when /\.zip$/i, /\.(tar(\.(gz|bz2|xz|lzma|lz|zst))?|tgz|tbz|tpxz|txz)$/i, /\.deb$/i, /\.AppImage$/i
        # If told to, try and find the downloaded file in the cache and copy it to CREW_BREW_DIR.
        filename = find_cached_url_download(pkg.name, filename, sha256sum, verbose) if CREW_CACHE_ENABLED
        # Download the file if we weren't told to/weren't able to find it in the cache.
        url_download(pkg.name, url, sha256sum, verbose)
        # Cache the downloaded file if told to.
        cache_downloaded_file(filename, verbose) if CREW_CACHE_ENABLED
      when /\.git$/i
        # If told to, try and find the cached git directory and extract it to CREW_BREW_DIR/extract_dir.
        find_cached_git_download(pkg, extract_dir, verbose) if CREW_CACHE_ENABLED
        # Download the git repository if we weren't told to/weren't able to find it in the cache.
        git_download(pkg, extract_dir)
        # Cache the git directory if told to.
        cache_git_dir(pkg, extract_dir, verbose) if File.writable?(CREW_CACHE_DIR)
      else
        # If the file can't be extracted and isn't a git directory, just download it.
        downloader url, sha256sum, verbose
        puts "#{filename}: File downloaded.".lightgreen
        # Move the file into extract_dir.
        FileUtils.mv filename, "#{extract_dir}/#{filename}"
      end
      return filename, extract_dir
    end
  end
end

def url_download(name, url, sha256sum, verbose = false)
  downloader url, sha256sum, verbose
  puts "#{name.capitalize} archive downloaded.".lightgreen
end

def git_download(pkg, extract_dir)
  Dir.chdir extract_dir do
    system 'git init'
    system 'git config advice.detachedHead false'
    system "git fetch --depth 1 #{pkg.source_url} #{pkg.git_hashtag}"
    system 'git checkout FETCH_HEAD'
    system 'git submodule update --init --recursive --depth 1'
    system "git fetch --tags --depth 1 #{pkg.source_url}" if pkg.git_fetchtags?
    puts 'Repository downloaded.'.lightgreen
  end
end

def find_cached_url_download(name, filename, sha256sum, verbose)
  puts "Looking for #{name} archive in cache".orange if verbose
  # Privilege CREW_LOCAL_BUILD_DIR over CREW_CACHE_DIR.
  cachefile = File.join(CREW_CACHE_DIR, filename) if File.file?(File.join(CREW_CACHE_DIR, filename))
  if File.file?(File.join(CREW_LOCAL_BUILD_DIR, filename))
    cachefile = File.join(CREW_LOCAL_BUILD_DIR, filename)
    puts "Using #{name} archive from the build cache at #{cachefile}".orange
    puts 'The checksum will not be checked against the package file.'.orange
  end
  if cachefile
    puts "#{name.capitalize} archive file exists in cache".lightgreen if verbose
    # Don't check checksum if file is in the build cache.
    if Digest::SHA256.hexdigest(File.read(cachefile)) == sha256sum || cachefile == File.join(CREW_LOCAL_BUILD_DIR, filename)
      begin
        # Hard link cached file if possible.
        FileUtils.ln cachefile, CREW_BREW_DIR, force: true, verbose: verbose
        puts 'Archive hard linked from cache'.green if verbose
      rescue StandardError
        # Copy cached file if hard link fails.
        FileUtils.cp cachefile, CREW_BREW_DIR, verbose: verbose
        puts 'Archive copied from cache'.green if verbose
      end
      puts 'Archive found in cache'.lightgreen
    else
      puts 'Cached archive checksum mismatch. 😔 Will download.'.lightred
    end
  else
    puts 'Cannot find cached archive. 😔 Will download.'.lightred
  end
end

def find_cached_git_download(pkg, extract_dir, verbose)
  cachefile = File.join(CREW_CACHE_DIR, "#{filename}_#{pkg.git_hashtag.gsub('/', '_')}.tar.zst")
  puts "Git cachefile is #{cachefile}".orange if verbose
  if File.file?(cachefile) && File.file?("#{cachefile}.sha256")
    if Digest::SHA256.hexdigest(File.read(cachefile)) == File.read("#{cachefile}.sha256")
      system "tar -Izstd -x#{verbose}f #{cachefile} -C #{extract_dir}"
    else
      puts 'Cached git repository checksum mismatch. 😔 Will download.'.lightred
    end
  else
    puts 'Cannot find cached git repository. 😔 Will download.'.lightred
  end
end

def cache_downloaded_file(filename, verbose)
  begin
    # Hard link to cache if possible.
    FileUtils.ln filename, CREW_CACHE_DIR, verbose: verbose
    puts 'Archive hard linked to cache'.green if verbose
  rescue StandardError
    # Copy to cache if hard link fails.
    FileUtils.cp filename, CREW_CACHE_DIR, verbose: verbose
    puts 'Archive copied to cache'.green if verbose
  end
end

def cache_git_dir(pkg, extract_dir, verbose)
  cachefile = File.join(CREW_CACHE_DIR, "#{filename}_#{pkg.git_hashtag.gsub('/', '_')}.tar.zst")
  puts 'Caching downloaded git repo...'
  Dir.chdir extract_dir do
    # Do not use --exclude-vcs to exclude .git because some builds will use that information.
    system "tar c#{verbose} $(find -mindepth 1 -maxdepth 1 -printf '%P\n') | nice -n 20 #{CREW_PREFIX}/bin/zstd -c -T0 --ultra -20 - >  #{cachefile}"
  end
  File.write("#{cachefile}.sha256", Digest::SHA256.hexdigest(File.read(cachefile)))
  puts 'Git repo cached.'.lightgreen
end
