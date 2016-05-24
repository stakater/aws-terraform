module "amicreation" {
    source = "../modules/amicreation"

    # amicreation cluster_desired_capacity should be in odd numbers, e.g. 3, 5, 9
    cluster_desired_capacity = 1
    image_type = "t2.micro"
    keypair = "etcd"
    allow_ssh_cidr="0.0.0.0/0"

    # aws
    aws_account_id="${var.aws_account.id}"
    aws_region = "${var.aws_account.default_region}"
    ami = "${var.ami}"

    #cluster name
    cluster_name = "${var.cluster_name}"

    # Note: currently amicreation launch_configuration devices can NOT be changed after etcd cluster is up
    # See https://github.com/hashicorp/terraform/issues/2910
    docker_volume_size = 12
    root_volume_size = 12

    # vpc
    vpc_id = "${module.vpc.vpc_id}"
    vpc_cidr = "${module.vpc.vpc_cidr}"

    # This placeholder will be replaced by MODULE subnet id and availability zone variables
    # For more information look into 'substitute-VPC-AZ-placeholders.sh'
    <%MODULE-SUBNET-IDS-AND-AZS%>
}
