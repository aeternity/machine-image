# This file was autogenerated by the 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# Avoid mixing go templating calls ( for example ```{{ upper(`string`) }}``` )
# and HCL2 calls (for example '${ var.string_value_example }' ). They won't be
# executed together and the outcome will be unknown.

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.
variable "aws_access_key" {
  type    = string
  default = "${env("AWS_ACCESS_KEY_ID")}"
}

variable "aws_secret_key" {
  type    = string
  default = "${env("AWS_SECRET_ACCESS_KEY")}"
}

variable "postfix" {
  type    = string
  default = "${env("POSTFIX")}"
}

# The amazon-ami data block is generated from your amazon builder source_ami_filter; a data
# from this block can be referenced in source and locals blocks.
# Read the documentation for data blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/data
# Read the documentation for the Amazon AMI Data Source here:
# https://www.packer.io/docs/datasources/amazon/ami
data "amazon-ami" "autogenerated_1" {
  filters = {
    name                = "ubuntu/images/*ubuntu-bionic-18.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "us-west-2"
}

data "amazon-ami" "autogenerated_2" {
  filters = {
    name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "us-west-2"
}

# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "ubuntu-bionic" {
  ami_name              = "aeternity-ubuntu-18.04-v${local.timestamp}"
  ami_regions           = ["eu-central-1", "ap-southeast-1", "ap-southeast-2", "eu-west-2", "eu-north-1", "us-east-2"]
  force_delete_snapshot = true
  force_deregister      = true
  iam_instance_profile  = "epoch-packer-build"
  instance_type         = "t2.small"
  region                = "us-west-2"
  source_ami            = "${data.amazon-ami.autogenerated_1.id}"
  spot_price            = "0.2"
  ssh_username          = "ubuntu"
}

# could not parse template for following block: "template: hcl2_upgrade:3: function \"postfix\" not defined"

source "amazon-ebs" "ubuntu-focal" {
  ami_name              = "aeternity-ubuntu-20.04-v{{timestamp}}{{postfix}}"
  ami_regions           = ["eu-central-1", "ap-southeast-1", "ap-southeast-2", "eu-west-2", "eu-north-1", "us-east-2"]
  force_delete_snapshot = true
  force_deregister      = true
  iam_instance_profile  = "epoch-packer-build"
  instance_type         = "t2.small"
  region                = "us-west-2"
  source_ami            = "{{ data `amazon-ami.autogenerated_2.id` }}"
  spot_price            = "0.2"
  ssh_username          = "ubuntu"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.amazon-ebs.ubuntu-bionic", "source.amazon-ebs.ubuntu-focal"]

  provisioner "shell" {
    inline = ["sleep 30"]
  }

  provisioner "shell" {
    script = "${path.root}/scripts/apt-upgrade.sh"
  }

  provisioner "shell" {
    scripts = ["${path.root}/scripts/add-master-user.sh"]
  }

  provisioner "ansible" {
    extra_arguments = ["-e ansible_python_interpreter='/usr/bin/env python3'"]
    playbook_file   = "${path.root}/ansible/image-build.yml"
    user            = "ubuntu"
  }

}
