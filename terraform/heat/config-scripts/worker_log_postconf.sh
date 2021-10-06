#!/bin/bash
echo "# RUNNING: $(dirname $0)/$(basename $0)"
#set -x
set -e -o pipefail
libdir=/home/debian
[ -f ${libdir}/local.cfg ] && source ${libdir}/local.cfg
[ -f ${libdir}/config.cfg ] && source ${libdir}/config.cfg
[ -f ${libdir}/common_functions.sh ] && source ${libdir}/common_functions.sh
[ -f ${libdir}/log.cfg ] && source ${libdir}/log.cfg

cd /home/debian
echo "# DATA elasticsearch"
[ -d "/DATA/esdata" ] || mkdir -p /DATA/esdata
chown -R debian.root /DATA/esdata

echo "# DATA logs"
[ -d "/DATA/logs" ] || mkdir -p /DATA/logs
chown -R debian.root /DATA/logs

echo "## generate os_config"
cat <<EOF > /DATA/.openrc.sh
OS_AUTH_URL=$OS_AUTH_URL
OS_REGION_NAME=$OS_REGION_NAME
OS_USER_DOMAIN_NAME=$OS_USER_DOMAIN_NAME
OS_PROJECT_NAME=$OS_PROJECT_NAME
OS_USERNAME=$OS_USERNAME
OS_PASSWORD=$OS_PASSWORD
OS_PROJECT_DOMAIN_NAME=$OS_PROJECT_DOMAIN_NAME
OS_IDENTITY_API_VERSION=$OS_IDENTITY_API_VERSION
OS_CACERT=$OS_CACERT
OS_INTERFACE=$OS_INTERFACE
export OS_PROJECT_DOMAIN_NAME OS_INTERFACE OS_CACERT OS_USERNAME OS_AUTH_URL OS_PASSWORD OS_IDENTITY_API_VERSION OS_PROJECT_NAME OS_USER_DOMAIN_NAME OS_REGION_NAME
EOF
chown debian. /DATA/.openrc.sh
chmod 600 /DATA/.openrc.sh

echo "## log configuration"
cat <<'EOF' > /home/debian/deploy-logs.sh
#!/bin/bash
#set -x
set -e -o pipefail
libdir=/home/debian
[ -f ${libdir}/local.cfg ] && source ${libdir}/local.cfg
[ -f ${libdir}/config.cfg ] && source ${libdir}/config.cfg
[ -f ${libdir}/log.cfg ] && source ${libdir}/log.cfg

cd /home/debian
export no_proxy=$no_proxy
export http_proxy=$internal_http_proxy
export https_proxy=$internal_http_proxy

export DOCKERHUB_LOGIN="$dockerhub_login"
export DOCKERHUB_TOKEN="$dockerhub_token"

export GITHUB_TOKEN="$github_token"
export DOCKER_REGISTRY_USERNAME="$docker_registry_username"
export DOCKER_REGISTRY_TOKEN="$docker_registry_token"
export LOG_INSTALL_SCRIPT="$log_install_script"

echo "## generate kibana access list"
# get local ip and add to kibana access list
host_ip=$(ip add |awk ' /inet.*eth0$/ { print $2 } ' | awk -F/ ' { print $1 }')
[ -z "$host_ip" ] && host_ip=127.0.0.1

[ -z "${KIBANA_ACCESS_LIST}" ] && KIBANA_ACCESS_LIST='["all"]'
export KIBANA_ACCESS_LIST="${KIBANA_ACCESS_LIST}[\"$host_ip\"]"

export ES_MEM=$((( $( cat /proc/meminfo | grep MemTotal | awk '{ print $2 }' ) * 46 ) / 100 ))K

# if authenticated repo
if [ -n "${GITHUB_TOKEN}" ] ; then
  curl_args=" -H \"Authorization: token ${GITHUB_TOKEN}\" "
fi

(
eval curl -kL -s $curl_args ${LOG_INSTALL_SCRIPT} | \
 bash
) || exit $?
EOF
echo "# run /home/debian/deploy-logs.sh"
chmod +x /home/debian/deploy-logs.sh
su - debian -c "bash -c /home/debian/deploy-logs.sh"

echo "## End post installation"
