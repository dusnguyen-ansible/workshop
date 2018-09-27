########## Public Security Group Global Variables ##########
variable "public_subnet_vpc_id" {}

variable "public_subnet_ssh_port_cidr_blocks" {
  type    = "list"
  default = []
}

variable "public_subnet_icmp_cidr_blocks" {
  type    = "list"
  default = []
}

variable "public_subnet_security_group_tags_name" {}

########## Resource Declaration ##########
resource "aws_security_group" "public_subnet_security_group" {
  name        = "public_subnet_security_group"
  description = "Public subnet security group"
  vpc_id = "${var.public_subnet_vpc_id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks  = ["${var.public_subnet_ssh_port_cidr_blocks}"]
  }

  ingress {
    from_port   = "-1"
    to_port     = "-1"
    protocol    = "icmp"
    cidr_blocks = ["${var.public_subnet_icmp_cidr_blocks}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.public_subnet_security_group_tags_name}"
  }
}

########## Private Security Group Output ##########
output "public_subnet_security_group_name" {
  #Print out the name of the public_security_group
  value = "${aws_security_group.public_subnet_security_group.name}"
}

output "public_subnet_security_group_id" {
  #Print out the id of the public_subnet_security_group
  value = "${aws_security_group.public_subnet_security_group.id}"
}
