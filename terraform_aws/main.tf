terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "http" {
  }
}


provider "aws" {
  access_key = var.auth_data.access_key
  secret_key = var.auth_data.secret_key
  region = var.aws_provider.region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "selected" {
  id = tolist(data.aws_subnet_ids.all.ids)[0]
}

resource "aws_security_group" "terraform_horovod_master" {
  name        = "krisztian_terraform_horovod_master"
  description = "Created by Terraform. Do not use or manage manually."
}

resource "aws_security_group_rule" "secgroup_rule_1" {
  description = "Created by Terraform. Do not use or manage manually."
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.terraform_horovod_master.id
}

resource "aws_security_group_rule" "secgroup_rule_2" {
  description = "Created by Terraform. Do not use or manage manually."
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8888
  to_port           = 8888
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.terraform_horovod_master.id
}

resource "aws_security_group" "terraform_ALL" {
  name        = "krisztian_terraform_ALL"
  description = "Created by Terraform. Do not use or manage manually."
}

resource "aws_security_group_rule" "secgroup_rule_3" {
  description = "Created by Terraform. Do not use or manage manually."
  type              = "ingress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = [data.aws_subnet.selected.cidr_block]
  security_group_id = aws_security_group.terraform_ALL.id
}

resource "aws_security_group_rule" "secgroup_rule_4" {
  description = "Created by Terraform. Do not use or manage manually."
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = [data.aws_subnet.selected.cidr_block]
  security_group_id = aws_security_group.terraform_ALL.id
}

resource "aws_security_group_rule" "secgroup_rule_5" {
  description = "Created by Terraform. Do not use or manage manually."
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.terraform_ALL.id
}

resource "aws_security_group_rule" "secgroup_rule_6" {
  description = "Created by Terraform. Do not use or manage manually."
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.terraform_ALL.id
}

resource "aws_instance" "horovod_master" {
  ami                    = var.horovod_master_node.ami_id
  instance_type          = var.horovod_master_node.instance_type
  subnet_id              = data.aws_subnet.selected.id
  key_name               = var.horovod_master_node.key_pair
  vpc_security_group_ids = [
      aws_security_group.terraform_ALL.id,
      aws_security_group.terraform_horovod_master.id
  ]

  root_block_device {
      volume_type = "gp2"
      volume_size = 16
  }

  tags = {
    Name = var.horovod_master_node.name
  }

  provisioner "local-exec" {
    working_dir = "./"
    command = "export ANSIBLE_HOST_KEY_CHECKING=False && sleep 120 && ssh-keyscan -H ${self.public_ip} >> ~/.ssh/known_hosts && ../scripts/ansible-config.sh ${self.public_ip} && ansible-playbook -u root -i '${self.private_ip},' ../horovod_master.yaml"
  }
}

resource "aws_instance" "horovod_workers" {
  count                  = var.horovod_worker_node.count
  ami                    = var.horovod_worker_node.ami_id
  instance_type          = var.horovod_worker_node.instance_type
  subnet_id              = data.aws_subnet.selected.id
  key_name               = var.horovod_worker_node.key_pair
  vpc_security_group_ids = [
      aws_security_group.terraform_ALL.id,
  ]

  root_block_device {
      volume_type = "gp2"
      volume_size = 16
  }

  tags = {
    Name = var.horovod_worker_node.name
  }

  provisioner "local-exec" {
    working_dir = "./"
    command = "export ANSIBLE_HOST_KEY_CHECKING=False && sleep 120 && ssh-keyscan -H ${aws_instance.horovod_master.public_ip} >> ~/.ssh/known_hosts && ../scripts/ansible-config.sh ${aws_instance.horovod_master.public_ip} && ansible-playbook -u root -i '${self.private_ip},' ../horovod_worker.yaml --extra-vars \"NFS_SERVER=${aws_instance.horovod_master.private_ip}\" "
  }
}

# Define variables
variable "auth_data" {
  type = object({
    access_key = string
    secret_key = string
  })
  sensitive = true
}

variable "aws_provider" {
  type = object({
    region = string
})
}

variable "horovod_master_node" {
  type = object({
    name = string
    instance_type = string
    ami_id = string
    key_pair = string
})
}

variable "horovod_worker_node" {
  type = object({
    name = string
    count = number
    instance_type = string
    ami_id = string
    key_pair = string
})
}
