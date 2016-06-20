#!/bin/bash -e

# This script is a thin wrapper around `lsstswBuild.sh` and is only intended to
# be useful when executed by jenkins.  It assumes that the `lsst/lsstsw` and
# `lsst-sqre/buildbot-script` repos have already been cloned into the jenkins
# `$WORKSPACE`.

ARGS=()

# append lsst_ci to PRODUCT list unless SKIP_DEMO is set
if [[ $SKIP_DEMO != "true" ]]; then
  if [[ -z "$PRODUCT" ]]; then
    # lsstsw default targets
    PRODUCT="lsst_sims lsst_distrib qserv_distrib dax_webserv"
  fi
  PRODUCT="$PRODUCT lsst_ci"
fi

if [[ ! -z "$BRANCH" ]]; then
  ARGS+=('--branch')
  ARGS+=("$BRANCH")
fi

ARGS+=('--build_number')
ARGS+=("$BUILD_NUMBER")

if [[ ! -z "$PRODUCT" ]]; then
  ARGS+=('--product')
  ARGS+=("$PRODUCT")
fi

ARGS+=('--skip_docs')
ARGS+=('--print-fail')
ARGS+=('--color')

if [[ $SKIP_DEMO == "true" ]]; then
  ARGS+=('--skip_demo')
fi

if [[ $NO_FETCH == "true" ]]; then
  ARGS+=('--no-fetch')
fi

set -o verbose
if grep -q -i "CentOS release 6" /etc/redhat-release; then
  . /opt/rh/devtoolset-3/enable
fi
set +o verbose

export LSSTSW=${LSSTSW:-$WORKSPACE/lsstsw}

(
  cd "$LSSTSW"

  OPTS=()

  if [[ $python == "py3" ]]; then
    OPTS+=('-3')
  fi

  if [[ $pkgset == "sims" ]]; then
    OPTS+=('-s')
  fi

  ./bin/deploy "${OPTS[@]}"
)

"${WORKSPACE}/buildbot-scripts/lsstswBuild.sh" "${ARGS[@]}"
