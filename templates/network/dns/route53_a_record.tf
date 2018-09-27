########## route53 zone variables ##########
variable "dns_zone_id" {}
variable "dns_name" {}
variable "dns_zone_ttl" {}
variable "ip_address" {}

########## Resource Declaration ##########
resource "aws_route53_record" "a_record" {
  zone_id = "${var.dns_zone_id}"
  name    = "${var.dns_name}"
  type    = "A"
  ttl     = "${var.dns_zone_ttl}"
  records = ["${var.ip_address}"]
}
