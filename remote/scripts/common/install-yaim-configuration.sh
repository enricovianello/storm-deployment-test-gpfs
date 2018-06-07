#!/bin/bash
set -ex
trap "exit 1" TERM

SITEINFO_DIR=$1

rm -rf /etc/storm/siteinfo
mkdir -p /etc/storm/siteinfo

cp -r ${SITEINFO_DIR}/* /etc/storm/siteinfo
