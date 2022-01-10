# Retrieve user as a resource
data "aws_iam_user" "user" {
  user_name = var.AWS_S3_USER
}

# Create the policy to access the S3 bucket
resource "aws_iam_policy" "ci_policy" {
  name        = "github-ci-policy"
  path        = "/"
  description = "Github CI policy"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:DeleteObjectTagging",
          "s3:DeleteObjectVersion",
          "s3:DeleteObjectVersionTagging",
        ],
        Effect   = "Allow",
        Resource = [
          "${aws_s3_bucket.static_react_bucket.arn}/*"
        ]
      },
      {
        Action   = [
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = [
          aws_s3_bucket.static_react_bucket.arn
        ]
      },
    ]
  })
}

# Attach the policy to the user
resource "aws_iam_policy_attachment" "github_ci_attachment" {
  name       = "github-ci-attachment"
  users      = [data.aws_iam_user.user.user_name]
  policy_arn = aws_iam_policy.ci_policy.arn
}


# Lambda role
resource "aws_iam_role" "lambda_exec" {
  name               = "tarmo_serverless_lambda"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create the policy to access secrets manager in the region
resource "aws_iam_policy" "secrets-policy" {
  name        = "lambda-secrets-policy"
  path        = "/"
  description = "Lambda db secrets policy"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        Effect   = "Allow",
        Resource = [
          aws_secretsmanager_secret.tarmo-db-su.arn,
          aws_secretsmanager_secret.tarmo-db-admin.arn,
          aws_secretsmanager_secret.tarmo-db-rw.arn,
          aws_secretsmanager_secret.tarmo-db-r.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_secrets_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.secrets-policy.arn
}
