require 'package'
Package.load_package("#{__dir__}/glibc.rb")
Package.load_package("#{__dir__}/glibc_build235.rb")
Package.load_package("#{__dir__}/glibc_build237.rb")

class Glibc_lib < Package
  description 'glibc libraries'
  homepage Glibc.homepage
  license Glibc.license
  source_url 'SKIP'

  is_fake

  case LIBC_VERSION
  when '2.35'
    version Glibc_build235.version
    compatibility Glibc_build235.compatibility
    depends_on 'glibc_lib235'
  when '2.37'
    version Glibc_build237.version
    compatibility Glibc_build237.compatibility
    depends_on 'glibc_lib237'
  else
    version Glibc.version
    compatibility Glibc.compatibility
    depends_on 'glibc'
  end
end
