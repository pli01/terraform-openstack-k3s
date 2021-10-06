#!/bin/bash
echo "# RUNNING: $(dirname $0)/$(basename $0)"
set -e -o pipefail
libdir=/home/debian
[ -f ${libdir}/local.cfg ] && source ${libdir}/local.cfg
[ -f ${libdir}/config.cfg ] && source ${libdir}/config.cfg
[ -f ${libdir}/common_functions.sh ] && source ${libdir}/common_functions.sh
[ -f ${libdir}/lb.cfg ] && source ${libdir}/lb.cfg

echo "## generate os_config"
mkdir -p /DATA
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

echo "## lb configuration"
cat <<'EOF' > /home/debian/deploy-lb.sh
#!/bin/bash
set -e -o pipefail
libdir=/home/debian
[ -f ${libdir}/local.cfg ] && source ${libdir}/local.cfg
[ -f ${libdir}/config.cfg ] && source ${libdir}/config.cfg
[ -f ${libdir}/lb.cfg ] && source ${libdir}/lb.cfg

cd /home/debian
export no_proxy=$no_proxy
export http_proxy=$internal_http_proxy
export https_proxy=$internal_http_proxy

export DOCKERHUB_LOGIN="$dockerhub_login"
export DOCKERHUB_TOKEN="$dockerhub_token"

export GITHUB_TOKEN="$github_token"
export DOCKER_REGISTRY_USERNAME="$docker_registry_username"
export DOCKER_REGISTRY_TOKEN="$docker_registry_token"
export LB_INSTALL_SCRIPT="$lb_install_script"

# if authenticated repo
if [ -n "${GITHUB_TOKEN}" ] ; then
  curl_args=" -H \"Authorization: token ${GITHUB_TOKEN}\" "
fi

if [ -z "${LB_INSTALL_SCRIPT}" ] ; then
 echo "# NOTHING TO deploy!"
 exit 0
fi
(
eval curl -kL -s $curl_args ${LB_INSTALL_SCRIPT} | \
 bash
) || exit $?
EOF
echo "# run /home/debian/deploy-lb.sh"
chmod +x /home/debian/deploy-lb.sh
su - debian -c "bash -c /home/debian/deploy-lb.sh"

echo "## End post installation"
