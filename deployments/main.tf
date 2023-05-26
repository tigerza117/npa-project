provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
  region     = var.region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.branch_prefix} VPC"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  egress {
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.branch_prefix} Security Group"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  depends_on              = [aws_vpc.main]

  tags = {
    Name = "${var.branch_prefix} Public Subnet A"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}b"
  map_public_ip_on_launch = true
  depends_on        = [aws_vpc.main]

  tags = {
    Name = "${var.branch_prefix} Public Subnet B"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.region}a"
  depends_on        = [aws_vpc.main]

  tags = {
    Name = "${var.branch_prefix} Private Subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id     = aws_vpc.main.id
  depends_on = [aws_vpc.main]

  tags = {
    Name = "${var.branch_prefix} Internet Gateway"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  depends_on = [aws_internet_gateway.main, aws_vpc.main]

  tags = {
    Name = "${var.branch_prefix} Public Route"
  }
}

resource "aws_route_table_association" "public_route_association_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_route.id
  depends_on     = [aws_subnet.public_a, aws_route_table.public_route]
}

resource "aws_route_table_association" "public_route_association_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_route.id
  depends_on     = [aws_subnet.public_b, aws_route_table.public_route]
}

output "vpc_id" {
  value = aws_vpc.main.id
}
output "vpc_name" {
  value = aws_vpc.main.tags.Name
}

output "public_subnet_a_id" {
  value = aws_subnet.public_a.id
}
output "public_subnet_a_name" {
  value = aws_subnet.public_a.tags.Name
}

output "public_subnet_b_id" {
  value = aws_subnet.public_b.id
}
output "public_subnet_b_name" {
  value = aws_subnet.public_b.tags.Name
}

output "private_subnet" {
  value = aws_subnet.private.id
}
output "private_subnet_name" {
  value = aws_subnet.private.tags.Name
}
