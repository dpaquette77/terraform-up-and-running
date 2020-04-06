provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instanance"
    ingress {
        from_port = var.http_port
        to_port = var.http_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}

variable "http_port" {
    description = "port on which the HTTP server listens on"
    type = number
    default = 8080
    
}

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "The public ip of the instance where the webserver is running"
}

resource "aws_launch_configuration" "example" {
    image_id = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instance.id]
    user_data = <<EOF
#!/bin/bash
echo "hello world" > index.html
nohup busybox httpd -f -p ${var.http_port} &
EOF

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.name
    min_size = 2
    max_size = 3
    vpc_zone_identifier = data.aws_subnet_ids.default.ids

    tag {
        key = "Name"
        value = "terraform-autoscaling example"
        propagate_at_launch = true
    }

    
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}
