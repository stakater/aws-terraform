module "aurora_db" {
    source = "../modules/aurora_db"

    aurora_db_name = "mydb"
    aurora_db_username = "demo"
    aurora_db_password = "demodemodemo"
    environment_name = "demoenv"

    # vpc
    vpc_id = "${module.vpc.vpc_id}"

    # This placeholder will be replaced by module subnet id and availability zone variables
    # For more information look into 'substitute-VPC-AZ-placeholders.sh'
    
		aurora_db_subnet_a_id = "${module.vpc.aurora_db_subnet_a_id}"
		aurora_db_subnet_b_id = "${module.vpc.aurora_db_subnet_b_id}"
		aurora_db_subnet_c_id = "${module.vpc.aurora_db_subnet_c_id}"
	
		aurora_db_subnet_az_a = "${module.vpc.aurora_db_subnet_az_a}"
		aurora_db_subnet_az_b = "${module.vpc.aurora_db_subnet_az_b}"
		aurora_db_subnet_az_c = "${module.vpc.aurora_db_subnet_az_c}"
}