provider "aws" {
    region = "us-east-2"
}

resource "aws_iam_user" "matrix_users" {
    count = length(var.usernames)
    name = var.usernames[count.index]
}