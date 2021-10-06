#!/bin/bash
set -e

TG_RELEASE_URL=https://api.github.com/repos/gruntwork-io/terragrunt/releases
BIN_REQ="curl jq grep egrep"
for bin in ${BIN_REQ} ; do
  type -p $bin >/dev/null || { echo "$bin not found" ; exit 1 ; }
done

case $(uname -sm | tr '[:upper:]' '[:lower:]') in
  linux*64)
    OS=linux
    ARCH=amd64
    ;;
  linux*)
    OS=linux
    ARCH=386
    ;;
  darwin*64)
    OS=darwin
    ARCH=amd64
    ;;
  *)
    echo "Unknown"; exit 1
    ;;
esac

TERRAGRUNT_VERSION=${1:-latest}
tg_get_version="$TERRAGRUNT_VERSION" ;
case $TERRAGRUNT_VERSION in
   latest) tg_get_version='*' ;;
esac
echo "# find terragrunt $TERRAGRUNT_VERSION $OS $ARCH from $TG_RELEASE_URL"
TERRAGRUNT_PACKAGE=$( curl -sL ${TG_RELEASE_URL} | \
  jq -r '.[].assets[].browser_download_url' | \
  egrep "v${tg_get_version}/terragrunt_${OS}_${ARCH}" | head -1)
if [ -z "$TERRAGRUNT_PACKAGE" ] ; then
 echo "Error to fetch terraform $TERRAGRUNT_VERSION $OS $ARCH"
 exit 1
else
  echo "# fetch ${TERRAGRUNT_PACKAGE}"
  tgname=$(basename ${TERRAGRUNT_PACKAGE})-$(basename $(dirname $TERRAGRUNT_PACKAGE))
  mkdir -p bin
  ( cd bin &&
  curl -s -L -o $tgname ${TERRAGRUNT_PACKAGE} && \
    ln -sf $tgname terragrunt && \
    chmod +x $tgname
  ) || exit 1
  bin/terragrunt -v || exit 1
  exit 0
fi
