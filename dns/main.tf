### Tofu Settings ###

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.32.1"
    }
  }

  backend "s3" {
    bucket = "sigan-infrastructure"
    key    = "sigan_dns.tfstate"
    region = "us-east-1"
  }
}

### Providers Settings ###

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "Development"
      Project     = "Sigan DNS"
      ManagedBy   = "Tofu"
    }
  }
}

### Data ###

data "terraform_remote_state" "sigan_main" {
  backend = "s3"
  config = {
    bucket = "sigan-infrastructure"
    key    = "sigan_main.tfstate"
    region = "us-east-1"
  }
}

locals {
  sigan_io          = "sigan.io"
  www_sigan_io      = "www.sigan.io"
  api_sigan_io      = "api.sigan.io"
  db_sigan_io       = "db.sigan.io"
  wildcard_sigan_io = "*.sigan.io"

  sigan_site          = "sigan.site"
  www_sigan_site      = "www.sigan.site"
  wildcard_sigan_site = "*.sigan.site"

  rest_api_regional_domain_name = data.terraform_remote_state.sigan_main.outputs.rest_api_regional_domain_name
  rest_api_regional_zone_id     = data.terraform_remote_state.sigan_main.outputs.rest_api_regional_zone_id
  aurora_cluster_endpoint       = data.terraform_remote_state.sigan_main.outputs.aurora_cluster_endpoint
}

### Domain Setup: sigan.io ###

resource "aws_route53_zone" "sigan_io" {
  name    = local.sigan_io
  comment = "Zone for Sigan's main domain."

  tags = {
    Name = "Sigan Main Domain"
  }
}

module "sigan_io_records" {
  source = "./records"

  domain_zone_id = aws_route53_zone.sigan_io.zone_id
  records = {
    "sigan.io" = {
      name    = local.sigan_io
      type    = "A"
      records = ["76.76.21.21"]
    },
    "www.sigan.io" = {
      name    = local.www_sigan_io
      type    = "CNAME"
      records = ["cname.vercel-dns.com."]
    },
    "api.sigan.io" = {
      name = local.api_sigan_io
      type = "A"
      alias = {
        name    = local.rest_api_regional_domain_name
        zone_id = local.rest_api_regional_zone_id
      }
    },
    "db.sigan.io" = {
      name    = local.db_sigan_io
      type    = "CNAME"
      records = [local.aurora_cluster_endpoint]
    },
    # Email Records
    "mx-sigan.io" = {
      name = local.sigan_io,
      type = "MX"
      records = [
        "1 ASPMX.L.GOOGLE.COM",
        "5 ALT1.ASPMX.L.GOOGLE.COM",
        "5 ALT2.ASPMX.L.GOOGLE.COM",
        "10 ALT3.ASPMX.L.GOOGLE.COM",
        "10 ALT4.ASPMX.L.GOOGLE.COM"
      ]
    },
    "txt-sigan.io" = {
      name    = "sigan.io"
      type    = "TXT"
      records = ["REDACTED"]
    }
  }
}

module "wildcard_sigan_io_certificate" {
  source = "./certificate"

  domain_name    = local.wildcard_sigan_io
  domain_zone_id = aws_route53_zone.sigan_io.zone_id
}

### Domain Setup: sigan.site ###

resource "aws_route53_zone" "sigan_site" {
  name    = local.sigan_site
  comment = "Zone for Sigan's users' sites."

  tags = {
    Name = "Sigan Sites Domain"
  }
}

module "wildcard_sigan_site_certificate" {
  source = "./certificate"

  domain_name    = local.wildcard_sigan_site
  domain_zone_id = aws_route53_zone.sigan_site.zone_id
}
