
provider "aws" {
    region = "us-east-2"
}

resource "aws_iam_user" "users" {
    for_each = toset(var.usernames)
    name = each.value
    
}