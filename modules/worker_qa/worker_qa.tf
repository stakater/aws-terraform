#
# worker_qa autoscale group configurations
#
resource "aws_autoscaling_group" "worker_qa" {
  name = "${var.cluster_name}_worker_qa"
  # This placeholder will be replaced by array of variables defined for availability zone in the module's variables
  availability_zones = [ "${var.worker_qa_subnet_az_b}", "${var.worker_qa_subnet_az_c}", "${var.worker_qa_subnet_az_d}", "${var.worker_qa_subnet_az_e}" ]
  min_size = "${var.cluster_min_size}"
  max_size = "${var.cluster_max_size}"
  desired_capacity = "${var.cluster_desired_capacity}"

  health_check_type = "EC2"
  force_delete = true

  launch_configuration = "${aws_launch_configuration.worker_qa.name}"
  # This placeholder will be replaced by array of variables defined for VPC zone IDs in the module's variables
  vpc_zone_identifier = [ "${var.worker_qa_subnet_b_id}", "${var.worker_qa_subnet_c_id}", "${var.worker_qa_subnet_d_id}", "${var.worker_qa_subnet_e_id}" ]

  tag {
    key = "Name"
    value = "worker_qa"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "worker_qa" {
  # use system generated name to allow changes of launch_configuration
  image_id = "${var.ami}"
  instance_type = "${var.image_type}"
  iam_instance_profile = "${aws_iam_instance_profile.worker_qa.name}"
  security_groups = [ "${aws_security_group.worker_qa.id}" ]
  key_name = "${var.keypair}"
  lifecycle { create_before_destroy = true }

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

resource "aws_iam_instance_profile" "worker_qa" {
    name = "${var.cluster_name}_worker_qa"
    roles = ["${aws_iam_role.worker_qa.name}"]
}

resource "aws_iam_role_policy" "worker_qa_policy" {
    name = "${var.cluster_name}_worker_qa"
    role = "${aws_iam_role.worker_qa.id}"
    policy = "${file(\"policies/worker_qa_policy.json\")}"
}

resource "aws_iam_role" "worker_qa" {
    name = "${var.cluster_name}_worker_qa"
    path = "/"
    assume_role_policy =  "${file(\"policies/assume_role_policy.json\")}"
}
