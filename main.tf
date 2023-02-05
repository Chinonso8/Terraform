provider "aws" {
    region = "us-east-1"
}

#Creating VPC

resource "aws_vpc" "Project_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "Project_vpc"
  }
}

#Create Internet Gateway

resource "aws_internet_gateway" "Project_internet_gateway" {
   vpc_id = aws_vpc.Project_vpc.id
  tags = {
    Name = "Project_internet_gateway"
  }
}
  


# Create public Route Table

resource "aws_route_table" "Project-route-table-public" {
  vpc_id = aws_vpc.Project_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Project_internet_gateway.id
  }
  tags = {
    Name = "Project-route-table-public"
  }
}

# Associate public subnet 1 with public route table

resource "aws_route_table_association" "Project-public-subnet1-association" {
  subnet_id      = aws_subnet.Project-public-subnet1.id
  route_table_id = aws_route_table.Project-route-table-public.id
}

# Associate public subnet 2 with public route table
resource "aws_route_table_association" "Project-public-subnet2-association" {
  subnet_id      = aws_subnet.Project-public-subnet2.id
  route_table_id = aws_route_table.Project-route-table-public.id
}

# Create Public Subnet-1

resource "aws_subnet" "Project-public-subnet1" {
  vpc_id                  = aws_vpc.Project_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "Project-public-subnet1"
  }
}
# Create Public Subnet-2
resource "aws_subnet" "Project-public-subnet2" {
  vpc_id                  = aws_vpc.Project_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "Project-public-subnet2"
  }
}

resource "aws_network_acl" "Project-network_acl" {
  vpc_id     = aws_vpc.Project_vpc.id
  subnet_ids = [aws_subnet.Project-public-subnet1.id, aws_subnet.Project-public-subnet2.id]


ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

# Create a security group for the load balancer

resource "aws_security_group" "Project-load_balancer_sg" {
  name        = "Project-load-balancer-sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.Project_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Security Group to allow port 22, 80 and 443

resource "aws_security_group" "Project-security-grp-rule" {
  name        = "allow_ssh_http_https"
  description = "Allow SSH, HTTP and HTTPS inbound traffic for private instances"
  vpc_id      = aws_vpc.Project_vpc.id
 ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.Project-load_balancer_sg.id]
  }
 ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.Project-load_balancer_sg.id]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   
  }
  tags = {
    Name = "Project-security-grp-rule"
  }
}



