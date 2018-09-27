########## Variables Declaration ##########
variable "vpc_id" {}
variable "cidr_block" {}
variable "map_public_ip_on_launch" {
  default = false
}
variable "tags_name" {}

########## Resource Declaration ##########
resource "aws_subnet" "Subnet" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.cidr_block}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"
  tags = {
  	Name =  "${var.tags_name}"
  }
}

########## Output ##########
output "subnet_id" {
   #Print out the id of the subnet
   value = "${aws_subnet.Subnet.id}"
}