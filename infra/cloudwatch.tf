resource "aws_cloudwatch_log_group" "lambda_db_manager" {
  name              = "/aws/lambda/${aws_lambda_function.db_manager.function_name}"
  retention_in_days = 30
  tags = local.default_tags
}

resource "aws_cloudwatch_log_group" "lambda_lipas" {
  name              = "/aws/lambda/${aws_lambda_function.lipas_loader.function_name}"
  retention_in_days = 30
  tags = local.default_tags
}

resource "aws_cloudwatch_log_group" "lambda_osm" {
  name              = "/aws/lambda/${aws_lambda_function.osm_loader.function_name}"
  retention_in_days = 30
  tags              = local.default_tags
}

resource "aws_cloudwatch_log_group" "lambda_wfs" {
  name              = "/aws/lambda/${aws_lambda_function.wfs_loader.function_name}"
  retention_in_days = 30
  tags              = local.default_tags
}

# not tested yet, probably won't work
resource "aws_cloudwatch_event_rule" "lambda_lipas" {
  name        = "Tarmo-lambda-lipas-update"
  description = "Run lipas import every night"
  schedule_expression = "cron(0 4 * * ? *)"
}

# not tested yet, probably won't work
resource "aws_cloudwatch_event_target" "lambda_lipas" {
  target_id = "load_lipas"
  rule      = aws_cloudwatch_event_rule.lambda_lipas.name
  arn       = aws_lambda_function.lipas_loader.arn
}
