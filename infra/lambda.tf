resource "aws_lambda_function" "db_manager" {
  function_name = "${var.prefix}-db_manager"
  filename      = "../backend/lambda_functions/db_manager.zip"
  runtime       = "python3.8"
  handler       = "db_manager.handler"
  memory_size   = 128
  timeout       = 120

  role = aws_iam_role.lambda_exec.arn
  vpc_config {
    subnet_ids         = data.aws_subnet_ids.private.ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      AWS_REGION_NAME     = var.AWS_REGION_NAME
      DB_INSTANCE_ADDRESS = aws_db_instance.main_db.address
      DB_MAIN_NAME        = var.tarmo_db_name
      DB_MAINTENANCE_NAME = "postgres"
      READ_FROM_AWS       = 1
      DB_SECRET_SU_ARN    = aws_secretsmanager_secret.tarmo-db-su.arn
      DB_SECRET_ADMIN_ARN = aws_secretsmanager_secret.tarmo-db-admin.arn
      DB_SECRET_R_ARN     = aws_secretsmanager_secret.tarmo-db-r.arn
      DB_SECRET_RW_ARN    = aws_secretsmanager_secret.tarmo-db-rw.arn
    }
  }
  tags = merge(local.default_tags, { Name = "${var.prefix}-db_manager" })
}

resource "aws_lambda_function" "lipas_loader" {
  function_name = "${var.prefix}-lipas_loader"
  filename      = "../backend/lambda_functions/lipas_loader.zip"
  runtime       = "python3.8"
  handler       = "app.lipas_loader.handler"
  memory_size   = 128
  timeout       = 900

  role = aws_iam_role.lambda_exec.arn
  vpc_config {
    subnet_ids         = data.aws_subnet_ids.private.ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      AWS_REGION_NAME     = var.AWS_REGION_NAME
      DB_INSTANCE_ADDRESS = aws_db_instance.main_db.address
      DB_MAIN_NAME        = var.tarmo_db_name
      READ_FROM_AWS       = 1
      DB_SECRET_RW_ARN    = aws_secretsmanager_secret.tarmo-db-rw.arn
    }
  }
  tags = merge(local.default_tags, { Name = "${var.prefix}-lipas_loader" })
}

resource "aws_lambda_permission" "cloudwatch_call_lipas_loader" {
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lipas_loader.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.lambda_lipas.arn
}

resource "aws_lambda_function" "osm_loader" {
  function_name = "${var.prefix}-osm_loader"
  filename      = "../backend/lambda_functions/osm_loader.zip"
  runtime       = "python3.8"
  handler       = "app.osm_loader.handler"
  memory_size   = 256
  timeout       = 900

  role = aws_iam_role.lambda_exec.arn
  vpc_config {
    subnet_ids         = data.aws_subnet_ids.private.ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      AWS_REGION_NAME     = var.AWS_REGION_NAME
      DB_INSTANCE_ADDRESS = aws_db_instance.main_db.address
      DB_MAIN_NAME        = var.tarmo_db_name
      READ_FROM_AWS       = 1
      DB_SECRET_RW_ARN    = aws_secretsmanager_secret.tarmo-db-rw.arn
    }
  }
  tags = merge(local.default_tags, { Name = "${var.prefix}-osm_loader" })
}

resource "aws_lambda_permission" "cloudwatch_call_osm_loader" {
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.osm_loader.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.lambda_osm.arn
}

resource "aws_lambda_function" "wfs_loader" {
  function_name = "${var.prefix}-wfs_loader"
  filename      = "../backend/lambda_functions/wfs_loader.zip"
  runtime       = "python3.8"
  handler       = "app.wfs_loader.handler"
  memory_size   = 128
  timeout       = 900

  role = aws_iam_role.lambda_exec.arn
  vpc_config {
    subnet_ids         = data.aws_subnet_ids.private.ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      AWS_REGION_NAME     = var.AWS_REGION_NAME
      DB_INSTANCE_ADDRESS = aws_db_instance.main_db.address
      DB_MAIN_NAME        = var.tarmo_db_name
      READ_FROM_AWS       = 1
      DB_SECRET_RW_ARN    = aws_secretsmanager_secret.tarmo-db-rw.arn
    }
  }
  tags = merge(local.default_tags, { Name = "${var.prefix}-wfs_loader" })
}

resource "aws_lambda_permission" "cloudwatch_call_wfs_loader" {
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.wfs_loader.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.lambda_wfs.arn
}

resource "aws_lambda_function" "arcgis_loader" {
  function_name = "${var.prefix}-arcgis_loader"
  filename      = "../backend/lambda_functions/arcgis_loader.zip"
  runtime       = "python3.8"
  handler       = "app.arcgis_loader.handler"
  memory_size   = 256
  timeout       = 900

  role = aws_iam_role.lambda_exec.arn
  vpc_config {
    subnet_ids         = data.aws_subnet_ids.private.ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      AWS_REGION_NAME     = var.AWS_REGION_NAME
      DB_INSTANCE_ADDRESS = aws_db_instance.main_db.address
      DB_MAIN_NAME        = var.tarmo_db_name
      READ_FROM_AWS       = 1
      DB_SECRET_RW_ARN    = aws_secretsmanager_secret.tarmo-db-rw.arn
    }
  }
  tags = merge(local.default_tags, { Name = "${var.prefix}-arcgis_loader" })
}

resource "aws_lambda_permission" "cloudwatch_call_arcgis_loader" {
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.arcgis_loader.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.lambda_arcgis.arn
}
