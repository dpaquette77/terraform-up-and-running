terraform {
    backend "s3" {
        bucket = "dpaquette-terraform-up-and-running-state"
        key = "workspaces-example/terraform.tfstate"
        region = "us-east-2"
        dynamodb_table = "terraform-up-and-running-locks"
        encrypt = true
    }
}

resource "aws_instance" "example" { 
    ami = "ami-0c55b159cbfafe1f0" 
    instance_type = terraform.workspace == "default" ? "t2.micro" : "t2.nano" 
}