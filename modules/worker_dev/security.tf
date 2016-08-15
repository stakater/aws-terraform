resource "aws_security_group" "worker_dev"  {
    name = "worker_dev"
    vpc_id = "${var.vpc_id}"
    description = "worker_dev"

    # Allow all outbound traffic
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow access to 4001 (fleet) inside VPC
    ingress {
      from_port = 4001
      to_port = 4001
      protocol = "tcp"
      cidr_blocks = [ "${var.vpc_cidr}" ]
    }

    # Allow access to applciation port
    ingress {
      from_port = "${var.application_from_port}"
      to_port = "${var.application_to_port}"
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
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
      Name = "worker_dev"
    }
}
