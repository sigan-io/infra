### VPC ###

output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.main_vpc.vpc_id
}

output "private_subnets_ids" {
  description = "The IDs of the private subnets."
  value       = module.main_vpc.private_subnets
}

### Security Groups ###

output "sg_allow_internet_access_id" {
  description = "Security group ID for accessing the internet"
  value       = module.allow_internet_access.security_group_id
}

output "sg_try_db_access_id" {
  description = "Security group ID for accessing databases with the security group `allow_db_access`"
  value       = module.try_db_access.security_group_id
}

output "sg_try_efs_access_id" {
  description = "Security group ID for accessing filesytems with the security group `allow_efs_access`"
  value       = module.try_efs_access.security_group_id
}

### Buckets ###

output "wp_content_bucket_name" {
  description = "The name of the WordPress content bucket."
  value       = module.bucket_wp_contents.bucket_name
}

### API Gateway ###

output "rest_api_url" {
  description = "The original endpoint of the API Gateway."
  value       = module.rest_api.invoke_url
}

output "rest_api_custom_url" {
  description = "The endpoint of the API Gateway after setting up the custom domain."
  value       = "https://${local.rest_api_domain_name}"
}

output "rest_api_regional_domain_name" {
  description = "The regional domain name of the API Gateway. This is needed to setup a new alias record for the custom domain."
  value       = module.rest_api.regional_domain_name
}

output "rest_api_regional_zone_id" {
  description = "The regional zone ID of the API Gateway. This is needed to setup a new alias record for the custom domain."
  value       = module.rest_api.regional_zone_id
}

### Aurora Serverless ###

output "aurora_cluster_endpoint" {
  description = "Endpoint of the Aurora Serverless cluster. This endpoint is required to connect to the cluster and create databases."
  value       = module.main_aurora_cluster.cluster_endpoint
}

### EFS ###

output "filesystem_id" {
  description = "The unique identifier for the EFS file system. This value is needed to create new access points to the filesystem, allowing other resources to securely interact with the EFS."
  value       = aws_efs_file_system.this.id
}

### Roles ###

output "role_user_wp_function" {
  description = "The ARN of the role for the user's WordPress function."
  value       = module.role_user_wp_function.role_arn
}
