#!/bin/bash
set -ex

MODE=$1
PLATFORM=$2
STORAGE_ROOT_DIR=$3
HOSTNAME=$4

REPOSITORY="${REPOSITORY:-"https://github.com/italiangrid/storm-deployment-test.git"}"
BRANCH="${BRANCH:-"gpfs"}"
MODE="${MODE:-"clean"}"
PLATFORM="${PLATFORM:-"centos6"}"

if [ -z "$STORAGE_ROOT_DIR" ]; then
    echo "Need to set STORAGE_ROOT_DIR"
    exit 1
fi

if [ -z "$HOSTNAME" ]; then
    echo "Need to set HOSTNAME"
    exit 1
fi

echo "Cloning ${REPOSITORY} ..."
git clone ${REPOSITORY} --branch ${BRANCH}

pushd storm-deployment-test

STORAGE_ROOT_DIR=${STORAGE_ROOT_DIR} \
HOSTNAME=${HOSTNAME} \
MODE=${MODE} \
PLATFORM=${PLATFORM} \
sh run.sh

popd
