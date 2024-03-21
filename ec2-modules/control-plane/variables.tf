variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to resources"
  default = {
    "id"             = "2555"
    "owner"          = "casmaster"
    "teams"          = "DEL"
    "environment"    = "sandbox"
    "project"        = "auto"
    "create_by"      = "Terraform"
    "cloud_provider" = "aws"
  }
}

variable "cluster_name" {
  type    = string
  default = "500-sandbox-dp"
}

variable "eks_version" {
  type    = string
  default = "1.26"
}

variable "endpoint_private_access" {
  type    = bool
  default = false
}

variable "endpoint_public_access" {
  type    = bool
  default = true
}

variable "public_subnets" {
  type = map(string)
  default = {
    us-east-1a = "subnet-0eb45d5d34077f87b"
    us-east-1b = "subnet-0fc6c00333c26be58"
    us-east-1c = "subnet-0eb45d5d34077f87b"
  }
}