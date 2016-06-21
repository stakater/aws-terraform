module "admiral_global" {
    source = "../modules/admiral_global"

    image_type = "t2.medium"
    cluster_desired_capacity = 1
    root_volume_size =  8
    docker_volume_size =  12
    data_volume_size =  12
    keypair = "admiral_global"
    allow_ssh_cidr="0.0.0.0/0"

    # aws
    aws_account_id="${var.aws_account.id}"
    aws_region = "${var.aws_account.default_region}"
    ami = "${var.ami}"

    #cluster name
    cluster_name = "${var.cluster_name}"

    # vpc
    vpc_id = "${module.vpc.vpc_id}"
    vpc_cidr = "${module.vpc.vpc_cidr}"

    # This placeholder will be replaced by module subnet id and availability zone variables
    # For more information look into 'substitute-VPC-AZ-placeholders.sh'
    
		admiral_global_subnet_a_id = "${module.vpc.admiral_global_subnet_a_id}"
		admiral_global_subnet_b_id = "${module.vpc.admiral_global_subnet_b_id}"
	
		admiral_global_subnet_az_a = "${module.vpc.admiral_global_subnet_az_a}"
		admiral_global_subnet_az_b = "${module.vpc.admiral_global_subnet_az_b}"
}
