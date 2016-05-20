module "rds" {
    source = "../modules/rds"

    db_user = "demo"
    db_password = "demodemodemo"

    # vpc
    vpc_id = "${module.vpc.vpc_id}"
    vpc_cidr = "${module.vpc.vpc_cidr}"

    # This placeholder will be replaced by module subnet id and availability zone variables
    # For more information look into 'substitute-VPC-AZ-placeholders.sh'
    
		rds_subnet_a_id = "${module.vpc.rds_subnet_a_id}"
		rds_subnet_b_id = "${module.vpc.rds_subnet_b_id}"
	
		rds_subnet_az_a = "${module.vpc.rds_subnet_az_a}"
		rds_subnet_az_b = "${module.vpc.rds_subnet_az_b}"
}
