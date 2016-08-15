# Upload a certicate to iam in order to setup https
resource "aws_iam_server_certificate" "server_certificate" {
  name = "${var.cluster_name}_server_certificate"
  certificate_body = "${file("${var.certificate_body_path}")}"
  certificate_chain = "${file("${var.certificate_chain_path}")}"
  private_key = "${file("${var.private_key_path}")}"

  provisioner "local-exec" {
    command = <<EOF
echo # Sleep 10 secends so that aws_iam_server_certificate is truely setup by aws iam service
echo # See https://github.com/hashicorp/terraform/issues/2499 (terraform ~v0.6.1)
sleep 10
EOF
  }
}

output "server_certificate_arn" {value = "${aws_iam_server_certificate.server_certificate.arn}" }