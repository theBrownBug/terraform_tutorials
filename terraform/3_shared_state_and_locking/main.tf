provider "aws" {
  region = "us-east-1"
}

# this will tell Terraform to store the state in the S3 bucket
terraform {
  backend "s3" {
    # use the s3 bucket for storing state file
    bucket = "terraform-up-and-running-eeshan"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-1"

    # use the dynamo db table for locking
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}


/*
  The name of the shared state bucket should be globally unique
*/
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-eeshan"
  versioning {
    enabled = true
  }
  #enable server side encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  #prevent from getting un intentionally destroyed
  lifecycle {
    prevent_destroy = true
  }
}


/**

  Dynamo DB used for locking
*/

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}