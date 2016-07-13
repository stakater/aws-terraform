/* VPN Server -> Creating an EC2 instance on AWS */
resource "aws_instance" "base_instance" {
  count = 1
  ami   = "${var.ami}"
  availability_zone = "${var.availability_zone}"
  instance_type = "${var.image_type}"
  iam_instance_profile = "${aws_iam_instance_profile.base_instance.name}"

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

  key_name      = "${var.keypair}"
  subnet_id =  "${var.subnet_id}"
  security_groups = ["${aws_security_group.base_instance.id}"]

  tags {
        Name = "base_instance"
  }

  user_data = "${file("cloud-config/s3-cloudconfig-bootstrap.sh")}"
}

# setup the base_instance ec2 profile, role and polices
resource "aws_iam_instance_profile" "base_instance" {
    name = "${var.cluster_name}_base_instance"
    roles = ["${aws_iam_role.base_instance.name}"]
    depends_on = [ "aws_iam_role.base_instance" ]
}

resource "aws_iam_role_policy" "base_instance_policy" {
    name = "${var.cluster_name}_base_instance_policy"
    role = "${aws_iam_role.base_instance.id}"
    policy = "${file(\"policies/base_instance_policy.json\")}"
    depends_on = [ "aws_iam_role.base_instance" ]
}

resource "aws_iam_role" "base_instance" {
    name = "${var.cluster_name}_base_instance"
    path = "/"
    assume_role_policy =  "${file(\"policies/assume_role_policy.json\")}"
}

output "instance_id" {
    value = "${aws_instance.base_instance.id}"
}