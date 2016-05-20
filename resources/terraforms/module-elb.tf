module "elb" {
    source = "../modules/elb"

    # vpc
    vpc_id = "${module.vpc.vpc_id}"
    vpc_cidr = "${module.vpc.vpc_cidr}"

    # This placeholder will be replaced by module subnet id and availability zone variables
    # For more information look into 'substitute-VPC-AZ-placeholders.sh'
    
		elb_subnet_a_id = "${module.vpc.elb_subnet_a_id}"
		elb_subnet_b_id = "${module.vpc.elb_subnet_b_id}"
	
		elb_subnet_az_a = "${module.vpc.elb_subnet_az_a}"
		elb_subnet_az_b = "${module.vpc.elb_subnet_az_b}"

    # route53
    #route53_public_zone_id = "${module.route53.public_zone_id}"
    #route53_private_zone_id = "${module.route53.private_zone_id}"
    route53_public_zone_id = "not_available"
    route53_private_zone_id = "not_available"
}
