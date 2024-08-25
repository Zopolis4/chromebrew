#!/bin/bash -e
# This is for use as a Github CI Pull Request Unit Test.
set -e
echo "CHANGED_PACKAGES: ${CHANGED_PACKAGES}"
cd /usr/local/lib/crew/packages/
yes | crew update
yes | crew upgrade
git clone --depth=1 --branch="$CREW_BRANCH" "$CREW_REPO" ~/build_test
# crew wont let you build if you're in the installation directory.
(cd ~/build_test && yes | CREW_CACHE_ENABLED=1 crew build -vf ~/build_test/packages/hello_world_chromebrew.rb)
yes | crew install vim
yes | crew remove vim
ruby ../tests/commands/const.rb
ruby ../tests/commands/help.rb
ruby ../tests/commands/list.rb
ruby ../tests/commands/prop.rb
ruby ../tests/commands/remove.rb
ruby ../tests/lib/docopt.rb
if [[ -n ${CHANGED_PACKAGES-} ]]; then
  all_compatible_packages=$(crew list -d compatible)
  all_installed_packages=$(crew list -d installed)
  for pkg in ${CHANGED_PACKAGES}
    do
    # Only check packages compatible with the architecture being run on.
    if echo "${all_compatible_packages}" | grep "^${pkg}$"; then
      ruby ../tests/prop_test "${pkg}"
      ruby ../tests/buildsystem_test "${pkg}"
      if echo "${all_installed_packages}" | grep "^${pkg}$"; then
        echo "Testing reinstall of ${pkg}."
        yes | time crew reinstall "${pkg}"
      else
        echo "Testing install of ${pkg}."
        yes | time crew install "${pkg}"
      fi
      # Removal of essential packages is expected to fail.
      if [[ $(crew list -d essential) == *"${pkg}"* ]]; then
        echo "Testing removal of essential package ${pkg}."
        yes | time crew remove "${pkg}" || true
      else
        echo "Testing removal of ${pkg}."
        yes | time crew remove "${pkg}"
      fi
    else
      echo "${pkg^} is not compatible."
    fi
  done
fi