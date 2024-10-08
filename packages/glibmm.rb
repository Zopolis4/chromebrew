require 'package'
Package.load_package("#{__dir__}/glibmm_2_4.rb")
Package.load_package("#{__dir__}/glibmm_2_68.rb")

class Glibmm < Package
  description Glibmm_2_4.description
  homepage Glibmm_2_4.homepage
  version "#{Glibmm_2_4.version}+#{Glibmm_2_68.version}"
  license Glibmm_2_4.license
  compatibility Glibmm_2_4.compatibility

  is_fake

  depends_on 'glibmm_2_4'
  depends_on 'glibmm_2_68'
end
