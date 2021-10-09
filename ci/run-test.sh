#!/bin/bash
set -e

export PROJECT=examples
export TF_IN_AUTOMATION=true
TERRAFORM_VERSION="latest"
echo "# build cli/terraform $TERRAFORM_VERSION"
make install-tf
./bin/terraform version

echo "# build docker cli/terraform $TERRAFORM_VERSION"
make build
make tf-version

echo "# validate terraform module"
make tf-validate PROJECT="examples"
