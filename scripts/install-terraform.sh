#!/bin/bash
set -e

TF_URL="https://releases.hashicorp.com/terraform/index.json"
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

TERRAFORM_VERSION=${1:-latest}
tf_get_version="$TERRAFORM_VERSION" ;
case $TERRAFORM_VERSION in
   latest) tf_get_version='*' ;;
esac
echo "# find terraform $TERRAFORM_VERSION $OS $ARCH from $TF_URL"
TERRAFORM_PACKAGE=$(curl -sL ${TF_URL} | \
  jq -r '.versions[].builds[].url' | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | \
  egrep -v 'rc|beta|alpha' |grep "_${tf_get_version}_${OS}_${ARCH}" | tail -1)
if [ -z "$TERRAFORM_PACKAGE" ] ; then
 echo "Error to fetch terraform $TERRAFORM_VERSION $OS $ARCH"
 exit 1
else
  echo "# fetch ${TERRAFORM_PACKAGE}"
  zip=$(basename ${TERRAFORM_PACKAGE})
  tfname=$(basename ${TERRAFORM_PACKAGE} _${OS}_${ARCH}.zip)
  mkdir -p bin
  ( cd bin &&
  curl -s -O ${TERRAFORM_PACKAGE} \
    && unzip -p "$zip" > $tfname \
    && rm -rf "$zip"
    ln -sf $tfname terraform
    chmod +x $tfname
  ) || exit 1
  bin/terraform version || exit 1
  exit 0
fi
