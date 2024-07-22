locals {
  name_tag = title(replace(var.name, "-", " "))
}

resource "aws_s3_bucket" "this" {
  bucket        = var.name
  force_destroy = var.force_destroy

  tags = {
    Name = local.name_tag
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count = var.enable_versioning ? 1 : 0

  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}
