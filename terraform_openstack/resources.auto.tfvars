openstack_provider = ({
    tenant_name = "DDL"
    auth_url = "authurl"
})

horovod_master_node = ({
    name = "krisztian_horovod_master"
    flavor_name = "m1.medium"
    image_id = "88bafb03-b169-4289-8f6f-c0cffc9177ca"
    key_pair = "gitlab-bot-key"
    floating_ip= "floatingip"
})

horovod_worker_node = ({
    name = "krisztian_horovod_worker"
    count = 2
    flavor_name = "m1.medium"
    image_id = "88bafb03-b169-4289-8f6f-c0cffc9177ca"
    key_pair = "gitlab-bot-key"
})

horovod_network = ({
    network_subnet_range = "192.168.0.0/16"
})
