terraform {
    backend "s3" {
        bucket = "dpaquette-terraform-up-and-running-state"
        key = "stage/services/webserver-cluster/terraform.tfstate"
        region = "us-east-2"
        
        dynamodb_table = "terraform-up-and-running-locks"
        encrypt = true
    }
}

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

    target_group_arns = [aws_lb_target_group.mytarget-group.arn]
    health_check_type = "ELB"
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}


resource "aws_lb" "example" {
    name = "terraform-lb-example"
    load_balancer_type = "application"
    subnets = data.aws_subnet_ids.default.ids
    security_groups = [aws_security_group.alb_sg.id]
}

resource "aws_lb_listener" "example" {
    load_balancer_arn = aws_lb.example.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "fixed-response"
        fixed_response {
            content_type = "text/plain"
            message_body = "404: page not found"
            status_code = 404
        }
    }
}

resource "aws_security_group" "alb_sg" {
    name = "terraform-alb-sg"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}

resource "aws_lb_target_group" "mytarget-group" {
    name = "terraform-example-target-group"
    port = var.http_port
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id
    
    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb_listener_rule" "lblistenerrule" {
    listener_arn = aws_lb_listener.example.arn
    priority = 100
    # testing
    condition {
        field = "path-pattern"
        values = ["*"]
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.mytarget-group.arn
    }
  
}
