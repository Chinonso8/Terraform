# creating instance 1

resource "aws_instance" "Project1" {
  ami             = "ami-00874d747dde814fa"
  instance_type   = "t2.micro"
  key_name        = "key"
  security_groups = [aws_security_group.Project-security-grp-rule.id]
  subnet_id       = aws_subnet.Project-public-subnet1.id
  availability_zone = "us-east-1a"
  tags = {
    Name   = "Project-1"
    source = "terraform"
  }
}
# creating instance 2
 resource "aws_instance" "Project2" {
  ami             = "ami-00874d747dde814fa"
  instance_type   = "t2.micro"
  key_name        = "key"
  security_groups = [aws_security_group.Project-security-grp-rule.id]
  subnet_id       = aws_subnet.Project-public-subnet2.id
  availability_zone = "us-east-1b"
  tags = {
    Name   = "Project-2"
    source = "terraform"
  }
}
# creating instance 3
resource "aws_instance" "Project3" {
  ami             = "ami-00874d747dde814fa"
  instance_type   = "t2.micro"
  key_name        = "key"
  security_groups = [aws_security_group.Project-security-grp-rule.id]
  subnet_id       = aws_subnet.Project-public-subnet1.id
  availability_zone = "us-east-1a"
  tags = {
    Name   = "Project-3"
    source = "terraform"
  }
}

# Create a file to store the IP addresses of the instances

resource "local_file" "Ip_address" {
  filename = "/etc/ansible/hosts"
  content  = <<EOT
${aws_instance.Project1.public_ip}
${aws_instance.Project2.public_ip}
${aws_instance.Project3.public_ip}
  EOT
}