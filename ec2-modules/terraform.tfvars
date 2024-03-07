aws_region             = "us-east-1"
ami                    = "ami-0c7217cdde317cfec"
instance_type          = "t2.micro"
key_name               = "Key-pair-cas"
vpc_security_group_ids = ["sg-07ab144116a039e0c"]
subnet_id              = "subnet-0eb45d5d34077f87b"
volume_size            = "10"
tags = {
  "id"             = "2555"
  "owner"          = "Casmaster"
  "teams"          = "DEL"
  "environment"    = "development"
  "project"        = "a1"
  "create_by"      = "Terraform"
  "cloud_provider" = "aws"
}
