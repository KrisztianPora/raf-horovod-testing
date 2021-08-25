aws_provider = ({
    region = "eu-central-1"
})

horovod_master_node = ({
    name = "krisztian_horovod_master"
    instance_type = "t3.medium"
    ami_id = "ami-05f7491af5eef733a"
    key_pair = "krisztian_ssh_key"
})

horovod_worker_node = ({
    name = "krisztian_horovod_worker"
    count = 2
    instance_type = "t3.medium"
    ami_id = "ami-05f7491af5eef733a"
    key_pair = "krisztian_ssh_key"
})

