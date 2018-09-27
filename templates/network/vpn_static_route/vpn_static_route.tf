########## Variables Declaration ##########
variable "route_table_id" {}
variable "destination_cidr_block" {}
variable "vpn_gateway_id" {}

########## Resource Declaration ##########
resource "aws_route" "vpn_static_route" {
	route_table_id  = "${var.route_table_id}"
	destination_cidr_block = "${var.destination_cidr_block}"
	gateway_id = "${var.vpn_gateway_id}"
}

########## Output ##########
output "route_table_id" {
   #Print out the id of the subnet
   value = "${aws_route.vpn_static_route.id}"
}
