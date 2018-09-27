########## Variables Declaration ##########
variable "vpc_id" {}
variable "tags_name" {}
variable "route_table_id" {}
variable "destination_cidr_block" {}
variable "subnet_id" {}
variable "nat_tags_name" {}

########## Resource Declaration ##########
resource "aws_internet_gateway" "gw" {
  vpc_id = "${var.vpc_id}"
  tags {
        Name = "${var.tags_name}"
  }
}

resource "aws_eip" "gw_eip" {
  vpc      = true
  depends_on = [ "aws_internet_gateway.gw" ]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.gw_eip.id}"
  subnet_id = "${var.subnet_id}"
  depends_on = [ "aws_internet_gateway.gw" ]
  tags {
        Name = "${var.nat_tags_name}"
  }
}

########## Output ##########
output "gw_id" {
   #Print out the id of the gateway
   value = "${aws_internet_gateway.gw.id}"
}

output "gw_eip_id" {
   #Print out the id of the gateway EIP
   value = "${aws_eip.gw_eip.id}"
}

output "nat_gw_id" {
   #Print out the id of the nat gateway
   value = "${aws_nat_gateway.nat.id}"
}