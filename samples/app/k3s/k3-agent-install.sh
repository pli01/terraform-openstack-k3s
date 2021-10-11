#!/bin/bash
set -x

# insecure curl
echo "-k" >> ~/.curlrc

[ -n "${DOCKER_TOKEN}" -a -n "${DOCKER_LOGIN}" ] && echo "${DOCKER_TOKEN}" | docker login -u ${DOCKER_LOGIN}  --password-stdin

# k3s configuration
if [ -z "$K3S_TOKEN" ] ;then
  K3S_TOKEN=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 108  | head -n 1)
fi
INSTALL_K3S_EXEC="agent"
INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC --docker"
# in case of controle plane only without users workload
# INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC --node-taint CriticalAddonsOnly=true:NoExecute"

#
# download and install k3s
#
DEFAULT_TIMEOUT=${DEFAULT_TIMEOUT:-1200}

test_result=1
timeout=$DEFAULT_TIMEOUT
until [ "$timeout" -le 0 -o "$test_result" -eq "0" ] ; do
  ( curl -skfL https://get.k3s.io | INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC" K3S_TOKEN="$K3S_TOKEN" K3S_URL="$K3S_URL" bash - )
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

exit 0
