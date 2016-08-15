module "server_certificate" {
    source = "../modules/server_certificate"
    
    #cluster name
    cluster_name = "${var.cluster_name}"

    certificate_body_path = "${var.certificate_body_path}"
    certificate_chain_path = "${var.certificate_chain_path}"
    private_key_path = "${var.private_key_path}"
}