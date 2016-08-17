module "vpc" {
    source = "../modules/vpc"
    vpc_cidr = "10.0.0.0/16"
    vpc_name = "${var.cluster_name}"
    vpc_region = "${var.aws_account["default_region"]}"

# the subnets can be configured. See ../modules/vpc for default values
}
