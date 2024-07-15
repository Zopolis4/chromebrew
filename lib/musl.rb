# lib/musl.rb
# Defines common musl build constants used in musl builds.
require_relative 'const'

# x86_64-cros-linux-musl on x86_64, i686-cros-linux-musl on i686 and armv7l-cros-linux-musleabihf on armv7l.
MUSL_CROSS_PREFIX = "#{ARCH}-cros-linux-musl#{'eabihf' if ARCH.eql?('armv7l')}"

# x86_64 on x86_64, i386 on i686 and armhf on armv7l.
MUSL_LINKER_SUFFIX = { armv7l: 'armhf', i686: 'i386', x86_64: 'x86_64' }[ARCH.to_sym]

# https://www.thanassis.space/tricks.html#smartdynamic
# ha haaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

# It may seem like we're running a cross-compiler here, but that's only for gcc and musl.
# Everything else is still installed in CREW_PREFIX, which is why we're setting that as the sysroot here.

CREW_COMMON_MUSL_FLAGS = <<~OPT.chomp
  --sysroot=#{CREW_PREFIX}/#{MUSL_CROSS_PREFIX} \
  -dynamic-linker #{CREW_PREFIX}/lib/ld-musl-#{MUSL_LINKER_SUFFIX}.so.1 \
  -Wl,--rpath=#{CREW_PREFIX}/#{MUSL_CROSS_PREFIX}/lib
OPT

# CREW_COMMON_MUSL_FLAGS = <<~OPT.chomp
#   -isystem #{CREW_PREFIX}/#{MUSL_CROSS_PREFIX}/include \
#   -nostartfiles \
#   -no-pie \
#   -L #{CREW_PREFIX}/#{MUSL_CROSS_PREFIX}/lib \
#   -Wl,#{CREW_PREFIX}/#{MUSL_CROSS_PREFIX}/lib/crt1.o \
#   -Wl,#{CREW_PREFIX}/#{MUSL_CROSS_PREFIX}/lib/crti.o \
#   -Wl,#{CREW_PREFIX}/#{MUSL_CROSS_PREFIX}/lib/crtn.o \
#   -Wl,#{CREW_PREFIX}/#{MUSL_CROSS_PREFIX}/lib/libc.so \
#   -dynamic-linker #{CREW_PREFIX}/lib/ld-musl-#{MUSL_LINKER_SUFFIX}.so.1 \
#   -Wl,--rpath=#{CREW_PREFIX}/#{MUSL_CROSS_PREFIX}/lib
# OPT

# Setting the dynamic linker like this is less than ideal, but is the best solution with our awkward dual-sysroot semi-cross-compiling setup.
# Once we use musl natively, we'll need to use patchelf to adjust these variables in already-built musl packages.
# Additionally, once we use musl natively there will be no need to set the dynamic-linker path here, as musl will respect our syslibdir value.

CREW_MUSL_ENV_OPTIONS_HASH = {
  'CFLAGS'          => CREW_COMMON_MUSL_FLAGS,
  'CXXFLAGS'        => CREW_COMMON_MUSL_FLAGS,
  'FCFLAGS'         => CREW_COMMON_MUSL_FLAGS,
  'FFLAGS'          => CREW_COMMON_MUSL_FLAGS,
  'LD_LIBRARY_PATH' => CREW_LIB_PREFIX,
  'LDFLAGS'         => CREW_LDFLAGS
}

# Parse from hash to shell readable string
CREW_MUSL_ENV_OPTIONS = CREW_MUSL_ENV_OPTIONS_HASH.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')
