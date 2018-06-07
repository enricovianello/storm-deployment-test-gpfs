#!/bin/bash
set -ex

# Stop iptables ...
service iptables stop

# Install puppet
echo "Install puppet ..."
if rpm -qa | grep -q puppetlabs; then
  echo "puppetlabs already installed"
else
  rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
fi
yum clean all
yum -y install puppet

echo "Installing other base packages ... "
yum install -y git redhat-lsb-core

echo "Creating manifest file ..."

cat << EOF > manifest.pp
include mwdevel_egi_trust_anchors
include mwdevel_umd_repo
include mwdevel_test_vos
include mwdevel_test_ca
include mwdevel_infn_ca
EOF

echo "Installing base puppet modules ..."

puppet module install --force maestrodev-wget
puppet module install --force gini-archive
puppet module install --force puppetlabs-stdlib
puppet module install --force maestrodev-maven
puppet module install --force puppetlabs-java

echo "Fetching puppet modules from: https://github.com/cnaf/ci-puppet-modules ..."

if [ ! -e "ci-puppet-modules" ]; then
  git clone https://github.com/cnaf/ci-puppet-modules.git
else
  pushd ci-puppet-modules
  git pull
  popd
fi

echo "Applying the following puppet manifest: "
cat manifest.pp

puppet apply --debug -v \
  --modulepath "/etc/puppet/modules:$(pwd)/ci-puppet-modules/modules" \
  manifest.pp

echo "Install acl and extended attributes support ..."
yum install -y attr acl ntp

echo "Install fetch-crl ..."
yum install -y fetch-crl

echo "Run fetch-crl ..."
fetch-crl

echo "Check if errors occurred after fetch-crl execution ..."
if [ $? != 0 ]; then
  exit 1
fi
