
variable "public_subnet_count" {
  type    = number
  default = 3
}

variable "private_subnet_count" {
  type    = number
  default = 3
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block         = var.vpc_cidr_block
  availability_zones     = var.availability_zones
  public_subnet_count    = var.public_subnet_count
  private_subnet_count   = var.private_subnet_count
}




variable "vpc_cidr_block" {}
variable "availability_zones" {}
variable "public_subnet_count" {}
variable "private_subnet_count" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "MainVPC"
  }
}

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index + 100)
  availability_zone       = var.availability_zones[count.index]

  tags = {
    Name = "PrivateSubnet-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat" {
  count = var.private_subnet_count

  allocation_id = aws_instance.nat[count.index].network_interface_ids[0]
  subnet_id     = aws_subnet.public[count.index].id
}

resource "aws_instance" "nat" {
  count = var.private_subnet_count

  ami           = "ami-0c7217cdde317cfec" 
  instance_type = "t2.micro"

  network_interface {
    subnet_id = aws_subnet.public[count.index].id
  }
}

resource "aws_lb" "alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB-Security-Group"
  }
}
