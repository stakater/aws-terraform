resource "aws_route53_zone" "public" {
    name = "${var.public_domain}"

    tags {
        Name = "${var.public_domain}"
    }
}

resource "aws_route53_zone" "private" {
    name = "${var.private_domain}"
    vpc_id = "${var.vpc_id}"

    tags {
        Name = "${var.private_domain}"
    }
}

output "private_zone_id" {value = "${aws_route53_zone.private.zone_id}" }
output "public_zone_id" {value = "${aws_route53_zone.public.zone_id}" }
output "private_domain" {value = "${var.private_domain}" }