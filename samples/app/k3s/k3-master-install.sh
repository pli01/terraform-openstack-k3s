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
#INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC --tls-san $K3S_CLUSTER_HOSTNAME"

if [ "$K3S_HA_CLUSTER" == "true" ] ;then
  echo "### K3S_HA_CLUSTER = $K3S_HA_CLUSTER"
  K3S_IS_MASTER="false"
  # Quick: detect master on hostname index
  case "$(hostname)" in
   *master-1-*) K3S_IS_MASTER="true" ;;
  esac
  if [ -n "$K3_IS_MASTER" == "true" ] ;then
    echo "### K3S_IS_MASTER = $K3S_IS_MASTER"
    INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC --cluster-init"
  else
    echo "### K3S_IS_NOT_MASTER"
    INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC --server https://$K3S_CLUSTER_HOSTNAME:6443"
    exit 0
  fi
fi

# in case of controle plane only without users workload
#INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC --node-taint CriticalAddonsOnly=true:NoExecute"

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
# optional install portainer agent (9001)
#
sudo -E kubectl create -f https://downloads.portainer.io/portainer-agent-ce29-k8s-lb.yaml --dry-run="client" -o json | \
   jq '.|(if .kind == "ServiceAccount" then . + {"imagePullSecrets": [{"name": "regcred"}]} else . end)'  | \
   jq '.|(if .kind == "Deployment" then .spec.template.spec.containers[0].imagePullPolicy = "IfNotPresent"  else . end)' | \
   jq '.|(if .kind == "Deployment" then .spec.template.spec.tolerations = [{"key":"CriticalAddonsOnly","operator":"Exists"},{"key":"node-role.kubernetes.io/master","operator":"Exists","effect":"NoSchedule"},{"key":"node-role.kubernetes.io/control-plane","operator":"Exists","effect":"NoSchedule"}] else . end)' | \
   sudo -E kubectl apply -f -

#
# install portainer with following specifications:
#   * use image pull secrets to download image from dockerhub auth registry
#   * download container if not present
#   * stick portainer to control-plane/master node only
#   * add http_proxy,no_proxy env variable (corporate proxy)
#
MASTER_IP=$(( /sbin/ip add show dev eth0 2>&- || /sbin/ifconfig eth0  2>&- || /sbin/ifconfig en0 2>&- ) | awk '{ print $2}' | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")

sudo -E kubectl create -f https://raw.githubusercontent.com/portainer/k8s/master/deploy/manifests/portainer/portainer-lb.yaml --dry-run="client" -o json | \
   jq '.|(if .kind == "ServiceAccount" then . + {"imagePullSecrets": [{"name": "regcred"}]} else . end)'  | \
   jq '.|(if .kind == "Deployment" then .spec.template.spec.containers[0].imagePullPolicy = "IfNotPresent"  else . end)' | \
   jq '.|(if .kind == "Deployment" then .spec.template.spec.tolerations = [{"key":"CriticalAddonsOnly","operator":"Exists"},{"key":"node-role.kubernetes.io/master","operator":"Exists","effect":"NoSchedule"},{"key":"node-role.kubernetes.io/control-plane","operator":"Exists","effect":"NoSchedule"}] else . end)' | \
   jq \
    --arg http_proxy "$http_proxy" \
    --arg https_proxy "$https_proxy" \
    --arg no_proxy "$no_proxy,kubernetes.default.svc,$MASTER_IP" \
   '.|(if .kind == "Deployment" then .spec.template.spec.containers[0].env = [{"name":"HTTP_PROXY","value":$http_proxy},{"name":"HTTPS_PROXY","value":$http_proxy},{"name":"NO_PROXY","value":$no_proxy}] else . end)' | \
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
