provider "aws" {
  region     = "eu-west-3"
  access_key = ""
  secret_key = ""
}

variable "cidr_blocks" {
  description = "cidr blocks and name tags for vpc and subnets"
  type = list(object({
    cidr_block = string
    name       = string
  }))
}

# export TF_VAR_avail_zone="eu-west-3a" in cli
variable "avail_zone" {
  default = "eu-west-3a"
}

# CREATE A VPC
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.cidr_blocks[0].cidr_block
  tags = {
    Name = var.cidr_blocks[0].name
  }
}

# CREATE A SUBNET IN THE NEW VPC
resource "aws_subnet" "myapp-subnet-1" {
  vpc_id            = aws_vpc.myapp-vpc.id
  cidr_block        = var.cidr_blocks[1].cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = var.cidr_blocks[1].name
  }
}

output "dev-vpc-id" {
  value = aws_vpc.myapp-vpc.id
}

output "dev-subnet-id" {
  value = aws_subnet.myapp-subnet-1.id
}

# GET THE DEFAULT VPC FROM AZ
data "aws_vpc" "existing_vpc" {
  default = true
}

# CREATE A SUBNET IN THE DEFAULT AZ
resource "aws_subnet" "dev-subnet-2" {
  vpc_id            = data.aws_vpc.existing_vpc.id
  cidr_block        = "172.31.48.0/20"
  availability_zone = "eu-west-3a"
  tags = {
    Name = "subnet-2-default"
  }
}
