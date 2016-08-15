module "worker_qa" {
    source = "../modules/worker_qa"

    image_type = "t2.medium"
    cluster_desired_capacity = 3
    root_volume_size =  20
    docker_volume_size =  10
    keypair = "worker_qa"
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

    # qa app variables
    application_from_port = "${var.qa_app_from_port}"
    application_to_port = "${var.qa_app_to_port}"

    # This placeholder will be replaced by ADMIRAL subnet id and availability zone variables
    # For more information look into 'substitute-VPC-AZ-placeholders.sh'
    
		worker_qa_subnet_b_id = "${module.vpc.worker_qa_subnet_b_id}"
		worker_qa_subnet_c_id = "${module.vpc.worker_qa_subnet_c_id}"
		worker_qa_subnet_d_id = "${module.vpc.worker_qa_subnet_d_id}"
		worker_qa_subnet_e_id = "${module.vpc.worker_qa_subnet_e_id}"
	
		worker_qa_subnet_az_b = "${module.vpc.worker_qa_subnet_az_b}"
		worker_qa_subnet_az_c = "${module.vpc.worker_qa_subnet_az_c}"
		worker_qa_subnet_az_d = "${module.vpc.worker_qa_subnet_az_d}"
		worker_qa_subnet_az_e = "${module.vpc.worker_qa_subnet_az_e}"
}
