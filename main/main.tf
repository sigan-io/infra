### Data Sources ###

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}
data "terraform_remote_state" "sigan_dns" {
  backend = "s3"
  config = {
    bucket = "sigan-infrastructure"
    key    = "sigan_dns.tfstate"
    region = "us-east-1"
  }
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  rest_api_domain_name        = "api.sigan.io"
  rest_api_domain_certificate = data.terraform_remote_state.sigan_dns.outputs.certificates.wildcard_sigan_io
}

### Buckets ###

module "bucket_functions_code" {
  source = "./bucket"

  name              = "sigan-functions-code"
  force_destroy     = true
  enable_versioning = true
}

module "bucket_wp_versions" {
  source = "./bucket"

  name              = "sigan-wp-versions"
  force_destroy     = true
  enable_versioning = false
}

module "bucket_wp_contents" {
  source = "./bucket"

  name              = "sigan-wp-contents"
  force_destroy     = true
  enable_versioning = false
}

# Temp bucket until we improve the runtime.
module "bucket_runtime_code" {
  source = "./bucket"

  name              = "sigan-runtime-code"
  force_destroy     = true
  enable_versioning = true
}

### Network ###

module "main_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.3"

  name = "main-vpc"
  cidr = "10.0.0.0/16"

  azs              = local.azs
  private_subnets  = [for k, v in local.azs : cidrsubnet(module.main_vpc.vpc_cidr_block, 8, k)]
  public_subnets   = [for k, v in local.azs : cidrsubnet(module.main_vpc.vpc_cidr_block, 8, k + 10)]
  database_subnets = [for k, v in local.azs : cidrsubnet(module.main_vpc.vpc_cidr_block, 8, k + 20)]

  # enable_nat_gateway = true
  # single_nat_gateway = true

  tags = {
    Name = "Main VPC"
  }
}


### Multitenant WP Database ###

module "main_aurora_cluster" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.2.1"

  name            = "main-aurora-cluster"
  engine          = "aurora-mysql"
  engine_mode     = "provisioned"
  engine_version  = "8.0.mysql_aurora.3.06.0"
  instance_class  = "db.serverless"
  master_username = "admin"
  master_password = "password"

  instances = {
    one = {}
  }

  storage_encrypted   = true
  skip_final_snapshot = true
  apply_immediately   = true
  autoscaling_enabled = true

  serverlessv2_scaling_configuration = {
    min_capacity = 2
    max_capacity = 4
  }

  create_security_group  = false
  create_db_subnet_group = false

  vpc_id               = module.main_vpc.vpc_id
  db_subnet_group_name = module.main_vpc.database_subnet_group_name
  vpc_security_group_ids = [
    module.allow_db_access.security_group_id
  ]

  tags = {
    Name = "Main Aurora Cluster"
  }
}

### Multitenant WP File System ###

resource "aws_efs_file_system" "this" {
  creation_token = "wp-file-system"

  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"

  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }

  tags = {
    Name = "WP File System"
  }
}

resource "aws_efs_mount_target" "this" {
  count = length(module.main_vpc.private_subnets)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = module.main_vpc.private_subnets[count.index]
  security_groups = [module.allow_efs_access.security_group_id]
}

### API Gateway ###

module "rest_api" {
  source = "./apigateway"

  name             = "rest-api"
  description      = "API Gateway for REST API"
  openapi_filepath = "../api/main.yaml"
  stage_name       = "dev"
  role             = module.role_api_gateway.role_arn
  functions = [
    {
      name        = module.function_account_create.function_name
      invoke_arn  = module.function_account_create.invoke_arn
      path        = "/account/create"
      http_method = "POST"
    },
    {
      name        = module.function_account_confirm.function_name
      invoke_arn  = module.function_account_confirm.invoke_arn
      path        = "/account/confirm"
      http_method = "POST"
    }
  ]
  domain_name            = local.rest_api_domain_name
  domain_certificate_arn = local.rest_api_domain_certificate
}

### User Pool ###

resource "aws_cognito_user_pool" "this" {
  name = "accounts"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  tags = {
    Name = "Accounts"
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "accounts"
  user_pool_id = aws_cognito_user_pool.this.id

  access_token_validity  = 1
  refresh_token_validity = 365

  generate_secret = false
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}
