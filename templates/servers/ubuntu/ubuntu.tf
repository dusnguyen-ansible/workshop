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
  default = false
}
variable "subnet_id" {}
variable "depends_on" {
  type    = "list"
  default = []
}
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
resource "aws_instance" "ubuntu" {
  count = "${var.count}"
  ami = "${var.image_id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.keypair_name}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = [ "${var.vpc_security_group_ids}" ]
  provisioner "local-exec" {
    command = ": ${join(" ", var.depends_on)} >/dev/null"
  }
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
      "sudo apt-get install apache2 -y",
      "sudo systemctl enable apache2",
      "sudo systemctl start apache2",
      "sudo chmod 777 /var/www/html/index.html"
    ]
  }
  provisioner "file" {
    connection {
        user = "ubuntu"
    }
    source = "./templates/servers/ubuntu/index.html"
    destination = "/var/www/html/index.html"
  }

  provisioner "remote-exec" {
    connection {
        user = "ubuntu"
    }
    inline = [
      "sudo chmod 644 /var/www/html/index.html"
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
  availability_zone = "${element(aws_instance.ubuntu.*.availability_zone, count.index)}"
  snapshot_id = "${var.snap_shot_id}"
  encrypted = "${var.encrypted}"
  kms_key_id = "${var.kms_key_id}"
  tags {
        Name = "${var.vpcName}${var.hostname}${format("${var.instance_number_prefix}", count.index+1)}Volume"
  }
}

resource "aws_volume_attachment" "ebs_attatchment" {
  count = "${var.attach_volume}"
  depends_on = [
    "aws_instance.ubuntu"
  ]
  device_name = "${var.device_name}"
  volume_id   = "${element(aws_ebs_volume.ebs_volume.*.id, count.index)}"
  instance_id = "${element(aws_instance.ubuntu.*.id, count.index)}"
}

########## Output ##########
output "public_ip" {
   #Print out the public IP of the server
   value = ["${aws_instance.ubuntu.*.public_ip}"]
}
output "private_ip" {
  #Print out the private IP of the server
  value = ["${aws_instance.ubuntu.*.private_ip}"]
}

output "instance_id" {
  value = "${aws_instance.ubuntu.*.id}"
}
