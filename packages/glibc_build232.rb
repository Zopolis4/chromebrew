require 'package'

class Glibc_build232 < Package
  description 'The GNU C Library project provides the core libraries for GNU/Linux systems.'
  homepage 'https://www.gnu.org/software/libc/'
  version '2.32-4'
  license 'LGPL-2.1+, BSD, HPND, ISC, inner-net, rc, and PCRE'
  @libc_version = LIBC_VERSION
  compatibility 'aarch64 armv7l x86_64'
  min_glibc version.split('-').first
  max_glibc version.split('-').first
  source_url 'https://ftpmirror.gnu.org/glibc/glibc-2.32.tar.xz'
  source_sha256 '1627ea54f5a1a8467032563393e0901077626dc66f37f10ee6363bb722222836'
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: '2ab295e7c338288bf5fa6cb7b76c0039e452c7dab379744342a7bac1d26a300b',
     armv7l: '2ab295e7c338288bf5fa6cb7b76c0039e452c7dab379744342a7bac1d26a300b',
     x86_64: '37870ec860096ce1081b87b8155e4ad38ff5979d2baf4e367d8087aa4e1ce603'
  })

  depends_on 'gawk' => :build
  depends_on 'filecmd' # L Fixes creating symlinks on a fresh install.
  depends_on 'libidn2' => :build
  depends_on 'texinfo' => :build
  depends_on 'hashpipe' => :build
  # depends_on 'libtirpc' # R

  conflicts_ok
  no_env_options
  no_upstream_update

  def self.patch
    FileUtils.mkdir 'fedora'
    # Patch to enable build-local-archive
    system 'curl -Ls https://src.fedoraproject.org/rpms/glibc/raw/f30/f/glibc-fedora-locarchive.patch | \
    hashpipe sha256 0acccf57d8c6e7de82871c61ccb845f7a1ae13ae1fbc65995d347de8367c7bb1 | \
    patch -Np1 --binary'
    system 'curl -Ls https://src.fedoraproject.org/rpms/glibc/raw/f30/f/build-locale-archive.c | \
    hashpipe sha256 6834e8b8f2a987bf8adfd265c0e01665f102c7115db94b99ec36376b68e9d3fa > fedora/build-locale-archive.c'
    system "sed -i 's,/lib/locale,/lib#{CREW_LIB_SUFFIX}/locale,g' fedora/build-locale-archive.c"
    system "sed -i 's,/usr/sbin/tzdata-update,/bin/true,g' fedora/build-locale-archive.c"
    system "sed -i 's,verbose,locale_verbose,g' fedora/build-locale-archive.c"
    system "sed -i 's,be_quiet,locale_be_quiet,g' fedora/build-locale-archive.c"
    FileUtils.mkdir_p 'gentoopatches'
    system 'curl -Ls https://dev.gentoo.org/~dilfridge/distfiles/glibc-2.32-patches-8.tar.xz | \
      hashpipe sha256 6653f1d0aadad10bd288f3bae274bd4e0a013d47f09ce78199fb5989b2d8fd9b | \
      tar -xJf - -C gentoopatches'
    Dir.glob('gentoopatches/patches/*.patch').each do |patch|
      puts "patch -Np1 < #{patch}" if @opt_verbose
      system "patch -Np1 < #{patch}"
    end
    @googlesource_branch = 'release-R96-14268.B'
    system "git clone --depth=1 -b  #{@googlesource_branch} https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay googlesource"
    Dir.glob('googlesource/sys-libs/glibc/files/local/glibc-2.32/*.patch').each do |patch|
      puts "patch -Np1 < #{patch}" if @opt_verbose
      system "patch -Np1 < #{patch}"
    end
  end

  def self.build
    FileUtils.mkdir_p 'glibc_build'
    Dir.chdir 'glibc_build' do
      # gold linker does not work for glibc 2.23, and maybe others.
      FileUtils.mkdir_p 'binutils'
      @binutils = File.readlines(File.join(CREW_META_PATH, 'binutils.filelist'))
      @binutils.each do |bin|
        FileUtils.cp bin.chomp, "binutils/#{File.basename(bin.chomp)}" if bin['/bin/']
      end
      FileUtils.cp 'binutils/ld.bfd', 'binutils/ld'
      # Optimization flags from https://github.com/InBetweenNames/gentooLTO
      case ARCH
      when 'armv7l', 'aarch64'
        system "CFLAGS='-pipe -O2 -fipa-pta -fno-semantic-interposition -fdevirtualize-at-ltrans' \
          LD=ld ../configure \
          --prefix=#{CREW_PREFIX} \
          --libdir=#{CREW_LIB_PREFIX} \
          --with-headers=#{CREW_PREFIX}/include \
          --without-gd \
          ac_cv_header_cpuid_h=yes \
          ac_cv_lib_audit_audit_log_user_avc_message=no \
          ac_cv_lib_cap_cap_init=no \
          --disable-profile \
          --disable-sanity-checks \
          --disable-werror \
          --enable-bind-now \
          --enable-hacker-mode \
          --enable-kernel=4.14 \
          --enable-shared \
          libc_cv_386_tls=yes \
          libc_cv_arm_tls=yes \
          libc_cv_asm_cfi_directives=yes \
          libc_cv_broken_visibility_attribute=no \
          libc_cv_c_cleanup=yes \
          libc_cv_forced_unwind=yes \
          libc_cv_gcc___thread=yes \
          libc_cv_hashstyle=no \
          libc_cv_mlong_double_128ibm=yes \
          libc_cv_mlong_double_128=yes \
          libc_cv_predef_fortify_source=no \
          libc_cv_visibility_attribute=yes \
          libc_cv_x86_64_tls=yes \
          libc_cv_z_combreloc=yes \
          libc_cv_z_execstack=yes \
          libc_cv_z_initfirst=yes \
          libc_cv_z_nodelete=yes \
          libc_cv_z_nodlopen=yes \
          libc_cv_z_relro=yes \
          --with-binutils=binutils \
          --with-bugurl=https://github.com/chromebrew/chromebrew/issues/new \
          --without-cvs \
          --without-selinux \
          "
        # install-symbolic-link segfaults on armv7l, but we're deleting
        # the libraries anyways, so it doesn't matter.
        system "sed -i 's,install-symbolic-link,/bin/true,g' ../Makefile"
        system "sed -i 's,symbolic-link-prog := $(elf-objpfx)sln,symbolic-link-prog := /bin/true,g' ../Makerules"
      when 'x86_64'
        File.write('configparms', "slibdir=#{CREW_LIB_PREFIX}", mode: 'a+')
        system "CFLAGS='-pipe -O2 -fipa-pta -fno-semantic-interposition -falign-functions=32 -fdevirtualize-at-ltrans' \
          LD=ld ../configure \
          --prefix=#{CREW_PREFIX} \
          --libdir=#{CREW_LIB_PREFIX} \
          --with-headers=#{CREW_PREFIX}/include \
          ac_cv_header_cpuid_h=yes \
          ac_cv_lib_audit_audit_log_user_avc_message=no \
          ac_cv_lib_cap_cap_init=no \
          --disable-profile \
          --disable-sanity-checks \
          --disable-werror \
          --enable-bind-now \
          --enable-cet \
          --enable-hacker-mode \
          --enable-kernel=4.14 \
          --enable-shared \
          libc_cv_386_tls=yes \
          libc_cv_arm_tls=yes \
          libc_cv_asm_cfi_directives=yes \
          libc_cv_broken_visibility_attribute=no \
          libc_cv_c_cleanup=yes \
          libc_cv_forced_unwind=yes \
          libc_cv_gcc___thread=yes \
          libc_cv_hashstyle=no \
          libc_cv_mlong_double_128ibm=yes \
          libc_cv_mlong_double_128=yes \
          libc_cv_predef_fortify_source=no \
          libc_cv_visibility_attribute=yes \
          libc_cv_x86_64_tls=yes \
          libc_cv_z_combreloc=yes \
          libc_cv_z_execstack=yes \
          libc_cv_z_initfirst=yes \
          libc_cv_z_nodelete=yes \
          libc_cv_z_nodlopen=yes \
          libc_cv_z_relro=yes \
          --with-binutils=binutils \
          --with-bugurl=https://github.com/chromebrew/chromebrew/issues/new \
          --without-cvs \
          --without-gd \
          --without-selinux \
          "
      end
      system "make PARALLELMFLAGS='-j #{CREW_NPROC}' || make || make PARALLELMFLAGS='-j 1'"
      if Gem::Version.new(@libc_version.to_s) >= Gem::Version.new('2.32')
        system "gcc -Os -g -static -o build-locale-archive ../fedora/build-locale-archive.c \
          ../glibc_build/locale/locarchive.o \
          ../glibc_build/locale/md5.o \
          ../glibc_build/locale/record-status.o \
          -I. -DDATADIR=\\\"#{CREW_PREFIX}/share\\\" -DPREFIX=\\\"#{CREW_PREFIX}\\\" \
          -L../glibc_build \
          -B../glibc_build/csu/ -lc -lc_nonshared"
      end
    end
  end

  def self.install
    FileUtils.mkdir_p CREW_DEST_LIB_PREFIX
    system "sed 's,/usr/#{ARCH_LIB}/libc_nonshared.a,#{CREW_LIB_PREFIX}/libc_nonshared.a,g' /usr/#{ARCH_LIB}/libc.so > #{CREW_DEST_LIB_PREFIX}/libc.so"
    FileUtils.mkdir_p "#{CREW_DEST_PREFIX}/etc"
    Dir.chdir 'glibc_build' do
      system 'touch', "#{CREW_DEST_PREFIX}/etc/ld.so.conf"
      case ARCH
      when 'aarch64', 'armv7l'
        system "make -j1 DESTDIR=#{CREW_DEST_DIR} install || true" # "sln elf/symlink.list" fails on armv7l
      when 'x86_64'
        system "make -j1 DESTDIR=#{CREW_DEST_DIR} install"
      end
      Dir.chdir CREW_DEST_LIB_PREFIX do
        puts "System glibc version is #{LIBC_VERSION}.".lightblue
        puts 'Creating symlinks to system glibc version to prevent breakage.'.lightblue
        @crew_libc_version = @libc_version
        case ARCH
        when 'aarch64', 'armv7l'
          FileUtils.ln_sf File.realpath('/lib/ld-linux-armhf.so.3'), 'ld-linux-armhf.so.3'
        when 'x86_64'
          FileUtils.ln_sf File.realpath('/lib64/ld-linux-x86-64.so.2'), 'ld-linux-x86-64.so.2'
        end
        @libraries = %w[ld libBrokenLocale libSegFault libanl libc libcrypt
                        libdl libm libmemusage libmvec libnsl libnss_compat libnss_db
                        libnss_dns libnss_files libnss_hesiod libpcprofile libpthread
                        libthread_db libresolv librlv librt libthread_db-1.0 libutil]
        @libraries -= ['libpthread'] if @crew_libc_version.to_f >= 2.35
        @libraries.each do |lib|
          # Reject entries which aren't libraries ending in .so, and which aren't files.
          # Reject text files such as libc.so because they points to files like
          # libc_nonshared.a, which are not provided by ChromeOS
          Dir["{,/usr}/#{ARCH_LIB}/#{lib}.so*"].compact.select { |i| ['shared object', 'symbolic link'].any? { |j| `file #{i}`.chomp.include? j } }.each do |k|
            FileUtils.ln_sf k, File.join(CREW_DEST_LIB_PREFIX, File.basename(k))
          end
        end
      end
    end
    # Only save libnsl.so.2, since libnsl.so.1 is provided by perl
    FileUtils.ln_sf File.realpath("#{CREW_DEST_LIB_PREFIX}/libnsl.so.1"), "#{CREW_DEST_LIB_PREFIX}/libnsl.so.2"
    FileUtils.rm_f "#{CREW_DEST_LIB_PREFIX}/libnsl.so"
    FileUtils.rm_f "#{CREW_DEST_LIB_PREFIX}/libnsl.so.1"

    # Remove libmount.so since it conflicts with the one from util_linux.
    FileUtils.rm Dir.glob("#{CREW_DEST_LIB_PREFIX}/libmount.so*")
  end

  def self.check
    # Dir.chdir 'glibc_build' do
    #   system 'make -j1 check'
    # end
  end

  def self.postinstall
    if File.exist?("#{CREW_LIB_PREFIX}/libc.so.6")
      FileUtils.chmod 'u=wrx', "#{CREW_LIB_PREFIX}/libc.so.6"
      @crew_libcvertokens = `#{CREW_LIB_PREFIX}/libc.so.6`.lines.first.chomp.split(/\s/)
      @crew_libc_version = @crew_libcvertokens[@crew_libcvertokens.find_index('version') + 1].sub!(/[[:punct:]]?$/, '')
      puts "Package glibc version is #{@crew_libc_version}.".lightblue
    else
      @crew_libc_version = LIBC_VERSION
    end
    @libraries = %w[ld libBrokenLocale libSegFault libanl libc libcrypt
                    libdl libm libmemusage libmvec libnsl libnss_compat libnss_db
                    libnss_dns libnss_files libnss_hesiod libpcprofile libpthread
                    libthread_db libresolv librlv librt libthread_db-1.0 libutil]
    @libraries -= ['libpthread'] if Gem::Version.new(@libc_version.to_s) >= Gem::Version.new('2.35')
    Dir.chdir CREW_LIB_PREFIX do
      puts "System glibc version is #{@crew_libc_version}.".lightblue
      puts 'Creating symlinks to system glibc version to prevent breakage.'.lightblue
      case ARCH
      when 'aarch64', 'armv7l'
        FileUtils.ln_sf File.realpath('/lib/ld-linux-armhf.so.3'), 'ld-linux-armhf.so.3'
      when 'x86_64'
        FileUtils.ln_sf File.realpath('/lib64/ld-linux-x86-64.so.2'), 'ld-linux-x86-64.so.2'
      end
      @libraries.each do |lib|
        # Reject entries which aren't libraries ending in .so, and which aren't files.
        # Reject text files such as libc.so because they points to files like
        # libc_nonshared.a, which are not provided by ChromeOS
        Dir["{,/usr}/#{ARCH_LIB}/#{lib}.so*"].compact.select { |i| ['shared object', 'symbolic link'].any? { |j| `file #{i}`.chomp.include? j } }.each do |k|
          FileUtils.ln_sf k, File.join(CREW_LIB_PREFIX, File.basename(k))
        end
      end
    end
  end
end
