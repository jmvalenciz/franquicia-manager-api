locals {
  instance_type = "t2.micro"
  subnet = "subnet-76a8163a"
  project_name = "franquicias-manager"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${local.project_name} VPC"
    Env  = var.env
  }
}

resource "aws_internet_gateway" "main-igw" {
 vpc_id = aws_vpc.main-vpc.id
 tags = {
   Name = "${local.project_name} IG"
    Env  = var.env
 }
}

resource "aws_route_table" "second_rt" {
 vpc_id = aws_vpc.main-vpc.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.main-igw.id
 }
 tags = {
   Name = "Second Route Table"
    Env = var.env
 }
}

resource "aws_subnet" "main-public-subnets" {
  count      = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.az, count.index)
  tags = {
    Name = "Public Subnet ${count.index + 1}"
    Env  = var.env
  }
}
resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.main-public-subnets[*].id, count.index)
 route_table_id = aws_route_table.second_rt.id
}

resource "aws_subnet" "main-private-subnets" {
  count      = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.az, count.index)
  tags = {
    Name = "Private Subnet ${count.index + 1}"
    Env  = var.env
  }
}

// DATABASE

resource "aws_security_group" "db-sg" {
  name   = "${local.project_name}-db-sg"
  vpc_id = aws_vpc.main-vpc.id
  ingress {
    description      = "Allow access from API instance"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [aws_security_group.api-sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "api-db-subnet-group" {
  name       = "${local.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.main-private-subnets[0].id, aws_subnet.main-private-subnets[1].id]
  tags = {
    Name = "${local.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "api-db" {
  identifier             = "${local.project_name}-db"
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  db_subnet_group_name   = aws_db_subnet_group.api-db-subnet-group.name
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "16.4"
  username               = "franquicias_manager_db"
  password               = var.db_password
  publicly_accessible    = false
  skip_final_snapshot    = true
}

// INSTANCE

resource "aws_key_pair" "api-ssh-key" {
  key_name   = "${local.project_name} key"
  public_key = file("~/.ssh/franquicias-manager-key.pub")
}

resource "aws_security_group" "api-sg" {
  name        = "${local.project_name}-sg"
  vpc_id      = aws_vpc.main-vpc.id
  ingress {
    description = "HTTP ingress"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH ingress"
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
}

resource "aws_instance" "api-instance" {
  ami           = var.ami
  instance_type = local.instance_type
  subnet_id = aws_subnet.main-public-subnets[0].id
  security_groups = [aws_security_group.api-sg.id]
  associate_public_ip_address = true
  key_name      = aws_key_pair.api-ssh-key.key_name
  // Script para instalar docker e iniciar el contenedor
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo systemctl enable docker
    sudo systemctl start docker

    DB_HOST="${aws_db_instance.api-db.endpoint}"
    sudo docker run --name franquicias-manager-api \
      -p 8080:8080 -d \
      -e DB_HOST=$DB_HOST \
      localhost/franquicias-manager-api:0.0.1
  EOF
  tags          = {
    Name = "${local.project_name}-api"
    Env  = var.env
  }
}
