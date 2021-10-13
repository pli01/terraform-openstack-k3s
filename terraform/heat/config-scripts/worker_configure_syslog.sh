#!/bin/bash
echo "# RUNNING: $(dirname $0)/$(basename $0)"
set -e -o pipefail

libdir=/home/debian
[ -f ${libdir}/local.cfg ] && source ${libdir}/local.cfg
[ -f ${libdir}/config.cfg ] && source ${libdir}/config.cfg
[ -f ${libdir}/common_functions.sh ] && source ${libdir}/common_functions.sh

echo "## configuration syslog"
apt-get -q update
apt-get -qy install jq

echo "# config journald.conf"
sed -i.back -e '/^ForwardToSyslog=.*/d; /^\[Journal\]/a\ForwardToSyslog=no' /etc/systemd/journald.conf
service systemd-journald restart

echo "# config /etc/rsyslog.conf"
sed -i.back  -e 's|^module(load="imuxsock".*|module(load="imuxsock" SysSock.Use="off" SysSock.Name="/run/systemd/journal/syslog")|g'  /etc/rsyslog.conf
echo "# config /etc/rsyslog.d"

cat <<'EOF' > /etc/rsyslog.d/01-journald-json.conf
# read journald, only last messages, and Burst to 100000 messages/10mn
module(load="imjournal" IgnorePreviousMessages="on" Ratelimit.Burst="100000")
# If the message contains json, parse it.
module(load="mmjsonparse")

# create structured json with selected fields
template(
  name="json_docker"
  type="list"
  option.casesensitive="on"
) {
    constant(value="{")
      constant(value="\"@timestamp\":\"")        property(name="timereported" dateFormat="rfc3339" date.inUTC="on")
      constant(value="\",\"@version\":\"1")
      constant(value="\",\"message\":\"")     property(name="$!MESSAGE" format="json")
      constant(value="\",\"hostname\":\"")    property(name="hostname")
      constant(value="\",\"severity\":\"")    property(name="syslogseverity-text")
      constant(value="\",\"facility\":\"")    property(name="syslogfacility-text")
      constant(value="\",\"programname\":\"") property(name="programname")
      constant(value="\",\"procid\":\"")      property(name="procid")
      constant(value="\",\"container_id\":\"")   property(name="$!CONTAINER_ID")
      constant(value="\",\"container_name\":\"") property(name="$!CONTAINER_NAME")
      constant(value="\",\"container_tag\":\"")  property(name="$!CONTAINER_TAG")
      constant(value="\"}\n")
#      constant(value="\",")                      property(name="$!json" position.from="2")
#    constant(value="\n")
}

action(type="mmjsonparse" cookie="" container="!json")
EOF

echo "# send to $syslog_relay"
if [ ! -z "$syslog_relay" ] ; then

  cat <<'EOF' | sed -e "s/\$syslog_relay/$syslog_relay/g" > /etc/rsyslog.d/99-forward-elk.conf
# log contains variable MESSAGE go in json format to elk asis
if ($!MESSAGE != "") then {
*.* @$syslog_relay:514;json_docker
}
EOF
fi
service rsyslog restart

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
  service docker restart
fi

echo "# config logrotate"
cp /etc/cron.daily/logrotate /etc/cron.hourly/logrotate
cat <<EOF > /etc/logrotate.d/rsyslog
# Local modifications will be overwritten.
/var/log/mail.info /var/log/mail.warn /var/log/mail.err /var/log/mail.log /var/log/daemon.log /var/log/kern.log /var/log/auth.log /var/log/user.log /var/log/lpr.log /var/log/cron.log /var/log/debug /var/log/messages {
  rotate 4
  hourly
  size 10M
  missingok
  notifempty
  compress
  delaycompress
  sharedscripts
  postrotate
    invoke-rc.d rsyslog rotate > /dev/null
  endscript
}
EOF

cat <<EOF > /etc/logrotate.d/syslog
# Local modifications will be overwritten.
/var/log/syslog {
  rotate 7
  hourly
  size 10M
  missingok
  notifempty
  compress
  delaycompress
  postrotate
    invoke-rc.d rsyslog rotate > /dev/null
  endscript
}
EOF
