#!/bin/bash
#set -e
set -x

mkdir k3s
( cd k3s
curl -LO https://raw.githubusercontent.com/k3s-io/k3s/master/docker-compose.yml
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
export K3S_TOKEN="$(uname -a | base64)"
docker-compose up -d

export KUBECONFIG=$(pwd)/kubeconfig.yaml

DEFAULT_TIMEOUT=${DEFAULT_TIMEOUT:-1200}

test_result=1
timeout=$DEFAULT_TIMEOUT
until [ "$timeout" -le 0 -o "$test_result" -eq "0" ] ; do
  ( ./kubectl get node -A  )
  test_result=$?
  if [ "$test_result" -gt 0 ] ;then
     echo "Retry $timeout seconds: $test_result";
     (( timeout-- ))
     sleep 1
  fi
done

if [ "$test_result" -gt 0 ] ;then
        test_status=ERROR
        echo "$test_status: curl https://get.k3s.io $test_result"
        exit $test_result
fi
)

exit 0
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


