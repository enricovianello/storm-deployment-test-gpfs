# Provider settings
provider "openstack" {
  user_name = var.mw_username
  tenant_name = var.mw_tenant
  password = var.mw_password
  auth_url = "https://horizon.cloud.cnaf.infn.it:5000/v3"
  region = "regionOne"
  domain_name = "Default"
}

resource "openstack_compute_instance_v2" "test" {
  name = var.vm_name
  image_name = var.vm_image
  flavor_name = var.vm_flavor
  key_pair = "jenkins"
  security_groups = ["default", "storm", "mysql"]

  network {
    name = var.vm_network_name
    fixed_ip_v4 = var.vm_network_ipv4
  }
}

# Assign floating ip
resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = var.vm_fip
  instance_id = openstack_compute_instance_v2.test.id
}

# Upload configuration scripts
resource "null_resource" "configure" {
  connection {
    type = "ssh"
    user = "centos"
    agent = false
    private_key = file(var.ssh_key_file)
    host = var.vm_fip
  }

  provisioner "file" {
    source = "remote/"
    destination = "/home/centos"
  }

  depends_on = [
    openstack_compute_floatingip_associate_v2.fip_1,
  ]
}

# Boostrap as GPFS cluster client
resource "null_resource" "bootstrap-gpfs" {
  connection {
    type = "ssh"
    user = "centos"
    agent = false
    private_key = file(var.ssh_key_file)
    host = var.vm_fip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh bootstrap-gpfs.sh",
    ]
  }

  depends_on = [
    null_resource.configure,
  ]
}

# Provision script: run puppet and install useful stuff
resource "null_resource" "provision" {
  connection {
    type = "ssh"
        user = "centos"
        agent = false
        private_key = file(var.ssh_key_file)
        host = var.vm_fip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh provision.sh",
    ]
  }

  depends_on = [
    null_resource.bootstrap-gpfs,
  ]
}

# Deploy StoRM
resource "null_resource" "deploy" {
  connection {
    type = "ssh"
    user = "centos"
    agent = false
    private_key = file(var.ssh_key_file)
    host = var.vm_fip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh run.sh ${var.mode} ${var.platform} ${var.storm_repo} ${var.storage_root_dir} ${var.vm_fqdn_hostname}",
    ]
  }

  depends_on = [
    null_resource.provision,
  ]
}
