provider "aws" {
    region = "us-east-2"
}

# configure terraform backend to use s3 to store state and dynamydb for locking
terraform {
    backend "s3" {
        # TODO: test if I could I use a reference here instead of a string
        bucket = "dpaquette-terraform-up-and-running-state"
        key = "global/s3/terraform.tfstate"
        region = "us-east-2"
        
        dynamodb_table = "terraform-up-and-running-locks"
        encrypt = true
    }
}

# s3 bucket to store terraform state file
resource "aws_s3_bucket" "terraform_state" {
    bucket = "dpaquette-terraform-up-and-running-state"

    lifecycle {
        prevent_destroy = true
    }

    versioning {
        enabled = true
    }

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
}

# dynamoDB table for lock management
resource "aws_dynamodb_table" "terraform_locks" {
    name = "terraform-up-and-running-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}