# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.Parameters.html
# A parameter group cannot be deleted when linked to a db instance. For
# upgrading the database, we first create a new parameter group to link
# to, and delete the old one after the database upgrade is complete.
resource "aws_db_parameter_group" "tarmo_16" {
  name   = "${var.prefix}-params-16"
  family = "postgres16"

  parameter {
    name  = "log_connections"
    value = "1"
  }
  tags = local.default_tags
}

resource "aws_db_instance" "main_db" {
  identifier                      = "${var.tarmo_db_name}db"
  instance_class                  = var.db_instance_type
  allocated_storage               = var.db_storage
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  engine                          = "postgres"
  engine_version                  = var.db_postgres_version
  username                        = var.su_secrets.username
  password                        = var.su_secrets.password
  db_subnet_group_name            = aws_db_subnet_group.db.name
  vpc_security_group_ids          = [aws_security_group.rds.id]
  allow_major_version_upgrade     = true
  parameter_group_name            = aws_db_parameter_group.tarmo_16.name
  multi_az                        = false
  apply_immediately               = false
  publicly_accessible             = false
  skip_final_snapshot             = true
  deletion_protection             = true
  tags                            = local.default_tags
}
