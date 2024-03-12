require 'digest/sha2'
require 'fileutils'
require_relative '../lib/color'
require_relative '../lib/const'
require_relative '../lib/package'

class Command
  def self.download(pkg, opt_verbose)
    abort "No precompiled binary or source is available for #{ARCH}.".lightred unless url = pkg.get_url(ARCH.to_sym)
    abort "Unable to download fake package.".lightred if pkg.is_fake?

    build_cachefile = File.join(CREW_CACHE_DIR, "#{pkg.name}-#{pkg.version}-build-#{ARCH}.tar.zst")
    return build_cachefile if CREW_CACHE_BUILD && File.file?(build_cachefile)

    if pkg.build_from_source
      puts 'Downloading source...'
    elsif pkg.is_binary?(ARCH.to_sym)
      puts 'Precompiled binary available, downloading...'
    elsif url.casecmp?('SKIP')
      puts 'Skipping source download...'
    else
      puts 'No precompiled binary available for your platform, downloading source...'
    end

    filename = File.basename(url)
    sha256sum = pkg.get_sha256(ARCH.to_sym)
    extract_dir = "#{pkg.name}.#{Time.now.utc.strftime('%Y%m%d%H%M%S')}.dir"

    Dir.chdir CREW_BREW_DIR do
      Dir.mkdir extract_dir
      case filename
      when /\.zip$/i, /\.(tar(\.(gz|bz2|xz|lzma|lz|zst))?|tgz|tbz|tpxz|txz)$/i, /\.deb$/i, /\.AppImage$/i
        # If told to, try and find the downloaded file in the cache
        if CREW_CACHE_ENABLED
          cachefile = find_cached_url_download(pkg.name, sha256sum, opt_verbose)
          return cachefile unless cachefile.empty?
        end
        # Download the file if we weren't told to/weren't able to find it in the cache
        url_download(pkg.name, url, sha256sum, opt_verbose)
        # Cache the downloaded file if told to
        cache_downloaded_file(filename, opt_verbose) if CREW_CACHE_ENABLED
        # Return the location of the downloaded file
        return filename
      when /\.git$/i # Source URLs which end with .git are git sources.
        # If told to, try and find the cached git directory
        if CREW_CACHE_ENABLED
          cachefile = find_cached_git_download(pkg, extract_dir, opt_verbose)
          return cachefile unless cachefile.empty?
        end
        # Download the git repository if we weren't told to/weren't able to find it in the cache
        git_download(name, extract_dir)
        # Cache the git directory if told to
        cache_git_dir(extract_dir) if File.writable?(CREW_CACHE_DIR)
      else
        downloader url, sha256sum, opt_verbose

        puts "#{filename}: File downloaded.".lightgreen

        FileUtils.mv filename, "#{extract_dir}/#{filename}"
      end
    end
  end

  def url_download(name, url, sha256sum, opt_verbose)
    downloader url, sha256sum, opt_verbose
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

  def find_cached_url_download(name, sha256sum, opt_verbose)
    puts "Looking for #{name} archive in cache".orange if opt_verbose
    # Privilege CREW_LOCAL_BUILD_DIR over CREW_CACHE_DIR.
    local_build_cachefile = File.join(CREW_LOCAL_BUILD_DIR, filename)
    crew_cache_dir_cachefile = File.join(CREW_CACHE_DIR, filename)
    cachefile = File.file?(local_build_cachefile) ? local_build_cachefile : crew_cache_dir_cachefile
    puts "Using #{name} archive from the build cache at #{cachefile}; The checksum will not be checked against the package file.".orange if cachefile.include?(CREW_LOCAL_BUILD_DIR)
    if File.file?(cachefile)
      puts "#{name.capitalize} archive file exists in cache".lightgreen if opt_verbose
      # Don't check checksum if file is in the build cache.
      if Digest::SHA256.hexdigest(File.read(cachefile)) == sha256sum || sha256sum =~ /^SKIP$/i || cachefile.include?(CREW_LOCAL_BUILD_DIR)
        begin
          # Hard link cached file if possible.
          FileUtils.ln cachefile, CREW_BREW_DIR, force: true, verbose: opt_verbose unless File.identical?(cachefile, "#{CREW_BREW_DIR}/#{filename}")
          puts 'Archive hard linked from cache'.green if opt_verbose
        rescue StandardError
          # Copy cached file if hard link fails.
          FileUtils.cp cachefile, CREW_BREW_DIR, verbose: opt_verbose unless File.identical?(cachefile, "#{CREW_BREW_DIR}/#{filename}")
          puts 'Archive copied from cache'.green if opt_verbose
        end
        puts 'Archive found in cache'.lightgreen
        return filename
      else
        puts 'Cached archive checksum mismatch. 😔 Will download.'.lightred
        return
      end
    else
      puts 'Cannot find cached archive. 😔 Will download.'.lightred
      return
    end
  end

  def find_cached_git_download(pkg, extract_dir, opt_verbose)
    verbose = opt_verbose ? 'v' : ''
    cachefile = File.join(CREW_CACHE_DIR, "#{filename}_#{pkg.git_hashtag.gsub('/', '_')}.tar.zst")
    puts "Git cachefile is #{cachefile}".orange if opt_verbose
    if File.file?(cachefile) && File.file?("#{cachefile}.sha256")
      if Dir.chdir CREW_CACHE_DIR do
            system "sha256sum -c #{cachefile}.sha256"
          end
        FileUtils.mkdir_p extract_dir
        system "tar -Izstd -x#{verbose}f #{cachefile} -C #{extract_dir}"
        return filename
      else
        puts 'Cached git repository checksum mismatch. 😔 Will download.'.lightred
      end
    else
      puts 'Cannot find cached git repository. 😔 Will download.'.lightred
    end
  end

  def cache_downloaded_file(filename, opt_verbose)
    begin
      # Hard link to cache if possible.
      FileUtils.ln filename, CREW_CACHE_DIR, verbose: opt_verbose
      puts 'Archive hard linked to cache'.green if opt_verbose
    rescue StandardError
      # Copy to cache if hard link fails.
      FileUtils.cp filename, CREW_CACHE_DIR, verbose: opt_verbose
      puts 'Archive copied to cache'.green if opt_verbose
    end
  end

  def cache_git_dir(extract_dir, opt_verbose)
    verbose = opt_verbose ? 'v' : ''
    puts 'Caching downloaded git repo...'
    Dir.chdir extract_dir do
      # Do not use --exclude-vcs to exclude .git because some builds will use that information.
      system "tar c#{verbose} \
        $(find -mindepth 1 -maxdepth 1 -printf '%P\n') | \
        nice -n 20 #{CREW_PREFIX}/bin/zstd -c -T0 --ultra -20 - >  \
        #{cachefile}"
    end
    system 'sha256sum', cachefile, out: "#{cachefile}.sha256"
    puts 'Git repo cached.'.lightgreen
  end

end
