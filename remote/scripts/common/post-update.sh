#!/bin/bash
set -ex
trap "exit 1" TERM

# Removed no more used stuff
yum remove -y storm-gridhttps-plugin
yum remove -y java-1.6.0-openjdk java-1.7.0-openjdk java-1.7.0-openjdk-devel

# Update namespace schema
cd /etc/storm/backend-server
if [ -a "namespace-1.5.0.xsd.rpmnew" ]; then
    echo "Found namespace-1.5.0.xsd.rpmnew ..."
    mv namespace-1.5.0.xsd namespace-1.5.0.xsd.saved
    mv namespace-1.5.0.xsd.rpmnew namespace-1.5.0.xsd
fi

# 1.11.15

# StoRM WebDAV needs to know what host has not to be considered as a 3rd-party copy
echo "STORM_WEBDAV_HOSTNAME_0=\"cloud-vm127.cloud.cnaf.infn.it\"" >> /etc/sysconfig/storm-webdav
