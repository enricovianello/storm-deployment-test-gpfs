#!/bin/bash

instance=$1

if [ $# -eq 0 ]
then
echo "No instance name or id supplied."
echo "Usage: sh delete-if-exists <instance-name-or-id>"
exit 1
fi

status=$(openstack --os-cloud cnaf server show ${instance} -f json)

if [ $? -eq 1 ]
then
echo "${instance} not found. Nothing to delete."
exit 0
fi

echo "${status}"
echo "${instance} found. Deleting ..."
openstack --os-cloud cnaf server delete ${instance}

if [ $? -eq 0 ]
then
echo "${instance} successfully deleted!"
else
echo "Error while deleting {instance}"
exit 1
fi

exit 0
