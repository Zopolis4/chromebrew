require 'buildsystems/autotools'

class Openais < Autotools
  description 'OpenAIS was an open implementation of the Application Interface Specification (AIS) provided by the Service Availability Forum (SAForum or SA).'
  homepage 'https://github.com/corosync/openais'
  version '1.1.4'
  license 'BSD-3-Clause'
  compatibility 'all'
  source_url 'https://github.com/corosync/openais/releases/download/openais-1.1.4/openais-1.1.4.tar.gz'
  source_sha256 '974b4959f3c401c16156dab31e65a6d45bbf84dd85a88c2a362712e738c06934'
end
