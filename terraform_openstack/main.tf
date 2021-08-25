terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.42.0"
    }
  }
  backend "http" {
  }
}


provider "openstack" {
  user_name   = var.auth_data.user_name
  password    = var.auth_data.password
  tenant_name = var.openstack_provider.tenant_name
  auth_url    = var.openstack_provider.auth_url
}

resource "openstack_networking_secgroup_v2" "terraform_horovod_master" {
  name        = "krisztian_terraform_horovod_master"
  description = "Created by Terraform. Do not use or manage manually."
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_1" {
  description = "Created by Terraform. Do not use or manage manually."
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.terraform_horovod_master.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_2" {
  description = "Created by Terraform. Do not use or manage manually."
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8888
  port_range_max    = 8888
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.terraform_horovod_master.id
}

resource "openstack_networking_secgroup_v2" "terraform_ALL" {
  name        = "krisztian_terraform_ALL"
  description = "Created by Terraform. Do not use or manage manually."
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_3" {
  description = "Created by Terraform. Do not use or manage manually."
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = var.horovod_network.network_subnet_range
  security_group_id = openstack_networking_secgroup_v2.terraform_ALL.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_4" {
  description = "Created by Terraform. Do not use or manage manually."
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = var.horovod_network.network_subnet_range
  security_group_id = openstack_networking_secgroup_v2.terraform_ALL.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_5" {
  description = "Created by Terraform. Do not use or manage manually."
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = var.horovod_network.network_subnet_range
  security_group_id = openstack_networking_secgroup_v2.terraform_ALL.id
}

resource "openstack_compute_instance_v2" "horovod_master" {
  name            = var.horovod_master_node.name
  image_id        = var.horovod_master_node.image_id
  flavor_name     = var.horovod_master_node.flavor_name
  key_pair        = var.horovod_master_node.key_pair
  security_groups = ["default", "${openstack_networking_secgroup_v2.terraform_horovod_master.name}", "${openstack_networking_secgroup_v2.terraform_ALL.name}"]

  provisioner "local-exec" {
    working_dir = "./"
    command = "export ANSIBLE_HOST_KEY_CHECKING=False && sleep 120 && ansible-playbook -u root -i '${self.access_ip_v4},' ../horovod_master.yaml"
  }
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = var.horovod_master_node.floating_ip
  instance_id = openstack_compute_instance_v2.horovod_master.id
}

resource "openstack_compute_instance_v2" "horovod_workers" {
  name            = var.horovod_worker_node.name
  count           = var.horovod_worker_node.count
  flavor_name     = var.horovod_worker_node.flavor_name
  image_id        = var.horovod_worker_node.image_id
  key_pair        = var.horovod_worker_node.key_pair
  security_groups = ["default", "${openstack_networking_secgroup_v2.terraform_ALL.name}"]

   provisioner "local-exec" {
    working_dir = "./"
    command = "export ANSIBLE_HOST_KEY_CHECKING=False && sleep 120 && ansible-playbook -u root -i '${self.access_ip_v4},' ../horovod_worker.yaml --extra-vars \"NFS_SERVER=${openstack_compute_instance_v2.horovod_master.access_ip_v4}\" "
  }

}

# Define variables
variable "auth_data" {
  type = object({
    user_name = string
    password = string
  })
  sensitive = true
}

variable "openstack_provider" {
  type = object({
    tenant_name = string
    auth_url = string
})
}

variable "horovod_master_node" {
  type = object({
    name = string
    flavor_name = string
    image_id = string
    key_pair = string
    floating_ip = string
})
}

variable "horovod_worker_node" {
  type = object({
    name = string
    count = number
    flavor_name = string
    image_id = string
    key_pair = string
})
}

variable "horovod_network" {
  type = object({
    network_subnet_range = string
})
}
