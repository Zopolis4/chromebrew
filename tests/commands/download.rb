require 'minitest/autorun'
require_relative '../../lib/const'
require_relative '../../lib/package'
require_relative '../../commands/download'

class DownloadCommandTest < Minitest::Test
  def test_download_tar
    pkg = Package.load_package(File.join(CREW_LIB_PATH, 'tests/data/openais.rb'))
    filename, extract_dir = Command.download(pkg, nil)
    assert_equal(File.basename(pkg.url), filename)
    assert(File.file?(File.join(CREW_BREW_DIR, extract_dir)))
  end
end
