resource "aws_lambda_function" "db_manager" {
  function_name = "db_manager"
  filename      = "../backend/lambda_functions/db_manager.zip"
  runtime       = "python3.8"
  handler       = "db_manager.handler"
  memory_size   = 128
  timeout       = 120

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      AWS_REGION_NAME     = var.AWS_REGION_NAME
      DB_INSTANCE_ADDRESS = aws_db_instance.main_db.address
      DB_MAIN_NAME        = var.tarmo_db_name
      DB_MAINTENANCE_NAME = "postgres"
      DB_SECRET_SU_ARN    = aws_secretsmanager_secret.tarmo-db-su.arn
      DB_SECRET_ADMIN_ARN = aws_secretsmanager_secret.tarmo-db-admin.arn
      DB_SECRET_R_ARN     = aws_secretsmanager_secret.tarmo-db-r.arn
      DB_SECRET_RW_ARN    = aws_secretsmanager_secret.tarmo-db-rw.arn
    }
  }
  tags = merge(local.default_tags, { Name = "${var.prefix}-db_manager" })
}

resource "aws_lambda_function" "lipas_loader" {
  function_name = "lipas_loader"
  filename      = "../backend/lambda_functions/lipas_loader.zip"
  runtime       = "python3.8"
  handler       = "lipas_loader.handler"
  memory_size   = 128
  timeout       = 900

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      AWS_REGION_NAME     = var.AWS_REGION_NAME
      DB_INSTANCE_ADDRESS = aws_db_instance.main_db.address
      DB_MAIN_NAME        = var.tarmo_db_name
      DB_SECRET_RW_ARN    = aws_secretsmanager_secret.tarmo-db-rw.arn
    }
  }
  tags = merge(local.default_tags, { Name = "${var.prefix}-lipas_loader" })
}

resource "aws_lambda_function" "osm_loader" {
  function_name = "osm_loader"
  filename      = "../backend/lambda_functions/osm_loader.zip"
  runtime       = "python3.8"
  handler       = "osm_loader.handler"
  memory_size   = 128
  timeout       = 900

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      AWS_REGION_NAME     = var.AWS_REGION_NAME
      DB_INSTANCE_ADDRESS = aws_db_instance.main_db.address
      DB_MAIN_NAME        = var.tarmo_db_name
      DB_SECRET_RW_ARN    = aws_secretsmanager_secret.tarmo-db-rw.arn
    }
  }
  tags = merge(local.default_tags, { Name = "${var.prefix}-osm_loader" })
}
