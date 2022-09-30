resource "aws_db_parameter_group" "tarmo" {
  name   = "${var.prefix}-params"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
  tags = local.default_tags
}

resource "aws_db_instance" "main_db" {
  identifier             = "${var.tarmo_db_name}db"
  instance_class         = var.db_instance_type
  allocated_storage      = var.db_storage
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  engine                 = "postgres"
  engine_version         = var.db_postgres_version
  username               = var.su_secrets.username
  password               = var.su_secrets.password
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.tarmo.name
  multi_az               = false
  apply_immediately      = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = true
  tags                   = local.default_tags
}
