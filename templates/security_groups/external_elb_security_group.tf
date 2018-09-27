########## External ELB Security Group Global Variables ##########
variable "external_elb_vpc_id" {}

variable "external_elb_http_port_cidr_blocks" {
  type    = "list"
  default = []
}

variable "external_elb_security_group_tags_name" {}

########## Resource Declaration ##########
resource "aws_security_group" "external_elb_security_group" {
  name        = "external_elb_security_group"
  description = "external elb security group"
  vpc_id = "${var.external_elb_vpc_id}"

  #Http Port
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks  = ["${var.external_elb_http_port_cidr_blocks}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.external_elb_security_group_tags_name}"
  }
}

########## External Elb Security Group Output ##########
output "external_elb_security_group_name" {
  #Print out the name of the external_elb_security_group
  value = "${aws_security_group.external_elb_security_group.name}"
}

output "external_elb_security_group_id" {
  #Print out the id of the external_elb_security_group
  value = "${aws_security_group.external_elb_security_group.id}"
}
