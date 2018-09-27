########## Private Security Group Global Variables ##########
variable "private_subnet_vpc_id" {}

variable "private_subnet_ssh_port_cidr_blocks" {
  type    = "list"
  default = []
}

variable "private_subnet_icmp_cidr_blocks" {
  type    = "list"
  default = []
}


variable "private_subnet_security_group_tags_name" {}

########## Resource Declaration ##########
resource "aws_security_group" "private_subnet_security_group" {
  name        = "private_subnet_security_group"
  description = "Allow SSH from Bastion to private subnet"
  vpc_id = "${var.private_subnet_vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.private_subnet_ssh_port_cidr_blocks}"]
  }

  ingress {
    from_port   = "-1"
    to_port     = "-1"
    protocol    = "icmp"
    cidr_blocks = ["${var.private_subnet_icmp_cidr_blocks}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.private_subnet_security_group_tags_name}"
  }
}

########## Private Security Group Output ##########
output "private_subnet_security_group_name" {
  #Print out the name of the private_security_group
  value = "${aws_security_group.private_subnet_security_group.name}"
}

output "private_subnet_security_group_id" {
  #Print out the id of the private_subnet_security_group
  value = "${aws_security_group.private_subnet_security_group.id}"
}
