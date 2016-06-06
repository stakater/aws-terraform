module "ami_baker" {
    source = "../modules/ami_baker"
    instance_id = "${module.base_instance.instance_id}"
    #cluster name
    cluster_name = "${var.cluster_name}"
}
