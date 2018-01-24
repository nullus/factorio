provider "aws" {
    version = "~> 1.7"   
    region = "ap-southeast-2"
}

data "aws_ami" "ubuntu" {
    owners = ["099720109477"]
    most_recent = true
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name = "root-device-type"
        values = ["ebs"] 
    }
    filter {
        name = "name"
        values = ["ubuntu/images/*/ubuntu-xenial-*-amd64-server-*"]
    }
}

#
# Administration configuration
#
data "aws_security_group" "admin_group" {
    # id = "sg-1f04ac7b"
    name = "greeves"
    vpc_id = "vpc-ee96488b"
}

resource "aws_key_pair" "admin_key" {
    key_name = "admin_key"
    public_key = "${file("id_rsa.pub")}"
}

#
# Server/service level security groups
#
resource "aws_security_group" "factorio" {
    name = "factorio"
    description = "Allow inbound factorio traffic"
    ingress {
        from_port   = 34197
        to_port     = 34197
        protocol    = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "factorio" {
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "c4.large"
    key_name = "${aws_key_pair.admin_key.key_name}"
    vpc_security_group_ids = ["${data.aws_security_group.admin_group.id}", "${aws_security_group.factorio.id}"]
    tags {
        Name = "factorio"
    }
    user_data = "${file("run_factorio.yaml")}"
}

