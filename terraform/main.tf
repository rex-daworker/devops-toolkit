terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# Your existing EC2 instance
data "aws_instance" "devops_ec2" {
  instance_id = "i-04a687aefbf0747ea"
}

output "instance_type" {
  value = data.aws_instance.devops_ec2.instance_type
}

output "instance_state" {
  value = data.aws_instance.devops_ec2.instance_state
}

output "public_ip" {
  value = data.aws_instance.devops_ec2.public_ip
}
