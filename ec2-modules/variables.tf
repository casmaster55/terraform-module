variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ami" {
  type    = string
  default = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = "Key-pair-cas"
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = ["sg-07ab144116a039e0c"]
}

variable "subnet_id" {
  type    = string
  default = "subnet-0eb45d5d34077f87b"
}

variable "volume_size" {
  type    = string
  default = "10"
}

variable "public_subnet_count" {
  type    = number
  default = 3
}

variable "private_subnet_count" {
  type    = number
  default = 3
}

variable "distribution" {
  type    = string
  default = " "
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "eip_count" {
  type    = number
  default = 3
}

variable "tags" {
  type = map(any)
  default = {
    "id"             = "2555"
    "owner"          = "Casmaster"
    "teams"          = "DEL"
    "environment"    = "development"
    "project"        = "a1"
    "create_by"      = "Terraform"
    "cloud_provider" = "aws"
  }
}
