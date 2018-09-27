AWS Terraform Simple Webserver Project
======================================

- Website: https://www.terraform.io
- [![Gitter chat](https://badges.gitter.im/hashicorp-terraform/Lobby.png)](https://gitter.im/hashicorp-terraform/Lobby)
- Mailing list: [Google Groups](http://groups.google.com/group/terraform-tool)

<img src="https://cdn.rawgit.com/hashicorp/terraform-website/master/content/source/assets/images/logo-hashicorp.svg" width="600px">


Download & Setup Terraform
--------------------------

-	[Download Terraform](https://www.terraform.io/downloads.html)
-   [Install Terraform](https://www.terraform.io/intro/getting-started/install.html)

Download and unzip the Terraform binary package into your home directory.
Setup terraform by creating a symlink to the binary:
```bash
$ sudo ln -s /home/$(whoami)/terraform /usr/local/bin/terraform
```

Or permanently set $PATH:
- [environment PATH](https://stackoverflow.com/questions/14637979/how-to-permanently-set-path-on-linux-unix)


Verifying Terraform installation
--------------------------------

After installing Terraform, verify the installation by opening a new terminal session and checking that Terraform is available.

When executing Terraform you should see help output similar to this:
```bash
$ terraform
Usage: terraform [--version] [--help] <command> [args]

The available commands for execution are listed below.
The most common, useful commands are shown first, followed by
less common or more advanced commands. If you're just getting
started with Terraform, stick with the common commands. For the
other commands, please read the help and docs before usage.

Common commands:
    apply              Builds or changes infrastructure
    console            Interactive console for Terraform interpolations
# ...
```

If you get an error that terraform could not be found, your PATH environment variable was not set up properly. Please go back and ensure that your PATH variable contains the directory where Terraform was installed.


Getting Started
---------------

First you need to do a clean check out of the project:
```bash
$ git clone git@github.com:dusnguyen/terraform-aws-web-project.git
```
Or download a copy of the project:

[Download project](https://github.com/dusnguyen/terraform-aws-web-project/archive/master.zip)


AWS Access & Credentials
------------------------

- [AWS Security Credentials](https://docs.aws.amazon.com/general/latest/gr/aws-security-credentials.html)

You will need AWS IAM user account with:
```
IAMFullAccess
```
```
AmazonS3FullAccess
```

Configuration
-------------
The project root contains a file `variables.tf`. It contains a listing of Terraform & AWS variables.
You will need to replace the followings with your own:
- AWS access key:
```variable "aws_access_key" ```
- AWS secret key:
```variable "aws_secret_key"```
- SSH public key:
```variable "ssh_public_key"```
- SSH public key name:
```variable "keypair"```
- VPC name:
```variable "vpcName" ```
- Whitelisted IP address(s) for SSH access to the servers:
```variable "white_listed_ip"```

Usage
-------

- [Commands (CLI)](https://www.terraform.io/docs/commands/index.html)
- [Build Infrastructure](https://www.terraform.io/intro/getting-started/build.html)
- [Change Infrastructure](https://www.terraform.io/intro/getting-started/change.html)
- [Destroy Infrastructure](https://www.terraform.io/intro/getting-started/destroy.html)

First make sure you are in the root directory of the project:
```bash
$ cd /path_to_the_project
```

1 - Update/Download the Terraform modules into a local .terraform folder
```bash
$ terraform get ./
```

2 - Initialisation: Preparing the working directory for use
```bash
$ terraform init
```

3 - Plan: Create an execution plan
```bash
$ terraform plan
```

4 - Apply: scans the current directory for the configuration and applies the changes appropriately
```bash
$ terraform apply
```

5 - Output: Once Terraform successfully applied or deployed. You will get a similar output as below
```bash
Apply complete! Resources: 19 added, 0 changed, 0 destroyed.

Outputs:

external_elb = TESTELB-597260835.eu-west-2.elb.amazonaws.com
webserver_private_ip = [
    10.120.1.166
]
webserver_public_ip = [
    35.178.158.90
]
```

6 - Show: Is used to provide human-readable output from a state or plan file
```bash
$ terraform show
```

7 - Destroy: destroy the Terraform-managed infrastructure
```bash
$ terraform destroy
```

The Elastic loadbalancer DNS can be found in the output:
-----------------------------------------------------------
```bash
Outputs:

external_elb = TESTELB-597260835.eu-west-2.elb.amazonaws.com
```

