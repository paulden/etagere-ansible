provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-1"
}

resource "aws_vpc" "etagere" {
  cidr_block = "10.4.0.0/16"

  enable_dns_hostnames = true

  tags = {
    Name = "etagere-terraform"
  }
}

resource "aws_subnet" "etagere" {
  vpc_id     = aws_vpc.etagere.id
  cidr_block = "10.4.0.0/25"

  tags = {
    Name = "etagere-terraform"
  }
}

resource "aws_internet_gateway" "etagere" {
  vpc_id = aws_vpc.etagere.id

  tags = {
    Name = "etagere-terraform"
  }
}

resource "aws_default_route_table" "etagere" {
  default_route_table_id = aws_vpc.etagere.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.etagere.id
  }
}

resource "aws_security_group" "etagere_default" {
  name        = "etagere-default"
  description = "Allow ssh and http"
  vpc_id      = aws_vpc.etagere.id

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "etagere_user" {
  count         = length(var.user_map)
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.etagere.id

  key_name = aws_key_pair.user[count.index].key_name

  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.etagere_default.id]

  tags = {
    "Trigramme" = "${element(keys(var.user_map), count.index)}"
    "Name"      = "etagere-${element(keys(var.user_map), count.index)}"
  }

  depends_on = [aws_key_pair.user]
}

resource "aws_key_pair" "user" {
  count      = length(var.user_map)
  key_name   = "etagere-${element(keys(var.user_map), count.index)}"
  public_key = element(values(var.user_map), count.index)
}
