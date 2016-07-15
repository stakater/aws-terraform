resource "aws_ami_from_instance" "ami_baker" {
    name = "${var.cluster_name}_${var.application_name}_${var.application_version}"
    source_instance_id = "${var.instance_id}"
}

output "ami_baker_ami_id" {
    value = "${aws_ami_from_instance.ami_baker.id}"
}
