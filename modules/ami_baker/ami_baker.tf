resource "aws_ami_from_instance" "ami_baker" {
    name = "${var.cluster_name}_${var.application_name}_${var.application_version}"
    source_instance_id = "${var.instance_id}"
    snapshot_without_reboot = "true"
}

output "ami_baker_ami_id" {
    value = "${aws_ami_from_instance.ami_baker.id}"
}
