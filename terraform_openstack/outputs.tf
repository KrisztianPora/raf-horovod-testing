output "master_instance_ip" {
  value = openstack_compute_instance_v2.horovod_master.access_ip_v4
}

output "worker_instance_ips" {
  value = openstack_compute_instance_v2.horovod_workers[*].access_ip_v4
}
