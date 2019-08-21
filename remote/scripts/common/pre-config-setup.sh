#!/bin/bash
set -ex
trap "exit 1" TERM

# StoRM WebDAV needs to know what host has not to be considered as a 3rd-party copy
echo "" >> /etc/sysconfig/storm-webdav
echo "STORM_WEBDAV_HOSTNAME_0=\"cloud-vm127.cloud.cnaf.infn.it\"" >> /etc/sysconfig/storm-webdav
