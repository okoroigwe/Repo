provider "aws" {
  region     = "us-east-1"
  profile = "Olisaemeka"
}


# Create a VPC
resource "aws_vpc" "proVPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main_VPC"
  }
}

# Create a subnet
resource "aws_subnet" "proSubnet" {
  vpc_id     = aws_vpc.proVPC.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = us-east-2a

  tags = {
    Name = "Main_Subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.proVPC.id

  tags = {
    Name = "main_IGW"
  }
}

# Create a security group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.proVPC.id

  ingress {
    description = "TLS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.proVPC.cidr_block]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.proVPC.cidr_block]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.proVPC.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

# Create a Route Table
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.proVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "main_RT"
  }
}

# Associate subnet to route table
resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.proSubnet.id
  route_table_id = aws_route_table.RT.id
}

# Create EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0fa3fe0fa7920f68e"
  instance_type = "t2.micro"

  key_name = "olisa_keypair"


  subnet_id = aws_subnet.proSubnet.id

  vpc_security_group_ids = [
    aws_security_group.allow_tls.id
  ]
   tags = {
    Name = "Olisa_Resource"}
}