########## Instance Variables ##########
variable "vpnName" {}
variable "vpc_id" {}
variable "bgp_asn" {
  #Default range: 64512-65534
  default = "64512"
}
variable "customer_gateway_IP" {}
variable "type" {
  default = "ipsec.1"
}
variable "static_routes_only" {
  default = true
}
variable "destination_cidr_block" {}


########## Resource Declaration ##########
resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = "${var.vpc_id}"
  tags {
        Name = "${var.vpnName}"
  }
}

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = "${var.bgp_asn}"
  ip_address = "${var.customer_gateway_IP}"
  type       = "${var.type}"
  tags {
        Name = "${var.vpnName}"
  }
}

resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = "${aws_vpn_gateway.vpn_gateway.id}"
  customer_gateway_id = "${aws_customer_gateway.customer_gateway.id}"
  type                = "${var.type}"
  static_routes_only  = true
  tags {
        Name = "${var.vpnName}"
  }
}

resource "aws_vpn_connection_route" "connection_route" {
  destination_cidr_block = "${var.destination_cidr_block}"
  vpn_connection_id = "${aws_vpn_connection.main.id}"
}

########## Output ##########
output "vpn_gateway_id" {
   #Print out the id of the subnet
   value = "${aws_vpn_gateway.vpn_gateway.id}"
}

output "vpn_tunnel1_ip" {
   value = "${aws_vpn_connection.main.tunnel1_address}"
}

output "vpn_tunnel2_ip" {
   #Print out the id of the subnet
   value = "${aws_vpn_connection.main.tunnel2_address}"
}
