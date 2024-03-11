require_relative '../../lib/downloader'
require_relative '../../lib/package'

class Download
  def self.url_download(name, url, sha256sum, opt_verbose)
    downloader url, sha256sum, opt_verbose
    puts "#{name.capitalize} archive downloaded.".lightgreen
  end

  def self.git_download(name, extract_dir)
    pkgPath = File.join(CREW_PACKAGES_PATH, "#{name}.rb")
    pkg = Package.load_package(pkgPath, name)
    Dir.mkdir extract_dir
    Dir.chdir extract_dir do
      if pkg.git_branch.to_s.empty?
        system 'git init'
        system 'git config advice.detachedHead false'
        system 'git config init.defaultBranch master'
        system "git remote add origin #{pkg.source_url}", exception: true
        system "git fetch --depth 1 origin #{pkg.git_hashtag}", exception: true
        system 'git checkout FETCH_HEAD'
      else
        # Leave a message because this step can be slow.
        puts 'Downloading src from a git branch. This may take a while...'
        system "git clone --branch #{pkg.git_branch} --single-branch #{pkg.source_url} tmpdir", exception: true
        system 'mv tmpdir/.git . && rm -rf tmpdir'
        system "git reset --hard #{pkg.git_hashtag}", exception: true
      end
      system 'git submodule update --init --recursive' unless pkg.no_git_submodules?
      system 'git fetch --tags', exception: true if pkg.git_fetchtags?
      system "git fetch origin #{pkg.git_hashtag}", exception: true if pkg.git_clone_deep?
      puts 'Repository downloaded.'.lightgreen
   end
  end
end
