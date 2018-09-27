########## Route Tables Golbal Variables Declaration ##########
variable "vpc_id" {}
variable "nat_gateway_id" {}
variable "internet_gateway_id" {}
variable "public_subnet_id" {}
variable "private_subnet_id" {}
variable "public_route_table_tags_name" {}
variable "private_route_table_tags_name" {}

########## Resource Declaration ##########
resource "aws_route_table" "PublicRoutetable" {
    vpc_id = "${var.vpc_id}"
    tags {
        Name = "${var.public_route_table_tags_name}"
    }
}

resource "aws_route_table" "PrivateRoutetable" {
    vpc_id = "${var.vpc_id}"
    tags {
        Name = "${var.private_route_table_tags_name}"
    }
}

resource "aws_route" "public_route" {
	route_table_id  = "${aws_route_table.PublicRoutetable.id}"
	destination_cidr_block = "0.0.0.0/0"
	gateway_id = "${var.internet_gateway_id}"
}

resource "aws_route" "private_route" {
	route_table_id  = "${aws_route_table.PrivateRoutetable.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${var.nat_gateway_id}"
}

resource "aws_route_table_association" "PublicSubnetAssociation" {
    subnet_id = "${var.public_subnet_id}"
    route_table_id = "${aws_route_table.PublicRoutetable.id}"
}

resource "aws_route_table_association" "PrivateSubnetAssociation" {
    subnet_id = "${var.private_subnet_id}"
    route_table_id = "${aws_route_table.PrivateRoutetable.id}"
}

########## Output ##########
output "public_route_table_id" {
   #Print out the id of the public_route_table
   value = "${aws_route_table.PublicRoutetable.id}"
}

output "private_route_table_id" {
   #Print out the id of the private_route_table
   value = "${aws_route_table.PrivateRoutetable.id}"
}
