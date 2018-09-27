########## Variables Declaration ##########
variable "cidr_block" {}
variable "enable_dns_support" {}
variable "enable_dns_hostnames" {}
variable "instance_tenancy" {}
variable "tags_name" {}

########## Resource Declaration ##########
resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr_block}"
  enable_dns_support = "${var.enable_dns_support}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  instance_tenancy = "${var.instance_tenancy}"
  tags = {
    Name = "${var.tags_name}"
  }
}

########## Output ##########
output "vpc_id" {
   #Print out the id of the vpc
   value = "${aws_vpc.vpc.id}"
}

output "vpc_main_route_table_id" {
   #Print out the main_route_table_id of the vpc
   value = "${aws_vpc.vpc.main_route_table_id}"
}
