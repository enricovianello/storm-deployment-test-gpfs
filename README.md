# StoRM GPFS deployment test

## Prerequisites

Install Terraform.
https://www.terraform.io/intro/getting-started/install.html

## Usage

### Input variables

Variables for which it makes sense to change/set their value:

```
# Deployment type. Values: clean or update
mode = "clean"
# Tenant user password MANDATORY
mw_password = "my-secret-value"
# Root path of storage areas MANDATORY
storage_root_dir = "/storage"
# StoRM .repo file URL path
storm_repo = "http://italiangrid.github.io/storm/repo/storm_sl6.repo"
```

Fixed variables:

```
# Deployment platform. Values: centos6
platform = "centos6"
# Floating IP - Fixed
vm_fip = "131.154.96.127"
# Tenant user name
mw_username = "mw-user"
# Tenant name
mw_tenant = "MW-DEVEL"
# VM image
vm_image = "centos-6-1804-x86_64-generic-gpfs-client-certs"
# VM name
vm_name = "cloud-vm127"
# VM flavor
vm_flavor = "m1.medium"
# VM network name
vm_network_name = "net-mw-devel"
# VM network ipv4
vm_network_ipv4 = "10.50.9.114"
# SSH key file path used to login into VM
ssh_key_file = "/home/jenkins/.ssh/id_rsa"
# VM FQDN hostname
vm_fqdn_hostname = "cloud-vm127.cloud.cnaf.infn.it"
```

## Run

Create you `variables.tfvars` with your own values of variables.
Then, from `main.tf` directory run:

```
terraform init -input=false
terraform plan -var-file='variables.tfvars' -out=tfplan -input=false
terraform apply -input=false tfplan
```

To terminate:

```
terraform destroy
```

