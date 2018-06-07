# !/bin/bash
set -e

source /etc/profile.d/gpfs_env.sh

echo "restore client into cluster ..."

mmsdrrestore -p host-10-50-9-111.openstacklocal

echo "show cluster info ..."

mmlscluster

echo "show license info ..."

mmlslicense -L

echo "start gpfs daemon and mount all ..."

mmstartup -a

hostname="host-10-50-9-114"
count=50

for ((i=$count; i>=1; i--))
do
    status=$(mmgetstate | grep ${hostname} | awk '{print $3}')
    echo "${hostname} status is $status ..."
    if [ "$status" == "active" ]; then
        break
    fi
    sleep 2s
done

if [ "$status" != "active" ]; then
    echo "gpfs node status is not active"
    exit 1
fi

mmgetstate -a

echo "check mount state ..."

mount
