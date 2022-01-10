resource "aws_lambda_function" "db_manager" {
  function_name = "db_manager"
  filename      = "../backend/lambda_functions/db_manager.zip"
  runtime       = "python3.8"
  handler       = "db_manager.handler"
  memory_size   = 128
  timeout       = 120

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_function" "lipas_loader" {
  function_name = "lipas_loader"
  filename      = "../backend/lambda_functions/lipas_loader.zip"
  runtime       = "python3.8"
  handler       = "lipas_loader.handler"
  memory_size   = 128
  timeout       = 900

  role = aws_iam_role.lambda_exec.arn
}
