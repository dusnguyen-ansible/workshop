########## Instance Variables ##########
variable "count" {}
variable "image_id" {
  type = "string"
  default = "ami-996372fd"
}
variable "instance_type" {
  type = "string"
  default = "t2.micro"
}
variable "keypair_name" {}
variable "associate_public_ip_address" {
  default = true
}
variable "subnet_id" {}
variable "private_base_subnet" {}
variable "start_ip_range" {}
variable "vpc_security_group_ids" {
  type    = "list"
  default = []
}
variable "hostname" {}
variable "vpcName" {}
variable "instance_number_prefix" {}

########## Volume Variables ##########
variable "attach_volume" {
  default = false
}

variable "volume_type" {
  #General Purpose SSD: gp2
  #Provisioned IOPS SSD: io1
  #Cold HDD: sc1
  #throughput Optimized HDD: st1
  #Magnetic: standard
  default = "gp2"
}

variable "volume_size" {
  default = "1"
}

variable "iops" {
  #io1: 100 - 20000
  #gp2: 100 - 3000
  #sc1/st1/magnetic: NA
  default = "100"
}

variable "snap_shot_id" {
  default = ""
}

variable "encrypted" {
  default = false
}

variable "kms_key_id" {
  default = ""
}

########## Volume Attachment Variables ##########
variable "device_name" {
  default = "/dev/xvdh"
}

variable "force_detach" {
  default = false
}

variable "skip_destroy" {
  default = false
}

########## Resource Declaration ##########
resource "aws_instance" "bastion" {
  count = "${var.count}"
  ami = "${var.image_id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.keypair_name}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  subnet_id = "${var.subnet_id}"
  private_ip = "${var.private_base_subnet}${count.index+var.start_ip_range}"
  vpc_security_group_ids = [ "${var.vpc_security_group_ids}" ]
  provisioner "remote-exec" {
    connection {
        user = "ubuntu"
    }
    inline = [
      "HOSTNAME='${var.hostname}${format("${var.instance_number_prefix}", count.index+1)}'",
      "echo $HOSTNAME | sudo tee /etc/hostname",
      "sudo hostname $HOSTNAME",
      "sudo apt-get update",
      "sudo apt-get install -y ntp ntpdate",
      "sudo ntpdate -u 0.ubuntu.pool.ntp.org",
      "sudo timedatectl set-timezone Europe/London",
    ]
  }
  lifecycle {
    ignore_changes = ["ami","instance_type","key_name"]
  }
  tags {
        Name = "${var.vpcName}${var.hostname}${format("${var.instance_number_prefix}", count.index+1)}"
  }
}

########## Resource Declaration ##########
resource "aws_ebs_volume" "ebs_volume" {
  count = "${var.attach_volume}"
  type = "${var.volume_type}"
  size = "${var.volume_size}"
  iops = "${var.iops}"
  availability_zone = "${element(aws_instance.bastion.*.availability_zone, count.index)}"
  snapshot_id = "${var.snap_shot_id}"
  encrypted = "${var.encrypted}"
  kms_key_id = "${var.kms_key_id}"
  tags {
        Name = "${var.vpcName}${var.hostname}${format("${var.instance_number_prefix}", count.index+1)}Volume"
  }
}

resource "aws_volume_attachment" "ebs_attatchment" {
  count = "${var.attach_volume}"
  device_name = "${var.device_name}"
  volume_id   = "${aws_ebs_volume.ebs_volume.id}"
  instance_id = "${element(aws_instance.bastion.*.id, count.index)}"
}

########## Output ##########
output "private_ip" {
  value = ["${aws_instance.bastion.*.private_ip}"]
}

output "public_ip" {
  value = ["${aws_instance.bastion.*.public_ip}"]
}

output "instance_id" {
  value = "${aws_instance.bastion.*.id}"
}
