output "master_instance_ip" {
  value = aws_instance.horovod_master.private_ip
}

output "master_instance_public_ip" {
  value = aws_instance.horovod_master.public_ip
  sensitive = true
}

output "worker_instance_ips" {
  value = aws_instance.horovod_workers[*].private_ip
}
