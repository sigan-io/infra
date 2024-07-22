### AWS Managed Policies ###

data "aws_iam_policy" "lambda_vpc_execution_role" {
  name = "AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy" "efs_client_read_write_access" {
  name = "AmazonElasticFileSystemClientReadWriteAccess"
}

### Allow Function Invoke ###

resource "aws_iam_policy" "allow_function_invoke" {
  name        = "sigan-allow-function-invoke"
  description = "A policy that allows any function to be invoked"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:lambda:${local.region}:${local.account_id}:function:*"
      }
    ]
  })

  tags = {
    Name = "Allow Function Invoke"
  }
}

### Allow CloudWatch Logs ###

resource "aws_iam_policy" "allow_cloudwatch_logs" {
  name        = "sigan-allow-cloudwatch-logs"
  description = "A policy that allows writing logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  tags = {
    Name = "Allow CloudWatch Logs"
  }
}

### Allow S3 Read Access ###

resource "aws_iam_policy" "allow_s3_read_access" {
  name        = "sigan-allow-s3-read-access"
  description = "A policy that allows read access to S3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::*"
      }
    ]
  })

  tags = {
    Name = "Allow S3 Read Access"
  }
}

### Allow S3 Read/Write Access ###

resource "aws_iam_policy" "allow_s3_read_write_access" {
  name        = "sigan-allow-s3-read-write-access"
  description = "A policy that allows read and write access to any S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::*"
      }
    ]
  })

  tags = {
    Name = "Allow S3 Read/Write Access"
  }
}

### Allow DB Access ###

resource "aws_iam_policy" "allow_main_db_access" {
  name        = "sigan-allow-db-access"
  description = "A policy that allows access to the main database"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds-data:ExecuteSql",
          "rds-data:ExecuteStatement",
          "rds-data:BatchExecuteStatement",
          "rds-data:BeginTransaction",
          "rds-data:CommitTransaction",
          "rds-data:RollbackTransaction"
        ],
        Effect   = "Allow"
        Resource = module.main_aurora_cluster.cluster_arn
      }
    ]
  })
}
