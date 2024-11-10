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

resource "aws_key_pair" "api-ssh-key" {
  key_name   = "${local.project_name} key"
  public_key = file(var.ssh_key_path)
}

resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.project_name}-VPC"
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
  name        = "${local.project_name}-db-sg"
  vpc_id      = aws_vpc.main-vpc.id
  ingress {
    description = "HTTP ingress"
    from_port   = 5432
    to_port     = 5432
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

resource "aws_instance" "db-instance" {
  ami           = var.ami
  instance_type = local.instance_type
  subnet_id = aws_subnet.main-public-subnets[0].id
  security_groups = [aws_security_group.db-sg.id]
  associate_public_ip_address = true
  key_name      = aws_key_pair.api-ssh-key.key_name
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

    apt-get install -y postgresql-client

    sudo systemctl enable docker
    sudo systemctl start docker
    cat << 'EOL' > /home/ubuntu/docker-compose.yml
services:
  db:
    image: postgres
    restart: always
    shm_size: 128mb
    volumes:
      - ./volumes/postgresql:/var/lib/postgresql
    environment:
      POSTGRES_PASSWORD: ${var.db_password}
      POSTGRES_USER: postgres
      POSTGRES_DB: franquicias-manager
    ports:
      - 5432:5432
    EOL
    cd $HOME & sudo docker-compose up -d;
    PGPASSWORD=${var.db_password} psql -h localhost -U postgres -d franquicias-manager <<'SQL'
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
      CREATE OR REPLACE FUNCTION update_timestamp()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.updated_at = NOW();
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
      CREATE TABLE IF NOT EXISTS franquicias(
        id UUID DEFAULT uuid_generate_v4(),
        nombre VARCHAR(60) NOT NULL UNIQUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id)
      );
      CREATE INDEX idx_franquicias_nombre ON franquicias(nombre);
      CREATE TRIGGER set_franquicia_updated_at
      BEFORE UPDATE ON franquicias
      FOR EACH ROW
      EXECUTE FUNCTION update_timestamp();
      CREATE TABLE IF NOT EXISTS sucursales(
        id UUID DEFAULT uuid_generate_v4(),
        nombre VARCHAR(60) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        franquicia_id UUID NOT NULL,
        UNIQUE (nombre, franquicia_id),
        FOREIGN KEY (franquicia_id) REFERENCES franquicias(id),
        PRIMARY KEY (id)
      );
      CREATE INDEX idx_sucursales_franquicia ON sucursales(franquicia_id);
      CREATE INDEX idx_sucursales_nombre_franquicia ON sucursales(franquicia_id, nombre);
      CREATE TRIGGER set_sucursal_updated_at
      BEFORE UPDATE ON sucursales
      FOR EACH ROW
      EXECUTE FUNCTION update_timestamp();
      CREATE TABLE IF NOT EXISTS productos(
        id SERIAL,
        nombre VARCHAR(60) NOT NULL,
        stock INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        sucursal_id UUID NOT NULL,
        UNIQUE (nombre, sucursal_id),
        FOREIGN KEY (sucursal_id) REFERENCES sucursales(id)
      );
      CREATE INDEX idx_productos_sucursal ON productos(sucursal_id);
      CREATE INDEX idx_productos_nombre ON productos(nombre);
      CREATE INDEX idx_productos_stock ON productos(stock);
      CREATE INDEX idx_productos_nombre_sucursal ON productos(sucursal_id, nombre);
      CREATE TRIGGER set_producto_updated_at
      BEFORE UPDATE ON productos
      FOR EACH ROW
      EXECUTE FUNCTION update_timestamp();
    SQL
  EOF
  tags          = {
    Name = "${local.project_name}-db"
    Env  = var.env
  }
}

// INSTANCE


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

    apt-get install -y postgresql-client

    sudo systemctl enable docker
    sudo systemctl start docker

    DB_HOST="${aws_instance.db-instance.private_ip}"
    DB_PORT="5432"
    DB_PASSWORD="${var.db_password}"
    DB_USER="postgres"
    DB_DATABASE="franquicias-manager"
    sudo docker run --name franquicias-manager-api \
      -p 8080:8080 -d \
      -e DB_HOST=$DB_HOST \
      -e DB_PORT=$DB_PORT \
      -e DB_USER=$DB_USER \
      -e DB_DATABASE=$DB_DATABASE \
      -e DB_PASSWORD=$DB_PASSWORD \
      ghcr.io/jmvalenciz/franquicias-manager-api:latest
  EOF
  tags          = {
    Name = "${local.project_name}-api"
    Env  = var.env
  }
}
