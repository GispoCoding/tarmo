# Database secrets
resource "aws_secretsmanager_secret" "tarmo-db-su" {
  name = "${var.prefix}-postgres-database-su"
  tags = merge(local.default_tags, {Name = "${var.prefix}-postgres-database-su"})
}

resource "aws_secretsmanager_secret_version" "tarmo-db-su" {
  secret_id     = aws_secretsmanager_secret.tarmo-db-su.id
  secret_string = jsonencode(var.su_secrets)
}

resource "aws_secretsmanager_secret" "tarmo-db-admin" {
  name = "${var.prefix}-postgres-database-admin"
  tags = merge(local.default_tags, {Name = "${var.prefix}-postgres-database-admin"})
}

resource "aws_secretsmanager_secret_version" "tarmo-db-admin" {
  secret_id     = aws_secretsmanager_secret.tarmo-db-admin.id
  secret_string = jsonencode(var.tarmo_admin_secrets)
}

resource "aws_secretsmanager_secret" "tarmo-db-rw" {
  name = "${var.prefix}-postgres-database-rw"
  tags = merge(local.default_tags, {Name = "${var.prefix}-postgres-database-rw"})
}

resource "aws_secretsmanager_secret_version" "tarmo-db-rw" {
  secret_id     = aws_secretsmanager_secret.tarmo-db-rw.id
  secret_string = jsonencode(var.tarmo_rw_secrets)
}

resource "aws_secretsmanager_secret" "tarmo-db-r" {
  name = "${var.prefix}-postgres-database-r"
  tags = merge(local.default_tags, {Name = "${var.prefix}-postgres-database-r"})
}

resource "aws_secretsmanager_secret_version" "tarmo-db-r" {
  secret_id     = aws_secretsmanager_secret.tarmo-db-r.id
  secret_string = jsonencode(var.tarmo_r_secrets)
}
