#!/bin/bash
echo "# RUNNING: $(dirname $0)/$(basename $0)"
set -e -o pipefail
libdir=/home/debian
[ -f ${libdir}/local.cfg ] && source ${libdir}/local.cfg
[ -f ${libdir}/config.cfg ] && source ${libdir}/config.cfg
[ -f ${libdir}/common_functions.sh ] && source ${libdir}/common_functions.sh

echo "## http-proxy configuration"
export no_proxy=$no_proxy
export tinyproxy_upstream=$tinyproxy_upstream
export tinyproxy_proxy_authorization=$tinyproxy_proxy_authorization

echo "## installation des pre-requis"
apt-get -q update
apt-get -qy install curl jq tinyproxy

# config
cp /etc/tinyproxy/tinyproxy.conf /etc/tinyproxy/tinyproxy.conf.orig
cat <<EOF > /etc/tinyproxy/tinyproxy.conf
User tinyproxy
Group tinyproxy
Port 8888
Timeout 600
DefaultErrorFile "/usr/share/tinyproxy/default.html"
StatFile "/usr/share/tinyproxy/stats.html"
Logfile "/var/log/tinyproxy/tinyproxy.log"
LogLevel Info
PidFile "/run/tinyproxy/tinyproxy.pid"
MaxClients 100
MinSpareServers 5
MaxSpareServers 20
StartServers 10
MaxRequestsPerChild 0
ViaProxyName "tinyproxy"
ConnectPort 443
ConnectPort 563
# upstream proxy support start
$( [ -z "${tinyproxy_upstream}" ] && echo "# disable upstream" || { IFS=','
   for line in ${tinyproxy_upstream} ; do
      unset string start end
      eval string=$line
      start="${string[0]} ${string[1]}"
      [ -n "${string[2]}" ] && end=" \"${string[2]}\""
      echo "$start$end"
   done
 }
)
# upstream proxy support end
$( [ -z "${tinyproxy_proxy_authorization}" ] && echo "# Proxy-Autorization disable" || echo "AddHeader \"Proxy-Authorization\" \"Basic ${tinyproxy_proxy_authorization}\"" )
Allow 127.0.0.1
$(ip add |grep "inet " |awk ' { print "Allow",$2 } ')
EOF
service tinyproxy restart

# logrotate
sed -i -e 's/daily/hourly/g;' \
    -e 's/reload/restart/g' \
    -e '/compress/a\
        size 20M' \
        /etc/logrotate.d/tinyproxy

echo "## End post installation"
