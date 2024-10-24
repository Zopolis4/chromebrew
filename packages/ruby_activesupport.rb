require 'buildsystems/ruby'

class Ruby_activesupport < RUBY
  description 'A toolkit of support libraries and Ruby core extensions extracted from the Rails framework.'
  homepage 'https://rubyonrails.org/'
  version "7.2.1-#{CREW_RUBY_VER}"
  license 'MIT'
  compatibility 'all'
  source_url 'SKIP'

  depends_on 'ruby_concurrent_ruby' # L
  conflicts_ok
  no_compile_needed
end
