#!/bin/bash
set -ex
trap "exit 1" TERM

#MODE=$1
#PLATFORM=$2
#STORM_REPO=$3
STORAGE_ROOT_DIR=$4
HOSTNAME=$5

MODE="clean"
#MODE="${MODE:-"clean"}"
PLATFORM="${PLATFORM:-"centos6"}"

if [ -z "$STORAGE_ROOT_DIR" ]; then
  echo "Need to set STORAGE_ROOT_DIR"
  exit 1
fi

if [ -z "$HOSTNAME" ]; then
  echo "Need to set HOSTNAME"
  exit 1
fi

UMD_RELEASE_RPM="${UMD_RELEASE_RPM:-"http://repository.egi.eu/sw/production/umd/4/sl6/x86_64/updates/umd-release-4.1.3-1.el6.noarch.rpm"}"

echo "Setting FQDN hostname as ${HOSTNAME} ..."
hostname ${HOSTNAME}

echo "Create storage root directory ${STORAGE_ROOT_DIR} ..."
mkdir -p ${STORAGE_ROOT_DIR}

echo "Inject storage root directory into configuration ..."

sed -i '/^STORM_DEFAULT_ROOT/d' data/siteinfo/clean/storm.def
echo "STORM_DEFAULT_ROOT=${STORAGE_ROOT_DIR}" >> data/siteinfo/clean/storm.def

sed -i '/^STORM_DEFAULT_ROOT/d' data/siteinfo/update/storm.def
echo "STORM_DEFAULT_ROOT=${STORAGE_ROOT_DIR}" >> data/siteinfo/update/storm.def

echo "Running ${MODE} deployment for ${PLATFORM} with ..."
echo "UMD_RELEASE_RPM: ${UMD_RELEASE_RPM}"
echo "STORAGE_ROOT_DIR: ${STORAGE_ROOT_DIR}"
echo "HOSTNAME: ${HOSTNAME}"

UMD_RELEASE_RPM="${UMD_RELEASE_RPM}" \
STORAGE_ROOT_DIR="${STORAGE_ROOT_DIR}" \
HOSTNAME="${HOSTNAME}" \
sh scripts/run-${MODE}-${PLATFORM}.sh
