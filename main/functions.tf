### Create Account ###

module "function_account_create" {
  source = "./function"

  name        = "account-create"
  description = "Creates a user account."
  bucket_name = module.bucket_functions_code.bucket_name
  role        = module.role_public_function.role_arn
  env_variables = tomap({
    USER_POOL_CLIENT_ID = aws_cognito_user_pool_client.this.id
  })
}

### Confirm Account ###

module "function_account_confirm" {
  source = "./function"

  name        = "account-confirm"
  description = "Confirms a user account."
  bucket_name = module.bucket_functions_code.bucket_name
  role        = module.role_public_function.role_arn
  env_variables = tomap({
    USER_POOL_CLIENT_ID = aws_cognito_user_pool_client.this.id
  })
}
