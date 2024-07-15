# lib/musl.rb
# Defines common musl build constants used in musl builds
require_relative 'const'

MUSL_CROSS_PREFIX = ARCH.eql?('armv7l') ? 'armhf-linux-musl-eabihf' : "#{ARCH}-linux-musl"

# https://www.thanassis.space/tricks.html#smartdynamic
# ha haaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

# It may seem like we're running a cross-compiler here, but that's only for gcc and musl.
# Everything else is still installed in CREW_PREFIX, which is why we're setting that as the sysroot here.
# Override the linker to use gold, as the musl gcc version that we use doesn't support -fuse-ld=mold and we have a cross version of gold.
CREW_COMMON_MUSL_FLAGS = \
  "#{CREW_COMMON_FLAGS.gsub("-fuse-ld=#{CREW_LINKER}", '-fuse-ld=gold')} \
  -L#{CREW_MUSL_PREFIX}/#{MUSL_CROSS_PREFIX}/lib/libc.so \
  --sysroot=#{CREW_PREFIX}"

# Setting the dynamic linker like this is less than ideal, but is the best solution with our awkward dual-sysroot semi-cross-compiling setup.
# Once we use musl natively, we'll need to use patchelf to adjust these variables in already-built musl packages.
# Additionally, once we use musl natively there will be no need to set the dynamic-linker path here, as musl will respect our syslibdir value.
CREW_MUSL_LDFLAGS = \
  "#{CREW_LDFLAGS} --sysroot=#{CREW_PREFIX} \
  -L#{CREW_MUSL_PREFIX}/#{MUSL_CROSS_PREFIX}/lib/libc.so \
  -Wl,--dynamic-linker,#{CREW_MUSL_PREFIX}/lib/libc.so"

CREW_MUSL_ENV_OPTIONS_HASH = \
  if CREW_DISABLE_ENV_OPTIONS
    { 'CREW_DISABLE_ENV_OPTIONS' => '1' }
  else
    {
      'CC'              => "#{MUSL_CROSS_PREFIX}-gcc",
      'CXX'             => "#{MUSL_CROSS_PREFIX}-g++",
      'LD'              => "#{MUSL_CROSS_PREFIX}-ld.gold",
      'AR'              => "#{MUSL_CROSS_PREFIX}-ar",
      'CFLAGS'          => CREW_COMMON_MUSL_FLAGS,
      'CXXFLAGS'        => CREW_COMMON_MUSL_FLAGS,
      'FCFLAGS'         => CREW_COMMON_MUSL_FLAGS,
      'FFLAGS'          => CREW_COMMON_MUSL_FLAGS,
      'LD_LIBRARY_PATH' => CREW_LIB_PREFIX,
      'LDFLAGS'         => CREW_MUSL_LDFLAGS
    }
  end

# parse from hash to shell readable string
CREW_MUSL_ENV_OPTIONS = CREW_MUSL_ENV_OPTIONS_HASH.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')
