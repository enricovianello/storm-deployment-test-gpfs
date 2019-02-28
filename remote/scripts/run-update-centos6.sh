#!/bin/bash
trap "exit 1" TERM
set -ex

COMMON_PATH="./scripts/common"

hostname ${HOSTNAME}
hostname -f

echo "Install UMD repositories ..."
sh ${COMMON_PATH}/install-umd-repos.sh ${UMD_RELEASE_RPM}

echo "Add storm user if not exists ..."
id -u storm &>/dev/null || adduser -r storm

echo "Install StoRM packages ..."
yum clean all
yum install -y emi-storm-backend-mp emi-storm-frontend-mp emi-storm-globus-gridftp-mp storm-webdav

echo "Install GPFS native libs ..."
yum install -y storm-native-libs-gpfs

echo "Install configuration ..."
sh ${COMMON_PATH}/install-yaim-configuration.sh "$(pwd)/data/siteinfo/clean"

echo "Lauch YAIM ..."
/opt/glite/yaim/bin/yaim -c -s /etc/storm/siteinfo/storm.def -n se_storm_backend -n se_storm_frontend -n se_storm_gridftp -n se_storm_webdav

echo "Install stable StoRM repo ..."
wget https://repo.cloud.cnaf.infn.it/repository/storm/stable/storm-stable-centos6.repo -O /etc/yum.repos.d/storm-stable.repo

echo "Update all packages ..."
yum clean all
yum update -y

if [ $? != 0 ]; then
    echo "Problem occurred while updating the system!"
    exit 1
fi

sh ${COMMON_PATH}/post-update.sh

echo "Update configuration ..."
sh ${COMMON_PATH}/install-yaim-configuration.sh "$(pwd)/data/siteinfo/update"

echo "Run YAIM ..."
/opt/glite/yaim/bin/yaim -c -s /etc/storm/siteinfo/storm.def -n se_storm_backend -n se_storm_frontend -n se_storm_gridftp -n se_storm_webdav

echo "Run post-installation config script ..."
sh ${COMMON_PATH}/post-config-setup.sh "$(pwd)/data/siteinfo/update" ${STORAGE_ROOT_DIR}
