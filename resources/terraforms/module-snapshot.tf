module "snapshot" {
    source = "../modules/snapshot"

    keypair = "snapshot"

    # aws
    aws_account_id="${var.aws_account.id}"
    aws_region = "${var.aws_account.default_region}"
    ami = "${var.ami}"

    #cluster name
    cluster_name = "${var.cluster_name}"


    instance_id = "${module.amicreation.instance_id}"
    
}
