#!/bin/bash
set -ex

MODE=$1
PLATFORM=$2
STORM_REPO=$3
STORAGE_ROOT_DIR=$4
HOSTNAME=$5

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

if [ -z "$STORM_REPO" ]; then
    echo "Need to set STORM_REPO"
    exit 1
fi

echo "Cloning ${REPOSITORY} ..."
git clone ${REPOSITORY} --branch ${BRANCH}

pushd storm-deployment-test

STORAGE_ROOT_DIR=${STORAGE_ROOT_DIR} \
HOSTNAME=${HOSTNAME} \
MODE=${MODE} \
PLATFORM=${PLATFORM} \
STORM_REPO=${STORM_REPO} \
sh run.sh

popd
