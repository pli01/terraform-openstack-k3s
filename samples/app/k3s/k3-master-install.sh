#!/bin/bash
set -x
# insecure curl
echo "-k" >> ~/.curlrc

[ -n "${DOCKER_TOKEN}" -a -n "${DOCKER_LOGIN}" ] && echo "${DOCKER_TOKEN}" | docker login -u ${DOCKER_LOGIN}  --password-stdin

# k3s configuration
if [ -z "$K3S_TOKEN" ] ;then
  K3S_TOKEN=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 108  | head -n 1)
fi
INSTALL_K3S_EXEC="server"
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
  ( curl -skfL https://get.k3s.io | INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC" K3S_TOKEN="$K3S_TOKEN" bash - )
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

#
# wait k3s ready
#
test_result=1
timeout=$DEFAULT_TIMEOUT

until [ "$timeout" -le 0 -o "$test_result" -eq "0" ] ; do
 (sudo -E kubectl get node -A)
 test_result=$?
 if [ "$test_result" -gt 0 ] ;then
     echo "Retry $timeout seconds: $test_result";
     (( timeout-- ))
     sleep 1
 fi
done
if [ "$test_result" -gt 0 ] ;then
        test_status=ERROR
        echo "$test_status: k3s not ready $test_result"
        exit $test_result
fi


#
# wait traefik deployment ready
#
test_result=1
timeout=$DEFAULT_TIMEOUT

until [ "$timeout" -le 0 -o "$test_result" -eq "0" ] ; do
 (sudo -E kubectl rollout status  deployment/traefik -n kube-system -w  --timeout=${DEFAULT_TIMEOUT}s)
 test_result=$?
 if [ "$test_result" -gt 0 ] ;then
     echo "Retry $timeout seconds: $test_result";
     (( timeout-- ))
     sleep 1
 fi
done
if [ "$test_result" -gt 0 ] ;then
        test_status=ERROR
        echo "$test_status: traefik not ready $test_result"
        exit $test_result
fi


#
# add dockerhub credentials
#
if [ -n "$DOCKERHUB_LOGIN" -a -n "$DOCKERHUB_TOKEN" ] ; then
  sudo -E kubectl create secret docker-registry regcred \
     --docker-server=https://index.docker.io/v1/ \
     --docker-username=$DOCKERHUB_LOGIN \
     --docker-password=$DOCKERHUB_TOKEN
#
# Automatically add imagePullSecrets to default ServiceAccount
#
  sudo -E kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "regcred"}]}'
fi

#
# add portainer on /portainer path
#
# Hack: skip tls verify backend in traefik
cat <<EOF | sudo -E kubectl create -f -
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    globalArguments:
    - "--serversTransport.insecureSkipVerify=true"
EOF
sudo -E kubectl rollout status  deployment/traefik -n kube-system -w  --timeout=${DEFAULT_TIMEOUT}s

#
# install portainer with following specifications:
#   use image pull secrets to download image from dockerhub auth registry
#   download container if not present
#   stick portainer on control-plane/master node only
#
sudo -E kubectl create -f https://raw.githubusercontent.com/portainer/k8s/master/deploy/manifests/portainer/portainer-lb.yaml --dry-run="client" -o json | \
   jq '.|(if .kind == "ServiceAccount" then . + {"imagePullSecrets": [{"name": "regcred"}]} else . end)'  | \
   jq '.|(if .kind == "Deployment" then .spec.template.spec.containers[0].imagePullPolicy = "IfNotPresent"  else . end)' | \
   jq '.|(if .kind == "Deployment" then .spec.template.spec.tolerations = [{"key":"CriticalAddonsOnly","operator":"Exists"},{"key":"node-role.kubernetes.io/master","operator":"Exists","effect":"NoSchedule"},{"key":"node-role.kubernetes.io/control-plane","operator":"Exists","effect":"NoSchedule"}] else . end)' | \
   sudo -E kubectl apply -f -

test_result=1
timeout=$DEFAULT_TIMEOUT
until [ "$timeout" -le 0 -o "$test_result" -eq "0" ] ; do
 ( sudo -E kubectl rollout status  deployment/portainer -n portainer -w  --timeout=${DEFAULT_TIMEOUT}s )
 test_result=$?
 if [ "$test_result" -gt 0 ] ;then
     echo "Retry $timeout seconds: $test_result";
     (( timeout-- ))
     sleep 1
 fi
done
if [ "$test_result" -gt 0 ] ;then
        test_status=ERROR
        echo "$test_status: portainer not ready $test_result"
        exit $test_result
fi

#
# install ingressroute for portainer
#
sudo -E kubectl create -f https://raw.githubusercontent.com/pli01/terraform-openstack-k3s/main/samples/app/k3s/kubernetes-portainer-ingressroute.yml
exit
