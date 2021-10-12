#!/bin/bash
echo "# RUNNING: $(dirname $0)/$(basename $0)"
set -e -o pipefail
libdir=/home/debian
[ -f ${libdir}/local.cfg ] && source ${libdir}/local.cfg
[ -f ${libdir}/config.cfg ] && source ${libdir}/config.cfg
[ -f ${libdir}/common_functions.sh ] && source ${libdir}/common_functions.sh

echo "## docker configuration"

export no_proxy=$no_proxy
export http_proxy=$internal_http_proxy
export dns_nameservers=${dns_nameservers}
export dns_domainname=${dns_domainname}
export nexus_server=${nexus_server}
export mirror_docker="${mirror_docker:-https://download.docker.com/linux/debian}"
export mirror_docker_key="${mirror_docker_key:-https://download.docker.com/linux/debian/gpg}"
export docker_version="${docker_version:-docker-ce=5:19.03.11~3-0~debian-stretch}"
export docker_compose_version="${docker_compose_version:-1.21.2}"

echo "## vm max_map_count"
sysctl -w vm.max_map_count=262144

echo "## config apt with private proxy"
cat > /etc/apt/apt.conf.d/01proxy << EOF
Acquire::http::Proxy "$http_proxy";
Acquire::https::Proxy "$http_proxy";
EOF

echo "## installation des pre-requis"
apt-get update -q
PACKAGE_CUSTOM="sudo curl libapparmor1 libltdl7 apt-transport-https ca-certificates curl software-properties-common jq gnupg2 make git unzip python-pip python-dev python-openstackclient python-heatclient python-wheel"
apt-get -q update && apt-get install -qy --no-install-recommends $PACKAGE_CUSTOM

echo "## Installation et configuration de docker-ce"

echo "## hack group docker/LDAP"
type -p nslcd && service nslcd stop
type -p nscd && service nscd stop

echo "## installation docker"
MIRROR_DOCKER="$mirror_docker"
MIRROR_DOCKER_KEY="$mirror_docker_key"

curl -fsSL $MIRROR_DOCKER_KEY | apt-key add -
add-apt-repository \
     "deb [arch=amd64] $MIRROR_DOCKER \
     $(lsb_release -cs) \
     stable"
apt-get update -q
apt-get install -qy $docker_version

echo "## ajout debian au groupe docker"
usermod -aG docker debian

systemctl daemon-reload
systemctl restart docker

echo "## hack groupe docker/LDAP"
type -p nslcd && service nslcd start
type -p nscd && service nscd start
type -p nscd && nscd -i group

echo "## Installation de docker-compose"
# install python requirements

export REGISTRY_URL=$nexus_server
export PYPI_URL=https://${REGISTRY_URL}/repository/pypi-proxy/simple
export PYPI_HOST=${REGISTRY_URL}
export REGISTRY_URL PYPI_URL PYPI_HOST

set -e && [ -z "$PYPI_URL" ] || pip_args=" --index-url $PYPI_URL " ; \
  [ -z "$PYPI_HOST" ] || pip_args="$pip_args --trusted-host $PYPI_HOST " ; \
  echo "$no_proxy" |tr ',' '\n' | sort -u |grep "^$PYPI_HOST$" || \
  [ -z "$http_proxy" ] || pip_args="$pip_args --proxy $http_proxy "

# install docker-compose
cat <<EOF > /root/requirements.txt
ansible-lint==3.3.3
python-openstackclient==3.14.2
yamllint==1.12.1
# explicit depencies for yamllint
pathspec>=0.5.3
EOF
pip install $pip_args -I --no-deps -r /root/requirements.txt

pip install $pip_args "docker-compose==$docker_compose_version"

# post conf
# config docker proxy

#docker_data_root="/DATA/docker"
docker_data_root="${docker_data_root:-/DATA/docker}"
if [ -n "${docker_data_root}" ] ; then
 mkdir -p "${docker_data_root}"
fi

cat <<EOF > /etc/docker/daemon.json
{
    "data-root": "$docker_data_root",
    "dns": ${dns_nameservers},
    "dns-search": ${dns_domainname},
    "insecure-registries": [
        "localhost.local",
        "${nexus_server}"
    ],
    "registry-mirrors": [
        "https://${nexus_server}"
    ],
    "log-driver": "journald",
    "mtu": 1450
}
EOF

# config docker http proxy
mkdir -p /etc/systemd/system/docker.service.d/
cat <<EOF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=${http_proxy}"
Environment="HTTPS_PROXY=${http_proxy}"
Environment="NO_PROXY=localhost,127.0.0.1,${no_proxy}"
EOF

echo "# config /etc/docker/daemon.json"
if [ -d /etc/docker ] ;then
  docker_daemon_conf='{}'
  if [ -f /etc/docker/daemon.json ] ; then
   cat /etc/docker/daemon.json > /etc/docker/daemon.json.orig
   docker_daemon_conf="$(cat /etc/docker/daemon.json)"
  fi
  if [ ! -z "$docker_daemon_conf" ] ; then
  echo "$docker_daemon_conf" | \
    jq --arg driver journald '. + { "log-driver": $driver }' > /etc/docker/daemon.json
  fi
  systemctl daemon-reload
  service docker restart
fi

echo "## Post check"
docker version || exit $?
docker-compose  version || exit $?
id debian  | grep '(docker)' || exit $?
echo "## End post installation"
