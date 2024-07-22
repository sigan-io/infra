terraform {
  backend "s3" {
    bucket = "sigan-infrastructure"
    key    = "sigan_main.tfstate"
    region = "us-east-1"
  }
}
