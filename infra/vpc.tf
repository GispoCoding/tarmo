data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "2.77.0"
  name                 = "tarmo"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Project = "tarmo" }

}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name    = "tarmo-2-vpc"
    Project = "tarmo"
  }
}

resource "aws_subnet" "public" {
  count                   = var.public-subnet-count
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id

  tags = {
    Name       = "tarmo-public-subnet-${count.index}"
    SubnetType = "public"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "tarmo-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name       = "tarmo-public-route-table"
    SubnetType = "public"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = var.public-subnet-count
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}


resource "aws_db_subnet_group" "db" {
  name       = "tarmo-db"
  subnet_ids = module.vpc.public_subnets
}

# Security group for the public internet facing load balancer
resource "aws_security_group" "lb" {
  name        = "tarmo load balancer"
  description = "tarmo Load balancer security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "tarmo-lb-sg"
  }

}

# Https
resource "aws_security_group_rule" "lb-https" {
  count       = var.enable_route53_record ? 1 : 0
  description = "Load Balancer allow traffic using https"
  type        = "ingress"

  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.lb.id
}

# Security group for the backends that run the application.
# Allows traffic from the load balancer
resource "aws_security_group" "backend" {
  name        = "tarmo backend"
  description = "tarmo Backend security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = var.pg_tileserv_port
    to_port         = var.pg_tileserv_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tarmo-backend-sg"
  }

}


resource "aws_security_group" "rds" {
  name   = "tarmo-sg-rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
