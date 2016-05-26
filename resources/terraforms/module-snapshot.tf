module "snapshot" {
    source = "../modules/snapshot"
    keypair = "snapshot"
    instance_id = "${module.amicreation.instance_id}"
    
}
