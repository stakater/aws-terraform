#
# etcd cluster autoscale group configurations
#
resource "aws_autoscaling_group" "etcd" {
  name = "etcd"
  # This placeholder will be replaced by array of variables defined for availability zone in the module's variables
  availability_zones = <%MODULE-AZ-VARIABLES-ARRAY%>
  min_size = "${var.cluster_min_size}"
  max_size = "${var.cluster_max_size}"
  desired_capacity = "${var.cluster_desired_capacity}"

  health_check_type = "EC2"
  force_delete = true

  launch_configuration = "${aws_launch_configuration.etcd.name}"
  # This placeholder will be replaced by array of variables defined for VPC zone IDs in the module's variables
  vpc_zone_identifier = <%MODULE-ID-VARIABLES-ARRAY%>

  tag {
    key = "Name"
    value = "etcd"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "etcd" {
  # use system generated name to allow changes of launch_configuration
  # name = "etcd-${var.ami}"
  image_id = "${var.ami}"
  instance_type = "${var.image_type}"
  iam_instance_profile = "${aws_iam_instance_profile.etcd.name}"
  security_groups = [ "${aws_security_group.etcd.id}" ]
  key_name = "${var.keypair}"
  lifecycle { create_before_destroy = true }
  depends_on = [ "aws_iam_instance_profile.etcd", "aws_security_group.etcd" ]

  # /root
  root_block_device = {
    volume_type = "gp2"
    volume_size = "${var.root_volume_size}"
  }
  # /var/lib/docker
  ebs_block_device = {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "${var.docker_volume_size}"
  }

  user_data = "${file("cloud-config/s3-cloudconfig-bootstrap.sh")}"
}

# setup the etcd ec2 profile, role and polices
resource "aws_iam_instance_profile" "etcd" {
    name = "etcd"
    roles = ["${aws_iam_role.etcd.name}"]
    depends_on = [ "aws_iam_role.etcd" ]
}

resource "aws_iam_role_policy" "etcd_policy" {
    name = "etcd_policy"
    role = "${aws_iam_role.etcd.id}"
    policy = "${file(\"policies/etcd_policy.json\")}"
    depends_on = [ "aws_iam_role.etcd" ]
}

resource "aws_iam_role" "etcd" {
    name = "etcd"
    path = "/"
    assume_role_policy =  "${file(\"policies/assume_role_policy.json\")}"
}
