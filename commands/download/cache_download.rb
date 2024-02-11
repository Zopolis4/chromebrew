class Download
  def self.url_download(name, url, sha256sum, filename, opt_verbose)
    puts "Looking for #{name} archive in cache".orange if opt_verbose
    cachefile = File.join(CREW_CACHE_DIR, filename)
    if File.file?(cachefile)
      puts "#{name.capitalize} archive file exists in cache".lightgreen if opt_verbose
      if Digest::SHA256.hexdigest(File.read(cachefile)) == sha256sum || sha256sum =~ /^SKIP$/i
        begin
          # Hard link cached file if possible.
          FileUtils.ln cachefile, CREW_BREW_DIR, force: true, verbose: fileutils_verbose unless File.identical?(cachefile, "#{CREW_BREW_DIR}/#{filename}")
          puts 'Archive hard linked from cache'.green if opt_verbose
        rescue StandardError
          # Copy cached file if hard link fails.
          FileUtils.cp cachefile, CREW_BREW_DIR, verbose: @fileutils_verbose unless File.identical?(cachefile, "#{CREW_BREW_DIR}/#{filename}")
          puts 'Archive copied from cache'.green if opt_verbose
        end
        puts 'Archive found in cache'.lightgreen
        return { source:, filename: }
      else
        puts 'Cached archive checksum mismatch. 😔 Will download.'.lightred
        cachefile = ''
      end
    else
      puts 'Cannot find cached archive. 😔 Will download.'.lightred
      cachefile = ''
    end
  end
  def self.git_download(name, extract_dir)
    pkgPath = File.join(CREW_PACKAGES_PATH, "#{name}.rb")
    pkg = Package.load_package(pkgPath, name)
    # No git branch specified, just a git commit or tag
    if pkg.git_branch.to_s.empty?
      abort('No Git branch, commit, or tag specified!').lightred if pkg.git_hashtag.to_s.empty?
      cachefile = File.join(CREW_CACHE_DIR, "#{filename}#{pkg.git_hashtag.gsub('/', '_')}.tar.zst")
    # Git branch and git commit specified
    elsif !pkg.git_hashtag.to_s.empty?
      cachefile = File.join(CREW_CACHE_DIR, "#{filename}#{pkg.git_branch.gsub(/[^0-9A-Za-z.-]/, '_')}_#{pkg.git_hashtag.gsub('/', '_')}.tar.zst")
    # Git branch specified, without a specific git commit.
    else
      # Use to the day granularity for a branch timestamp with no specific commit specified.
      cachefile = File.join(CREW_CACHE_DIR, "#{filename}#{pkg.git_branch.gsub(/[^0-9A-Za-z.-]/, '_')}#{Time.now.strftime('%m%d%Y')}.tar.zst")
    end
    puts "Git cachefile is #{cachefile}".orange if opt_verbose
    if File.file?(cachefile) && File.file?("#{cachefile}.sha256")
      if Dir.chdir CREW_CACHE_DIR do
            system "sha256sum -c #{cachefile}.sha256"
          end
        FileUtils.mkdir_p extract_dir
        system "tar -Izstd -x#{@verbose}f #{cachefile} -C #{extract_dir}"
        return { source:, filename: }
      else
        puts 'Cached git repository checksum mismatch. 😔 Will download.'.lightred
      end
    else
      puts 'Cannot find cached git repository. 😔 Will download.'.lightred
    end
  end

  def self.cache_git_dir(extract_dir)
    puts 'Caching downloaded git repo...'
    Dir.chdir extract_dir do
      # Do not use --exclude-vcs to exclude .git
      # because some builds will use that information.
      system "tar c#{@verbose} \
        $(find -mindepth 1 -maxdepth 1 -printf '%P\n') | \
        nice -n 20 #{CREW_PREFIX}/bin/zstd -c -T0 --ultra -20 - >  \
        #{cachefile}"
    end
    system 'sha256sum', cachefile, out: "#{cachefile}.sha256"
    puts 'Git repo cached.'.lightgreen
  end

  def self.cache_downloaded_file(opt_verbose)
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
end
