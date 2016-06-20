variable "vpc_id" { }
#variable "public_domain" { default="dockerage.com" }
variable "private_domain" { }
variable "docker_registry_private_ip" { }

resource "aws_route53_zone" "private" {
    name = "${var.private_domain}"
    vpc_id = "${var.vpc_id}"

    tags {
        Name = "${var.private_domain}"
    }
}

resource "aws_route53_record" "registry_local" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name = "registry"
  type = "A"
  ttl = "5"
  records = ["${var.docker_registry_private_ip}"]
}

output "private_zone_id" {value = "${aws_route53_zone.private.zone_id}" }
output "private_domain" {value = "${var.private_domain}" }