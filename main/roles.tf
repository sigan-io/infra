### Public Function ###

module "role_public_function" {
  source = "./role"

  name        = "public-function"
  description = "Sets the permissions for a public function."
  service     = "lambda"
  managed_policies = [
    aws_iam_policy.allow_cloudwatch_logs.arn
  ]
}

### API Gateway ###

module "role_api_gateway" {
  source = "./role"

  name        = "api-gateway"
  description = "Sets the permissions for an API Gateway."
  service     = "apigateway"
  managed_policies = [
    aws_iam_policy.allow_cloudwatch_logs.arn
  ]
}


### Users WP Function Role ###

module "role_user_wp_function" {
  source = "./role"

  name        = "user-wp-function"
  description = "Sets the permissions for a function running user's WordPress."
  service     = "lambda"
  managed_policies = [
    data.aws_iam_policy.lambda_vpc_execution_role.arn,
    data.aws_iam_policy.efs_client_read_write_access.arn,
    aws_iam_policy.allow_main_db_access.arn
  ]
}
