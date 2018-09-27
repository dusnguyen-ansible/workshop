########## Webserver Security Group Global Variables ##########
variable "webserver_vpc_id" {}

variable "webserver_http_port_security_group_id" {
  type    = "list"
  default = []
}

variable "webserver_security_group_tags_name" {}

########## Resource Declaration ##########
resource "aws_security_group" "webserver_security_group" {
  name        = "webserver_security_group"
  description = "Webserver Security Group"
  vpc_id = "${var.webserver_vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["${var.webserver_http_port_security_group_id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.webserver_security_group_tags_name}"
  }
}

########## Webserver Security Group Output ##########
output "webserver_security_group_name" {
  #Print out the name of the webserver_security_group
  value = "${aws_security_group.webserver_security_group.name}"
}

output "webserver_security_group_id" {
  #Print out the id of the webserver_security_group
  value = "${aws_security_group.webserver_security_group.id}"
}
