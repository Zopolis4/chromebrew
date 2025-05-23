require 'package'

class Ld_default < Package
  description "Select the default ld executable and check for libraries in #{CREW_LIB_PREFIX} first"
  homepage 'https://github.com/chromebrew/chromebrew/wiki/FAQ'
  version '1.4'
  license 'GPL-3+'
  compatibility 'all'
  source_url 'SKIP'

  depends_on 'llvm_dev'

  no_compile_needed

  def self.build
    File.write 'ld_default', <<~EOF
      #!/bin/bash

      set -e

      mktmp=$(mktemp -d)

      cd #{CREW_PREFIX}/bin

      type=$(file ld | cut -d' ' -f2 | tr -d '\n')

      if [[ "${type}" == "ELF" ]]; then
        current=$(basename $(find . -inum $(ls -i ld | cut -d' ' -f1) | fgrep 'ld.'))
      elif [[ "${type}" == "symbolic" ]]; then
        current=$(basename $(readlink ld))
      elif [[ "${type}" == "Bourne-Again" ]]; then
        current=$(basename $(tail -1 ld | cut -d' ' -f1))
      else # Fall back to "Unknown" if linker was not identified
        current="Unknown"
      fi

      if [[ -z "${1}" ]]; then
        echo
        echo "  Current default linker: ${current}"
        echo
        echo '  Enter the new default linker:'
        echo
        echo '  b = ld.bfd'
        echo '  g = ld.gold'
        echo '  l = ld.lld'
        echo '  0 = Cancel'
        echo
      else
        echo "${current}" | cut -d'.' -f2 | cut -c1
      fi

      while true; do
        if [[ -z "${1}" ]]; then
          read default
        else
          default="${1}"
          if [[ "${default}" != 'b' ]] && [[ "${default}" != 'g' ]] && [[ "${default}" != 'l' ]]; then
            echo "Invalid linker configuration: ${default}"
            exit 1
          fi
        fi
        case "${default}" in
          b)
            new='ld.bfd'
            break;;
          g)
            new='ld.gold'
            break;;
          l)
            new='ld.lld'
            break;;
          0)
            exit;;
          *)
            echo 'Please select from one of the options or enter 0 to cancel.'
            echo
        esac
      done

      echo '#!/bin/bash' > ${mktmp}/ld
      echo "${new}"' --library-path #{CREW_LIB_PREFIX} -rpath #{CREW_LIB_PREFIX} "$@"' >> ${mktmp}/ld

      install -Dm755 ${mktmp}/ld #{CREW_PREFIX}/bin/ld

      rm -rf ${mktmp}
    EOF
  end

  def self.install
    FileUtils.install 'ld_default', "#{CREW_DEST_PREFIX}/bin/ld_default", mode: 0o755
  end

  def self.postinstall
    ExitMessage.add <<~EOM

      To change the default linker, execute `ld_default`.

      To change the default linker without any user interaction,
      execute `ld_default <letter>` where '<letter>' is b, g, or l
      for BFD, Gold, or LLD, respectively.

    EOM
  end
end
