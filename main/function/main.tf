locals {
  name_tag  = title(replace(var.name, "-", " "))
  file_path = "../target/lambda/${var.name}/bootstrap.zip"
}

### Function ###

resource "aws_lambda_function" "this" {
  function_name     = var.name
  description       = var.description
  handler           = var.handler
  s3_bucket         = var.bucket_name
  s3_key            = aws_s3_object.this.key
  s3_object_version = aws_s3_object.this.version_id
  runtime           = var.runtime
  architectures     = var.architectures
  timeout           = var.timeout
  role              = var.role

  environment {
    variables = var.env_variables
  }

  tags = {
    Name = local.name_tag
  }

  depends_on = [aws_cloudwatch_log_group.this]
}

### Function Code ###

resource "aws_s3_object" "this" {
  bucket      = var.bucket_name
  key         = "${var.name}/bootstrap.zip"
  source      = local.file_path
  source_hash = filemd5(local.file_path)

  tags = {
    Name = local.name_tag
  }

  depends_on = [terraform_data.build_function]
}

resource "terraform_data" "build_function" {
  triggers_replace = [
    fileexists(local.file_path)
  ]

  provisioner "local-exec" {
    command = !fileexists(local.file_path) ? "just build ${var.name}" : "echo 'Code file for `${var.name}` already exists'"
  }
}

### Log Group ###

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = 7
}
