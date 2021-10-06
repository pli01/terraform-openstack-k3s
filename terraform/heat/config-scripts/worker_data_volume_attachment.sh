#!/bin/bash
echo "# RUNNING: $(dirname $0)/$(basename $0)"
set -e -o pipefail

libdir=/home/debian
[ -f ${libdir}/local.cfg ] && source ${libdir}/local.cfg
[ -f ${libdir}/config.cfg ] && source ${libdir}/config.cfg
[ -f ${libdir}/common_functions.sh ] && source ${libdir}/common_functions.sh

volume_id="$volume_id"
if [ -z "${volume_id}" ] ; then
 echo "SKIP: $(basename $0) No volume id detected"
 exit 0
fi
volume_dev="/dev/disk/by-id/virtio-$(echo ${volume_id} | cut -c -20)"

echo "# Wait ${volume_dev} up"
set +e
ret=0
timeout=120;
test_result=1
until [ "$timeout" -le 0 -o "$test_result" -eq "0" ] ; do
        ( ls -L $volume_dev 2>&-)
        test_result=$?
        echo "Wait $timeout seconds: ${volume_dev} up $test_result";
        (( timeout-- ))
        sleep 1
done
if [ "$test_result" -gt "0" ] ; then
        ret=$test_result
        echo "ERROR: ${volume_dev} en erreur"
        exit $ret
fi

if ! /sbin/blkid -t TYPE=ext4 "${volume_dev}" ; then
  mkfs.ext4 ${volume_dev}
fi

mkdir -pv /DATA
#echo "${volume_dev} /DATA ext4 defaults 1 2" >> /etc/fstab
# disable accesstime update, enable data=ordered
echo "${volume_dev} /DATA ext4 rw,noatime,data=ordered 1 2" >> /etc/fstab
mount /DATA

# creation esdata
mkdir -p /DATA/app
chown -R debian.root /DATA/app
