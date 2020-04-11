provider "aws" {
    region = "us-east-2"
}

resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "my_vpc"
    }
}

# internet gateway
resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name = "my_igw"
    }
}

# public route table 
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.my_vpc.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }

    tags = {
        Name = "public_rt"
    }
}

# private route table
resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name = "private_rt"
    }
}

# public subnet 1
resource "aws_subnet" "pub_sn_a" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-2a"
    tags = {
        Name = "pub_sn_a"
    }
}

# public subnet 2
resource "aws_subnet" "pub_sn_b" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-2b"
    tags = {
        Name = "pub_sn_b"
    }
}

# private subnet 1
resource "aws_subnet" "pri_sn_a" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-2a"
    tags = {
        Name = "pri_sn_a"
    }
}

# private subnet 2
resource "aws_subnet" "pri_sn_b" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-2b"
    tags = {
        Name = "pri_sn_b"
    }
}

# pub_sn_a to public_rt association
resource "aws_route_table_association" "public_association_a" {
    subnet_id = aws_subnet.pub_sn_a.id
    route_table_id = aws_route_table.public_rt.id
}

# pub_sn_b to public_rt association
resource "aws_route_table_association" "public_association_b" {
    subnet_id = aws_subnet.pub_sn_b.id
    route_table_id = aws_route_table.public_rt.id
}

# pri_sn_a to private_rt association
resource "aws_route_table_association" "private_association_a" {
    subnet_id = aws_subnet.pri_sn_a.id
    route_table_id = aws_route_table.private_rt.id
}

# pri_sn_b to private_rt association
resource "aws_route_table_association" "private_association_b" {
    subnet_id = aws_subnet.pri_sn_b.id
    route_table_id = aws_route_table.private_rt.id
}


