module "route53" {
    source = "../modules/route53"
    vpc_id="${module.vpc.vpc_id}"
    public_domain = "${var.public_domain}"
    private_domain = "${var.private_domain}"
}