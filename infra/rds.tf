resource "aws_db_parameter_group" "tarmo" {
  name   = "education"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
  tags = local.default_tags
}

resource "aws_db_instance" "main_db" {
  identifier             = "tarmodb"
  instance_class         = var.db_instance_type
  allocated_storage      = var.db_storage
  engine                 = "postgres"
  engine_version         = var.db_postgres_version
  username               = var.su_secrets.username
  password               = var.su_secrets.password
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.tarmo.name
  multi_az               = false
  apply_immediately      = true # TODO: remove when in "production"
  publicly_accessible    = true
  skip_final_snapshot    = true
  tags                   = local.default_tags
}
