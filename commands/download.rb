require 'digest/sha2'
require 'fileutils'
require_relative '../lib/color'
require_relative '../lib/const'
require_relative '../lib/downloader'
require_relative '../lib/package'

class Command
  def self.download(pkg, verbose)
    abort "No precompiled binary or source is available for #{ARCH}.".lightred unless url = pkg.get_url(ARCH.to_sym)
    abort 'Unable to download fake package.'.lightred if pkg.is_fake?

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

cd $HOME
mkdir -p .cache/git
cd .cache/git
git init --bare
git config --local receive.shallowUpdate true
export GIT_ALTERNATE_OBJECT_DIRECTORIES=$HOME/.cache/git/objects
mkdir -p $CREW_PREFIX/etc/git_cache/hooks
git config -f $CREW_PREFIX/etc/git_cache/config core.hooksPath $CREW_PREFIX/etc/git_cache/hooks
git config --global includeIf.gitdir:$CREW_PREFIX/tmp/.path $CREW_PREFIX/etc/git_cache/config
echo 'git push ~/.cache/git HEAD:refs/heads/$(sed '\''s/.* //g'\'' .git/FETCH_HEAD | sed '\''s/\.git//'\'' | xargs basename)'  > $CREW_PREFIX/etc/git_cache/hooks/post-checkout
chmod +x $CREW_PREFIX/etc/git_cache/hooks/post-checkout

# REAL PLAN
# initialise the cache repo
# cd $HOME
# mkdir -p .cache/git
# cd .cache/git
# git init --bare
# git config --local receive.shallowUpdate true
# export GIT_ALTERNATE_OBJECT_DIRECTORIES=$HOME/.cache/git/objects
# create the configuration setup
# mkdir -p $CREW_PREFIX/etc/git_cache/hooks
# git config -f $CREW_PREFIX/etc/git_cache/config core.hooksPath $CREW_PREFIX/etc/git_cache/hooks
# git config --global includeIf.gitdir:$CREW_PREFIX/tmp/.path $CREW_PREFIX/etc/git_cache/config

# now we gotta create the actual hook
# echo 'git push ~/.cache/git HEAD:refs/heads/$(sed '\''s/.* //g'\'' FETCH_HEAD | sed '\''s/\.git//'\'' | xargs basename)'  > $CREW_PREFIX/etc/git_cache/hooks/post-checkout
# chmod +x $CREW_PREFIX/etc/git_cache/hooks/post-checkout

# sed 's/.* //g' .git/FETCH_HEAD | sed 's/\.git//' | xargs basename
# git branch --track $(sed 's/.* //g' .git/FETCH_HEAD | sed 's/\.git//' | xargs basename) $(sed 's/.* //g' .git/FETCH_HEAD)/$(git remote show $(sed 's/.* //g' .git/FETCH_HEAD) | awk 'NR==4 {print $3}')
# git branch --track local_branch remote_url/remote_branch
# git ls-remote --symref $(sed 's/.* //g' .git/FETCH_HEAD) HEAD | awk 'NR==1 {print $2}' | xargs basename
# git remote show $(sed 's/.* //g' .git/FETCH_HEAD) | awk 'NR==4 {print $3}'
#

# new plan
# do this in the cache repo (git config --local receive.shallowUpdate true)
# git push ~/.cache/git HEAD:refs/heads/$(sed 's/.* //g' .git/FETCH_HEAD | sed 's/\.git//' | xargs basename)



