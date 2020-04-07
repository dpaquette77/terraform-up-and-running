provider "aws" {
    region = "us-east-2"
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
}