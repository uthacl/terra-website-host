variable "cli_usr_access_key" {
  type    = string
  default = "access_key" # specify the access key
}
variable "cli_usr_secret_key" {
  type    = string
  default = "secret_key" # specify the secret key
}
variable "region" {
  type    = string
  default = "aws_region" # specify the region
}
variable "tags" {
  type        = map(string)
  description = "mapping of tags to assign to the instance"
  default = {
    terraform = "true"
    Name      = "terraform-instance"
  }
}
//variable "key_name" {
  //type        = string
  //description = "ssh key to connect to instance"
  //default     = "ssh_key_name" # specify the login key name
//}
variable "instance_type" {
  type        = string
  description = "instance type for the instance"
  default     = "instance_type" # specify the instance type
}
variable "ami_id" {
  type        = string
  description = "os image id for the instance. use free-tier ami id before runnning to avoid unwanted cost"
  default     = "ami-0cfedf42e63bba657" # specify the image id
}
variable "subnet_id" {
  type        = string
  description = "subnet id to launch the instance in"
  default     = "subnet_id" # specify the az id like ap-south-1a, or us-west-2a, or your choice
}
variable "vpc_id" {
  type        = string
  description = "vpc"
  default     = "vpc_id" # specify the vpc id
}
variable "availability_zone" {
  type        = string
  description = "az to start the instance in"
  default     = "availability_zone_id" # specify the az id
}
variable "instance_count" {
  type        = number
  description = "instances count. under free-tier we can have 3 ubuntuyes instances of 8 gb each "
  default     = 1 # specify the instances count
}

provider "aws" {
  region = "ap-south-1"
}


# creating security group
resource "aws_security_group" "ec2_sg" {
  vpc_id = "vpc-0e20adaa4a1db667c"
  ingress = [
    {
      # ssh port allowed from any ip
      description      = "ssh"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      # http port allowed from any ip
      description      = "http"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]
  egress = [
    {
      description      = "all-open"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]
  tags = {
    "Name"      = "terraform-ec2-SG"
    "terraform" = "true"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "my-keypair-ap-south-1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 vignesh.l@maxonclouds.com"
}

//resource "tls_private_key" "pk" {
  //algorithm = "RSA"
  //rsa_bits  = 4096
//}

//resource "aws_key_pair" "kp" {
  //key_name   = "terraform"       # Create a "myKey" to AWS!!
 // public_key = tls_private_key.pk.public_key_openssh
//}

//resource "local_file" "ssh_key" {
  //filename = "${aws_key_pair.kp.key_name}.pem"
  //content = tls_private_key.pk.private_key_pem
//}

# creating instance
resource "aws_instance" "terraform_instance" {
  ami           = "ami-0cfedf42e63bba657"
  instance_type = "t2.micro"
  key_name = "terraform"
  user_data                   = file("createwebsite.sh")
  associate_public_ip_address = true
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
    tags = {
      Name = "terraform-storage"
    }
  }
  tags = var.tags
}