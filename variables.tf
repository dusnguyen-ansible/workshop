########## Configure the AWS Provider ##########
provider "aws" {
  region  = "${var.region["london"]}"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "ah_poc_workshops"
  version = "~> 1.0"
}

########## Misc provider versions ##########
provider "random" {
  version = "~> 1.0"
}

provider "template" {
  version = "~> 1.0"
}

########## Variables Declaration ##########
variable "ssh_public_key" {
    #Replace this variable with your ssh public key
    default = ""
}

variable "keypair" {
    #Replace this variable with your own keypair name
    default = ""
}

variable "white_listed_ip" {
    #Replace this variable with your public IP address to allow SSH access
    default = "194.127.28.0"
}

variable "region" {
    type = "map"
    #We can add more regions here
    default = {
      frankfurt = "eu-central-1"
      ireland   = "eu-west-1"
      london    = "eu-west-2"
    }
}

variable "vpcName" {
    #Name of the VPC. Replace this with your choice of VPC name
    default = "dustin"
}

variable "vpcCDIR" {
    #IP range of the VPC
    default = "10.120.0.0/16"
}

variable "SubnetsCIDR" {
    type = "map"
    #IP range of the subnet
    default = {
      public  = "10.120.1.0/24"
      private = "10.120.2.0/24"
    }
}

variable "ubuntu_image_id" {
  type = "map"
  #Currently we use Ubuntu 16.04 LTS images
  default = {
    frankfurt = "ami-9c1db3f3"
    ireland   = "ami-016f9e78"
    london    = "ami-996372fd"
  }
}

variable "instance_number_prefix" {
  default = "%02d"
}
