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

resource "aws_cloudwatch_event_rule" "lambda_lipas" {
  name        = "Tarmo-lambda-lipas-update"
  description = "Run lipas import every night"
  schedule_expression = "cron(0 4 * * ? *)"
  tags              = local.default_tags
}

resource "aws_cloudwatch_event_target" "lambda_lipas" {
  target_id = "load_lipas"
  rule      = aws_cloudwatch_event_rule.lambda_lipas.name
  arn       = aws_lambda_function.lipas_loader.arn
  input     = "{\"close_to_lon\": 23.7634608, \"close_to_lat\": 61.4976505, \"radius\": 100}"
}

resource "aws_cloudwatch_event_rule" "lambda_wfs" {
  name        = "Tarmo-lambda-wfs-update"
  description = "Run wfs import every night"
  schedule_expression = "cron(15 4 * * ? *)"
  tags              = local.default_tags
}

resource "aws_cloudwatch_event_target" "lambda_wfs" {
  target_id = "load_wfs"
  rule      = aws_cloudwatch_event_rule.lambda_wfs.name
  arn       = aws_lambda_function.wfs_loader.arn
}

resource "aws_cloudwatch_event_rule" "lambda_osm" {
  name        = "Tarmo-lambda-osm-update"
  description = "Run osm import every night"
  schedule_expression = "cron(30 4 * * ? *)"
  tags              = local.default_tags
}

resource "aws_cloudwatch_event_target" "lambda_osm" {
  target_id = "load_osm"
  rule      = aws_cloudwatch_event_rule.lambda_osm.name
  arn       = aws_lambda_function.osm_loader.arn
  input     = "{\"close_to_lon\": 23.7634608, \"close_to_lat\": 61.4976505, \"radius\": 20}"
}

resource "aws_cloudwatch_event_rule" "lambda_arcgis" {
  name        = "Tarmo-lambda-arcgis-update"
  description = "Run arcgis import every night"
  schedule_expression = "cron(45 4 * * ? *)"
  tags              = local.default_tags
}

resource "aws_cloudwatch_event_target" "lambda_arcgis" {
  target_id = "load_arcgis"
  rule      = aws_cloudwatch_event_rule.lambda_arcgis.name
  arn       = aws_lambda_function.arcgis_loader.arn
  input     = "{\"close_to_lon\": 23.7634608, \"close_to_lat\": 61.4976505, \"radius\": 100}"
}
