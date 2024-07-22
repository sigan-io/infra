### Allow Internet Access ###

module "allow_internet_access" {
  source = "./security-group"

  name        = "allow-internet-access"
  description = "Allows resources to access the internet."
  vpc_id      = module.main_vpc.vpc_id

  egress_rules = [
    # HTTP
    {
      cidr_ipv4 = "0.0.0.0/0"
      port      = 80
    },
    {
      cidr_ipv6 = "::/0"
      port      = 80
    },
    # HTTPS
    {
      cidr_ipv4 = "0.0.0.0/0"
      port      = 443
    },
    {
      cidr_ipv6 = "::/0"
      port      = 443
    }
  ]
}

### Allow DB Access ###

module "allow_db_access" {
  source = "./security-group"

  name        = "allow-db-access"
  description = "Allows resources with the try_db_access security group to access the database."
  vpc_id      = module.main_vpc.vpc_id

  ingress_rules = [
    {
      referenced_security_group = module.try_db_access.security_group_id
      port                      = 3306
    }
  ]
}

### Try DB Access ###

module "try_db_access" {
  source = "./security-group"

  name        = "try-db-access"
  description = "Allows access to databases with the allow_db_access security group."
  vpc_id      = module.main_vpc.vpc_id

  egress_rules = [
    {
      referenced_security_group = module.allow_db_access.security_group_id
      port                      = 3306
    }
  ]
}

### Allow EFS Access ###

module "allow_efs_access" {
  source = "./security-group"

  name        = "allow-efs-access"
  description = "Allows resources with the try_efs_access security group to access the EFS."
  vpc_id      = module.main_vpc.vpc_id

  ingress_rules = [
    {
      referenced_security_group = module.try_efs_access.security_group_id
      port                      = 2049
    }
  ]
}

### Try EFS Access ###

module "try_efs_access" {
  source = "./security-group"

  name        = "try-efs-access"
  description = "Allows access to EFSs with the allow_efs_access security group."
  vpc_id      = module.main_vpc.vpc_id

  egress_rules = [
    {
      referenced_security_group = module.allow_efs_access.security_group_id
      port                      = 2049
    }
  ]
}
