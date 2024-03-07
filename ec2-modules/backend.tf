# terraform {
#   backend "s3" {
#     bucket         = ""
#     dynamodb_table = ""
#     key            = ""
#     region         = ""
#   }
# }
module "s3_backend" {
  source          = "github.com/devopstia/terraform-course-del/aws-terraform/modules/s3-backend-with-replication"
  bucket_name     = "2555-development-s1-tf-state"
  dynamodb_table  = "dyamodb_table_55"
  region          = "us-east-1"
}