# Looking at the git sources, the relevant function is `git_url_basename`, which, despite being split out into `dir.c` and made available in `dir.h` in [ed86301][1], is only used by `builtin/clone.c` and `builtin/submodule--helper.c`, so easy no way of accessing that function without calling `git clone`.
#
# So, taking a look at the source of `git_url_basename`:
# ```
# char *git_url_basename(const char *repo, int is_bundle, int is_bare)
# {
# 	const char *end = repo + strlen(repo), *start, *ptr;
# 	size_t len;
# 	char *dir;
#
# 	/*
# 	 * Skip scheme.
# 	 */
# 	start = strstr(repo, "://");
# 	if (!start)
# 		start = repo;
# 	else
# 		start += 3;
#
# 	/*
# 	 * Skip authentication data. The stripping does happen
# 	 * greedily, such that we strip up to the last '@' inside
# 	 * the host part.
# 	 */
# 	for (ptr = start; ptr < end && !is_dir_sep(*ptr); ptr++) {
# 		if (*ptr == '@')
# 			start = ptr + 1;
# 	}
#
# 	/*
# 	 * Strip trailing spaces, slashes and /.git
# 	 */
# 	while (start < end && (is_dir_sep(end[-1]) || isspace(end[-1])))
# 		end--;
# 	if (end - start > 5 && is_dir_sep(end[-5]) &&
# 	    !strncmp(end - 4, ".git", 4)) {
# 		end -= 5;
# 		while (start < end && is_dir_sep(end[-1]))
# 			end--;
# 	}
#
# 	/*
# 	 * It should not be possible to overflow `ptrdiff_t` by passing in an
# 	 * insanely long URL, but GCC does not know that and will complain
# 	 * without this check.
# 	 */
# 	if (end - start < 0)
# 		die(_("No directory name could be guessed.\n"
# 		      "Please specify a directory on the command line"));
#
# 	/*
# 	 * Strip trailing port number if we've got only a
# 	 * hostname (that is, there is no dir separator but a
# 	 * colon). This check is required such that we do not
# 	 * strip URI's like '/foo/bar:2222.git', which should
# 	 * result in a dir '2222' being guessed due to backwards
# 	 * compatibility.
# 	 */
# 	if (memchr(start, '/', end - start) == NULL
# 	    && memchr(start, ':', end - start) != NULL) {
# 		ptr = end;
# 		while (start < ptr && isdigit(ptr[-1]) && ptr[-1] != ':')
# 			ptr--;
# 		if (start < ptr && ptr[-1] == ':')
# 			end = ptr - 1;
# 	}
#
# 	/*
# 	 * Find last component. To remain backwards compatible we
# 	 * also regard colons as path separators, such that
# 	 * cloning a repository 'foo:bar.git' would result in a
# 	 * directory 'bar' being guessed.
# 	 */
# 	ptr = end;
# 	while (start < ptr && !is_dir_sep(ptr[-1]) && ptr[-1] != ':')
# 		ptr--;
# 	start = ptr;
#
# 	/*
# 	 * Strip .{bundle,git}.
# 	 */
# 	len = end - start;
# 	strip_suffix_mem(start, &len, is_bundle ? ".bundle" : ".git");
#
# 	if (!len || (len == 1 && *start == '/'))
# 		die(_("No directory name could be guessed.\n"
# 		      "Please specify a directory on the command line"));
#
# 	if (is_bare)
# 		dir = xstrfmt("%.*s.git", (int)len, start);
# 	else
# 		dir = xstrndup(start, len);
# 	/*
# 	 * Replace sequences of 'control' characters and whitespace
# 	 * with one ascii space, remove leading and trailing spaces.
# 	 */
# 	if (*dir) {
# 		char *out = dir;
# 		int prev_space = 1 /* strip leading whitespace */;
# 		for (end = dir; *end; ++end) {
# 			char ch = *end;
# 			if ((unsigned char)ch < '\x20')
# 				ch = '\x20';
# 			if (isspace(ch)) {
# 				if (prev_space)
# 					continue;
# 				prev_space = 1;
# 			} else
# 				prev_space = 0;
# 			*out++ = ch;
# 		}
# 		*out = '\0';
# 		if (out > dir && prev_space)
# 			out[-1] = '\0';
# 	}
# 	return dir;
# }
# ```
# So, let's re-implement this in `sed`.
#
# ```
# # Skip scheme
# sed 's/.*:\/\///'
# # Skip authentication data
# sed 's/[^/]*@[^/]*//'
# ```
#
#
#   [1]: https://github.com/git/git/commit/ed86301f68fcbb17c5d1c7a3258e4705b3b1da9c

