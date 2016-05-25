/* The AWS Security Group specifies the inbound (ingress) and outbound (egress) networking rules */
resource "aws_security_group" "amicreation" {
  name   = "amicreation"
  vpc_id = "${var.vpc_id}"
  description = "amicreation"

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
      Name = "amicreatioi"
  }
}