variable "mode" {
  default = "clean"
}

variable "platform" {
  default = "centos6"
}

variable "vm_fip" {
  default = "131.154.96.127"
}

variable "mw_username" {
  default = "mw-user"
}

variable "mw_password" {}

variable "mw_tenant" {
  default = "MW-DEVEL"
}

variable "vm_image" {
  default = "centos-6-1804-x86_64-generic-gpfs-client-certs"
}

variable "vm_name" {
  default = "cloud-vm127"
}

variable "vm_flavor" {
  default = "m1.medium"
}

variable "vm_network_name" {
  default = "net-mw-devel"
}

variable "vm_network_ipv4" {
  default = "10.50.9.114"
}

variable "ssh_key_file" {
  default = "/home/jenkins/.ssh/id_rsa"
}

variable "storage_root_dir" {}

variable "vm_fqdn_hostname" {
  default = "cloud-vm127.cloud.cnaf.infn.it"
}