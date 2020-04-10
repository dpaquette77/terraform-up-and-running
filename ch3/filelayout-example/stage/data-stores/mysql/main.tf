terraform {
    backend = "s3"
    bucket = "dpaquette-terraform-up-and-running-state"
    key = "stage/services/data-stores/mysql/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
}

provider "aws" {
    region = "us-east-2"
}
resources "aws_db_instance" "example" {
    identifier_prefix = "terraform-up-and-running"
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t2.micro"
    name = "example_database"
    username = "admin"
    password = "???"
}