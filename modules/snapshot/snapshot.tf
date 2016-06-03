resource "aws_ami_from_instance" "snapshot" {
    name = "${var.cluster_name}_ami-snapshot"
    source_instance_id = "${var.instance_id}"
}

output "snapshot_ami_id" {
    value = "${aws_ami_from_instance.snapshot.id}"
}
