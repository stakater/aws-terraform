resource "aws_security_group" "admiral_global"  {
    name = "admiral_global"
    vpc_id = "${var.vpc_id}"
    description = "admiral_global"

    # Allow all outbound traffic
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow access from vpc
    ingress {
      from_port = 10
      to_port = 65535
      protocol = "tcp"
      cidr_blocks = ["${var.vpc_cidr}"]
    }

    # Allow access from vpc
    ingress {
      from_port = 10
      to_port = 65535
      protocol = "udp"
      cidr_blocks = ["${var.vpc_cidr}"]
    }

    # Allow SSH from my hosts
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.allow_ssh_cidr}"]
      self = true
    }

    tags {
      Name = "admiral_global"
    }
}