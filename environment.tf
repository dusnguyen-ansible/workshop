########## VPC ##########
module "VPC" {
  source = "./templates/network/vpc"
  cidr_block = "${var.vpcCDIR}"
  enable_dns_support = true
  enable_dns_hostnames = true
  instance_tenancy = "default"
  tags_name = "${var.vpcName}"
}

########## Default keypair for accessing the instances ##########
resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.keypair}"
  public_key = "${var.ssh_public_key}"
}

########## Subnets ##########
module "PublicSubnet" {
  source = "./templates/network/subnets"
  vpc_id = "${module.VPC.vpc_id}"
  cidr_block = "${var.SubnetsCIDR["public"]}"
  map_public_ip_on_launch = true
  tags_name = "${var.vpcName}PublicSubnet"
}

module "PrivateSubnet" {
  source = "./templates/network/subnets"
  vpc_id = "${module.VPC.vpc_id}"
  cidr_block = "${var.SubnetsCIDR["private"]}"
  tags_name = "${var.vpcName}PrivateSubnet"
}

########## Internet Gateway ##########
module "InternetGateway" {
  source = "./templates/network/internet_gateway/"
  vpc_id = "${module.VPC.vpc_id}"
  route_table_id = "${module.VPC.vpc_main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  subnet_id = "${module.PublicSubnet.subnet_id}"
  tags_name = "${var.vpcName}InternetGateway"
  nat_tags_name = "${var.vpcName}InternetGatewayNat"
}

########## Routes & Route tables ##########
module "RouteTables" {
  source = "./templates/network/route_tables/"
  vpc_id = "${module.VPC.vpc_id}"
  internet_gateway_id = "${module.InternetGateway.gw_id}"
  nat_gateway_id = "${module.InternetGateway.nat_gw_id}"
  public_subnet_id = "${module.PublicSubnet.subnet_id}"
  private_subnet_id = "${module.PrivateSubnet.subnet_id}"
  public_route_table_tags_name = "${var.vpcName}PublicSubnetRoute"
  private_route_table_tags_name = "${var.vpcName}PrivateSubnetRoute"
}

########## Security Groups ##########
module "SecurityGroups" {
  source = "./templates/security_groups/"
  public_subnet_vpc_id = "${module.VPC.vpc_id}"
  public_subnet_security_group_tags_name =  "${var.vpcName}PublicSubnetSecurityGroup"
  public_subnet_ssh_port_cidr_blocks = [ "${var.white_listed_ip}/32" ]
  public_subnet_icmp_cidr_blocks = [ "${var.white_listed_ip}/32" ]
  private_subnet_vpc_id = "${module.VPC.vpc_id}"
  private_subnet_security_group_tags_name =  "${var.vpcName}PrivateSubnetSecurityGroup"
  external_elb_vpc_id = "${module.VPC.vpc_id}"
  external_elb_http_port_cidr_blocks = [ "0.0.0.0/0" ]
  external_elb_security_group_tags_name = "${var.vpcName}ExternalELBSecurityGroup"
  webserver_vpc_id = "${module.VPC.vpc_id}"
  webserver_http_port_security_group_id = [ "${module.SecurityGroups.external_elb_security_group_id}" ]
  webserver_security_group_tags_name = "${var.vpcName}WebServerSecurityGroup"
}

########## Server ##########
module "WebServer" {
  source = "./templates/servers/ubuntu"
  count = "1"
  image_id = "${var.ubuntu_image_id["london"]}"
  instance_type = "t2.small"
  keypair_name = "${var.keypair}"
  subnet_id = "${module.PublicSubnet.subnet_id}"
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "${module.SecurityGroups.public_subnet_security_group_id}",
    "${module.SecurityGroups.webserver_security_group_id}",
  ]
  hostname = "webserver"
  vpcName = "${var.vpcName}"
  instance_number_prefix = "${var.instance_number_prefix}"
}

########## ELBs ##########
resource "aws_elb" "external_elb" {
  name               = "${var.vpcName}ELB"

  access_logs {
    bucket        = "workshops-elb-logs"
    bucket_prefix = "test-logs"
    interval      = "60"
    enabled       = false
  }
  security_groups = [
    "${module.SecurityGroups.external_elb_security_group_id}",
  ]
  subnets = ["${module.PublicSubnet.subnet_id}"]
  internal = false
  instances = [
    "${module.WebServer.instance_id[0]}",
  ]
  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 300
  }
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  tags {
    Name = "${var.vpcName}TestELB"
  }
}

########## Output ##########
output "webserver_public_ip" {
  #Print out the web server public IP
  value = "${module.WebServer.public_ip}"
}
output "webserver_private_ip" {
  #Print out the web server private IP
  value = "${module.WebServer.private_ip}"
}

output "external_elb" {
  #Print out the DNS of external ELB
  value = "${aws_elb.external_elb.dns_name}"
}
