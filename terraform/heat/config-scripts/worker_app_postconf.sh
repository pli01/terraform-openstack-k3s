#!/bin/bash
echo "# RUNNING: $(dirname $0)/$(basename $0)"
set -e -o pipefail
libdir=/home/debian
[ -f ${libdir}/local.cfg ] && source ${libdir}/local.cfg
[ -f ${libdir}/config.cfg ] && source ${libdir}/config.cfg
[ -f ${libdir}/common_functions.sh ] && source ${libdir}/common_functions.sh
[ -f ${libdir}/app.cfg ] && source ${libdir}/app.cfg

echo "## app configuration"
cat <<'EOF' > /home/debian/deploy-app.sh
#!/bin/bash
set -e -o pipefail
libdir=/home/debian
[ -f ${libdir}/local.cfg ] && source ${libdir}/local.cfg
[ -f ${libdir}/config.cfg ] && source ${libdir}/config.cfg
[ -f ${libdir}/app.cfg ] && source ${libdir}/app.cfg

cd /home/debian
export no_proxy=$no_proxy
export http_proxy=$internal_http_proxy
export https_proxy=$internal_http_proxy

export DOCKERHUB_LOGIN="$dockerhub_login"
export DOCKERHUB_TOKEN="$dockerhub_token"

export GITHUB_TOKEN="$github_token"
export DOCKER_REGISTRY_USERNAME="$docker_registry_username"
export DOCKER_REGISTRY_TOKEN="$docker_registry_token"
export APP_INSTALL_SCRIPT="$app_install_script"

# if authenticated repo
if [ -n "${GITHUB_TOKEN}" ] ; then
  curl_args=" -H \"Authorization: token ${GITHUB_TOKEN}\" "
fi

(
eval curl -kL -s $curl_args ${APP_INSTALL_SCRIPT} | \
 bash
) || exit $?
EOF
echo "# run /home/debian/deploy-app.sh"
chmod +x /home/debian/deploy-app.sh
su - debian -c "bash -c /home/debian/deploy-app.sh"

echo "## End post installation"
