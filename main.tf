provider "aws" {
  region = var.region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
  tags       = var.tags
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet_cidr_block
  availability_zone = "${var.region}a"
  tags              = merge(var.tags, { Name = "Public Subnet" })
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr_blocks[0] # Adjust as per your requirement
  availability_zone = "${var.region}a"
  tags              = merge(var.tags, { Name = "Private Subnet" })
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = merge(var.tags, { Name = "Public Route Table" })
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "lb_security_group" {
  name        = "lb-security-group"
  description = "Security group for load balancers"

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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "instance_security_group" {
  name        = "instance-security-group"
  description = "Security group for instances"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
   cidr_blocks = ["10.144.17.0/26"]  //Your-Management-IP-Range
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["10.144.17.0/26"]  //Your-Management-IP-Rang
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