# #!/bin/sh
#
# # make sure that cloning $1 results in local directory $2
# test_sed () {
#   echo "$1" |
#   # Strip scheme (ssh://, git://, https://)
#   sed 's/.*:\/\///' |
#   # Strip authentication data
#   sed 's/[^/]*@//' |
#   # Strip trailing slashes and spaces
#   sed 's/[[:space:]/]*$//' |
#   # Strip trailing /.git
#   sed 's/\/\.git$//' |
#   # Strip trailing slashes again
#   sed 's/\/\+$//' |
#   # If the string contains a : and does not contain a /, strip trailing digits
#   sed -E '/.*\/.*/! { /.*:.*/ s/[0-9]*$// }' |
#   # Strip trailing colons
#   sed 's/:*$//' |
#   # Find the last component of the string, treating / and : as path separators
#   sed -E 's/.*[/:]([^/:]+)$/\1/' |
#   # Strip trailing .bundle or .git
#   sed 's/\.bundle$//;s/\.git$//'
# }
#
# test_clone_dir () {
#   [ "$3" = "bare" ] && return 1
#   if [ "$(test_sed $1)" = "$2" ]; then
#     echo "Passing on $1"
#   else
#     echo "Failing on $1, outputting $(test_sed $1) instead of expected $2"
#   fi
# }
#
# # basic syntax with bare and non-bare variants
# test_clone_dir host:foo foo
# test_clone_dir host:foo foo.git bare
# test_clone_dir host:foo.git foo
# test_clone_dir host:foo.git foo.git bare
# test_clone_dir host:foo/.git foo
# test_clone_dir host:foo/.git foo.git bare
#
# # similar, but using ssh URL rather than host:path syntax
# test_clone_dir ssh://host/foo foo
# test_clone_dir ssh://host/foo foo.git bare
# test_clone_dir ssh://host/foo.git foo
# test_clone_dir ssh://host/foo.git foo.git bare
# test_clone_dir ssh://host/foo/.git foo
# test_clone_dir ssh://host/foo/.git foo.git bare
#
# # we should remove trailing slashes and .git suffixes
# test_clone_dir ssh://host/foo/ foo
# test_clone_dir ssh://host/foo/// foo
# test_clone_dir ssh://host/foo/.git/ foo
# test_clone_dir ssh://host/foo.git/ foo
# test_clone_dir ssh://host/foo.git/// foo
# test_clone_dir ssh://host/foo///.git/ foo
# test_clone_dir ssh://host/foo/.git/// foo
#
# test_clone_dir host:foo/ foo
# test_clone_dir host:foo/// foo
# test_clone_dir host:foo.git/ foo
# test_clone_dir host:foo/.git/ foo
# test_clone_dir host:foo.git/// foo
# test_clone_dir host:foo///.git/ foo
# test_clone_dir host:foo/.git/// foo
#
# # omitting the path should default to the hostname
# test_clone_dir ssh://host/ host
# test_clone_dir ssh://host:1234/ host
# test_clone_dir ssh://user@host/ host
# test_clone_dir host:/ host
#
# # auth materials should be redacted
# test_clone_dir ssh://user:password@host/ host
# test_clone_dir ssh://user:password@host:1234/ host
# test_clone_dir ssh://user:passw@rd@host:1234/ host
# test_clone_dir user@host:/ host
# test_clone_dir user:password@host:/ host
# test_clone_dir user:passw@rd@host:/ host
#
# # auth-like material should not be dropped
# test_clone_dir ssh://host/foo@bar foo@bar
# test_clone_dir ssh://host/foo@bar.git foo@bar
# test_clone_dir ssh://user:password@host/foo@bar foo@bar
# test_clone_dir ssh://user:passw@rd@host/foo@bar.git foo@bar
#
# test_clone_dir host:/foo@bar foo@bar
# test_clone_dir host:/foo@bar.git foo@bar
# test_clone_dir user:password@host:/foo@bar foo@bar
# test_clone_dir user:passw@rd@host:/foo@bar.git foo@bar
#
# # trailing port-like numbers should not be stripped for paths
# test_clone_dir ssh://user:password@host/test:1234 1234
# test_clone_dir ssh://user:password@host/test:1234.git 1234

def git_download(pkg, extract_dir)
  Dir.chdir extract_dir do
    system 'git init'
    system 'git config advice.detachedHead false'
    system "git fetch #{'--tags' if pkg.git_fetchtags?} --depth 1 #{pkg.source_url} #{pkg.git_hashtag}"
    system 'git checkout FETCH_HEAD'
    system 'git submodule update --init --recursive --depth 1'
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
        puts 'Archive hard linked from cache.'.green if verbose
      rescue StandardError
        # Copy cached file if hard link fails.
        FileUtils.cp cachefile, CREW_BREW_DIR, verbose: verbose
        puts 'Archive copied from cache.'.green if verbose
      end
      puts 'Archive found in cache.'.lightgreen
    else
      puts 'Cached archive checksum mismatch. 😔 Will download.'.lightred
    end
    return cachefile
  else
    puts 'Cannot find cached archive. 😔 Will download.'.lightred
    return filename
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
  return if filename.include?(CREW_CACHE_DIR)
  begin
    # Hard link to cache if possible.
    FileUtils.ln filename, CREW_CACHE_DIR, force: true, verbose: verbose
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
