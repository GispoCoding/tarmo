data "aws_availability_zones" "available" {
  state = "available"
}

# This creates the vpc for the database
# module "vpc" {
#   source               = "terraform-aws-modules/vpc/aws"
#   version              = "2.77.0"
#   name                 = "tarmo"
#   cidr                 = "10.0.0.0/16"
#   azs                  = data.aws_availability_zones.available.names
#   # remove public subnets from the db
#   public_subnets       = ["10.0.1.0/24"]
#   enable_dns_hostnames = true
#   enable_dns_support   = true
#   tags                 = local.default_tags

# }

# Create common VPC for tile server, bastion, lambdas and rds
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = merge(local.default_tags, { "Name" : "${var.prefix}-vpc" })
}

resource "aws_subnet" "public" {
  # will have subnets the same # as availability zones
  # by default, we have eu-central-1a and eu-central-1b
  count                   = var.public-subnet-count
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name       = "${var.prefix}-public-subnet-${count.index}"
    SubnetType = "public"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name = "${var.prefix}-igw"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name = "${var.prefix}-public-route-table"
  })
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

resource "aws_subnet" "private" {
  # private subnets for the database instance and lambdas
  count                   = var.private-subnet-count
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  # what block should we use for the private subnets? is this alright?
  cidr_block              = "10.0.${count.index + 128}.0/24"
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name       = "${var.prefix}-private-subnet-${count.index}"
    SubnetType = "private"
  })
}

data "aws_subnet_ids" "private" {
  vpc_id  = aws_vpc.main.id
  tags = merge(local.default_tags, {
    SubnetType = "private"
  })
}

# Give lambdas access to Internet
resource "aws_eip" "eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.main]

  tags = merge(local.default_tags, {
    Name = "${var.prefix}-eip"
  })
}

# Use only one nat gateway for now (outbound traffic not that critical)
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(local.default_tags, {
    Name = "${var.prefix}-nat-gateway"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = merge(local.default_tags, {
    Name = "${var.prefix}-route-table-private"
  })
}

resource "aws_route_table_association" "private" {
  count          = var.private-subnet-count
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private[count.index].id
}

resource "aws_db_subnet_group" "db" {
  name       = "${var.prefix}-db"
  # only list private subnets in the db subnet group
  subnet_ids = data.aws_subnet_ids.private.ids

  tags = merge(local.default_tags, {
    Name = "${var.prefix}-db"
  })
}

# Security group for the public internet facing load balancer
resource "aws_security_group" "lb" {
  name        = "${var.prefix} load balancer"
  description = "${var.prefix} load balancer security group"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name = "${var.prefix}-lb-sg"
  })
}

# Http
resource "aws_security_group_rule" "lb-http" {
  description = "Load Balancer allow traffic using http"
  type        = "ingress"

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.lb.id
}

# Https
resource "aws_security_group_rule" "lb-https" {
  description = "Load Balancer allow traffic using https"
  type        = "ingress"

  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.lb.id
}

# Egress
resource "aws_security_group_rule" "lb-egress" {
  description = "Load Balancer allow traffic to Internet"
  type        = "egress"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.lb.id
}

# Security group for the backends that run the application.
# Allows traffic from the load balancer to tile server and tile cache
resource "aws_security_group" "backend" {
  name        = "${var.prefix} tile server"
  description = "${var.prefix} tile server security group"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.default_tags, {
    Name = "${var.prefix}-tileserver-sg"
  })
}

# Access to tile server from tile cache
resource "aws_security_group_rule" "tilecache-tileserv" {
  description = "Tile server allow traffic from tile cache"
  type        = "ingress"

  from_port   = 0
  to_port     = 0
  protocol    = -1
  self = true

  security_group_id = aws_security_group.backend.id
}

# Debug access to tile cache from bastion
resource "aws_security_group_rule" "tilecache-bastion" {
  description       = "Tile cache allow traffic from bastion"
  type              = "ingress"

  from_port         = 0
  to_port           = 0
  protocol          = -1

  source_security_group_id = aws_security_group.bastion.id
  security_group_id = aws_security_group.backend.id
}

# Access to tile server from lb
resource "aws_security_group_rule" "lb-tileserv" {
  description = "Tile server allow traffic from lb"
  type        = "ingress"

  from_port   = var.pg_tileserv_port
  to_port     = var.pg_tileserv_port
  protocol    = "tcp"

  source_security_group_id = aws_security_group.lb.id
  security_group_id = aws_security_group.backend.id
}

# Access to tile cache from lb
resource "aws_security_group_rule" "lb-varnish" {
  description = "Tile cache allow traffic from lb"
  type        = "ingress"

  from_port   = var.varnish_port
  to_port     = var.varnish_port
  protocol    = "tcp"

  source_security_group_id = aws_security_group.lb.id
  security_group_id = aws_security_group.backend.id
}

# Allows traffic to db and wherever lambdas need
resource "aws_security_group" "lambda" {
  name        = "${var.prefix} lambda"
  description = "${var.prefix} lambda security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    # allow traffic from the same security group
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    # allow all outbound traffic
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.default_tags, {
    Name = "${var.prefix}-lambda-sg"
  })
}

# Allows traffic from tileserver, lambdas and bastion to db
resource "aws_security_group" "rds" {
  name        = "${var.prefix} database"
  description = "${var.prefix} database security group"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name = "${var.prefix}-rds-sg"
  })
}

resource "aws_security_group_rule" "rds-tileserver" {
  description       = "Rds allow traffic from tileserver"
  type              = "ingress"

  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  # Cannot specify both cidr block and source security group
  #cidr_blocks       = ["10.0.0.0/16"]
  source_security_group_id = aws_security_group.backend.id
  security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rds-lambda" {
  description       = "Rds allow traffic from vpc"
  type              = "ingress"

  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  # Cannot specify both cidr block and source security group
  #cidr_blocks       = ["10.0.0.0/16"]
  source_security_group_id = aws_security_group.lambda.id
  security_group_id = aws_security_group.rds.id
}

# Allow traffic to bastion from the Internet
resource "aws_security_group" "bastion" {
  name   = "${var.prefix} bastion"
  description  = "${var.prefix} bastion security group"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name = "${var.prefix}-bastion-sg"
  })
}

resource "aws_security_group_rule" "internet-bastion" {
  description       = "Allow developers to access the bastion"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  protocol          = "tcp"
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "bastion-internet" {
  description       = "Allow bastion to access world (e.g. for installing postgresql client etc)"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = -1
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rds-bastion" {
  description       = "Rds allow traffic from bastion"
  type              = "ingress"

  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  # Cannot specify both cidr block and source security group
  # cidr_blocks       = ["10.0.0.0/16"]
  source_security_group_id = aws_security_group.bastion.id
  security_group_id = aws_security_group.rds.id
}
