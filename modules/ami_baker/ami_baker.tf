resource "aws_ami_from_instance" "ami_baker" {
    name = "${var.cluster_name}_ami"
    source_instance_id = "${var.instance_id}"
}

output "ami_baker_ami_id" {
    value = "${aws_ami_from_instance.ami_baker.id}"
}
