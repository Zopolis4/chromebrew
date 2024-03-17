require 'minitest/autorun'
require 'digest/sha2'
require_relative '../../lib/const'
require_relative '../../lib/package'
require_relative '../../commands/download'

# Add >LOCAL< lib to LOAD_PATH so that packages can be loaded
$LOAD_PATH.unshift File.join(CREW_LIB_PATH, 'lib')

class DownloadCommandTest < Minitest::Test
  def test_download_tar
    pkg = Package.load_package(File.join(CREW_LIB_PATH, 'tests/data/openais.rb'))
    filename, extract_dir = Command.download(pkg, nil)
    assert_equal(File.basename(pkg.source_url), filename)
    assert(File.exist?(File.join(CREW_BREW_DIR, extract_dir)))
    assert_equal(Digest::SHA256.hexdigest(File.read(File.join(CREW_BREW_DIR, filename))), pkg.source_sha256)
  end
end
