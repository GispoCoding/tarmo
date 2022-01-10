resource "aws_cloudwatch_log_group" "lambda_db_manager" {
  name              = "/aws/lambda/${aws_lambda_function.db_manager.function_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "lambda_lipas" {
  name              = "/aws/lambda/${aws_lambda_function.lipas_loader.function_name}"
  retention_in_days = 30
}
