provider "aws" {
    region = "us-east-2"
}

resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "my_vpc"
    }
}

# data source to access the possible availability zones in this region
data "aws_availability_zones" "available" {
    state = "available"
}

# internet gateway
resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name = "my_igw"
    }
}

# EIP for nat gw in pri_sn_a
resource "aws_eip" "eip_a" { 
    vpc = true
}

# EIP for nat gw in pri_sn_b
resource "aws_eip" "eip_b" { 
    vpc = true
}

# nat gateway for pri_sn_a
resource "aws_nat_gateway" "nat_gw_a" {
    allocation_id = aws_eip.eip_a.id
    subnet_id = aws_subnet.pri_sn_a.id
}

# nat gateway for pri_sn_b
resource "aws_nat_gateway" "nat_gw_b" {
    allocation_id = aws_eip.eip_b.id
    subnet_id = aws_subnet.pri_sn_b.id
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

# private route table a
resource "aws_route_table" "private_rt_a" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat_gw_a.id
    }

    tags = {
        Name = "private_rt_a"
    }
}

# private route table b
resource "aws_route_table" "private_rt_b" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat_gw_b.id
    }

    tags = {
        Name = "private_rt_b"
    }
}

# public subnet 1
resource "aws_subnet" "pub_sn_a" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available[0]
    tags = {
        Name = "pub_sn_a"
    }
}

# public subnet 2
resource "aws_subnet" "pub_sn_b" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available[1]
    tags = {
        Name = "pub_sn_b"
    }
}

# private subnet 1
resource "aws_subnet" "pri_sn_a" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = data.aws_availability_zones.available[0]
    tags = {
        Name = "pri_sn_a"
    }
}

# private subnet 2
resource "aws_subnet" "pri_sn_b" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = data.aws_availability_zones.available[1]
    tags = {
        Name = "pri_sn_b"
    }
}

# nacl associated with all public subnets
resource "aws_network_acl" "public_nacl" {
    vpc_id = aws_vpc.my_vpc.id

    ingress {
        protocol = "tcp"
        rule_no = 200
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 8080
        to_port = 8080
    }
    egress {
        protocol = "-1"
        rule_no = 200
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }

    subnet_ids = [aws_subnet.pub_sn_a.id, aws_subnet.pub_sn_b.id]

    tags = {
        Name = "public_nacl"
    }
}

# nacl associated with all private subnets
resource "aws_network_acl" "private_nacl" {
    vpc_id = aws_vpc.my_vpc.id

    ingress {
        protocol = "tcp"
        rule_no = 200
        action = "allow"
        cidr_block = "10.0.0.0/16"
        from_port = 8080
        to_port = 8080
    }
    egress {
        protocol = "-1"
        rule_no = 200
        action = "allow"
        cidr_block = "10.0.0.0/16"
        from_port = 0
        to_port = 0
    }

    subnet_ids = [aws_subnet.pri_sn_a.id, aws_subnet.pri_sn_b.id]

    tags = {
        Name = "private_nacl"
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

# pri_sn_a to private_rt_a association
resource "aws_route_table_association" "private_association_a" {
    subnet_id = aws_subnet.pri_sn_a.id
    route_table_id = aws_route_table.private_rt_a.id
}

# pri_sn_b to private_rt_b association
resource "aws_route_table_association" "private_association_b" {
    subnet_id = aws_subnet.pri_sn_b.id
    route_table_id = aws_route_table.private_rt_b.id
}


