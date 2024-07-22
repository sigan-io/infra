locals {
  name_tag = title(replace(var.name, "-", " "))
}

resource "aws_iam_role" "this" {
  name        = var.name
  description = var.description
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "${var.service}.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = var.managed_policies

  tags = {
    Name = local.name_tag
  }
}
