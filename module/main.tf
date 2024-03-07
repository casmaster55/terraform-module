locals {
  select_ami = var.distribution == "ubuntu" ? data.aws_ami.ubuntu.id : null
}

resource "aws_instance" "vm" {
  ami                    = local.selected_ami != "" ? local.selected_ami : var.ami 
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.vpc_security_group_ids[0]]
  subnet_id              = var.subnet_id
  disable_api_termination = var.enable_termination_protection 
  root_block_device {
    volume_size = var.volume_size
  }
  tags = merge(var.tags, {
    Name = format("%s-%s-%s-bastion-host", var.tags["id"], var.tags["environment"], var.tags["project"])
    },
  )
}

module "s3_backend" {
  source          = "github.com/devopstia/terraform-course-del/aws-terraform/modules/s3-backend-with-replication"
  bucket_name     = "2555-development-s1-tf-state"
  dynamodb_table  = "your-dynamodb-table-name"
  region          = "us-east-1"
}



provider "aws" {
  region = "your_aws_region"
}

# Main S3 bucket for storing the Terraform state file
resource "aws_s3_bucket" "main_terraform_state" {
  bucket = "main-terraform-state-bucket"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 30
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "Main_Terraform_Bucket"
    Environment = "dev"
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform_locks_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# Backup S3 bucket in a different Availability Zone (AZ)
resource "aws_s3_bucket" "backup_terraform_state" {
  bucket = "2555-development-s1-tf-stat"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 30
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  replication_configuration {
    role = aws_iam_role.replication.arn

    rules {
      id     = "tf-state-replication"
      status = "Enabled"

      destination {
        bucket = aws_s3_bucket.main_terraform_state.arn
      }

      source_selection_criteria {
        replica_modifications {
          status = "Enabled"
        }
      }
    }
  }

  tags = {
    Name        = "Backup_Terraform_Bucket"
    Environment = "production"
  }
}

# IAM role for S3 replication
resource "aws_iam_role" "replication" {
  name = "s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "s3.amazonaws.com"
      }
    }]
  })
}

# IAM policy for S3 replication
resource "aws_iam_policy" "replication" {
  name        = "s3-replication-policy"
  description = "Policy for S3 replication"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = "s3:ReplicateObject",
      Effect   = "Allow",
      Resource = [
        aws_s3_bucket.main_terraform_state.arn,
        aws_s3_bucket.main_terraform_state.arn,
      ],
    }]
  })
}

# Attach policy to the IAM role
resource "aws_iam_role_policy_attachment" "replication" {
  policy_arn = aws_iam_policy.replication.arn
  role       = aws_iam_role.replication.name
}
