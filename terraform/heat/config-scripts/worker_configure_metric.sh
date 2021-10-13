#!/bin/bash
echo "# RUNNING: $(dirname $0)/$(basename $0)"
set -e -o pipefail
libdir=/home/debian
[ -f ${libdir}/local.cfg ] && source ${libdir}/local.cfg
[ -f ${libdir}/config.cfg ] && source ${libdir}/config.cfg
[ -f ${libdir}/common_functions.sh ] && source ${libdir}/common_functions.sh
[ -f ${libdir}/app.cfg ] && source ${libdir}/app.cfg

# activation/desactivation metric metric_enable=true | false
if [ -z "$metric_enable" -o "$metric_enable" == "false" ] ; then
  echo "metric disable"
  exit 0
fi

cat <<'EOF' > /home/debian/configure-metric.sh
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

export METRIC_INSTALL_SCRIPT="$metric_install_script"

(
eval curl -kL -s ${METRIC_INSTALL_SCRIPT} | \
 bash
) || exit $?
EOF
chmod +x /home/debian/configure-metric.sh
su - debian -c "bash -c /home/debian/configure-metric.sh"
