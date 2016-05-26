module "snapshot" {
    source = "../modules/snapshot"
    instance_id = "${module.amicreation.instance_id}"

}
