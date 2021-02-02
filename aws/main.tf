# use AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment vars to access
# export AWS_ACCESS_KEY_ID="enterkeyhere", etc...
# TODO use shared credentials file

provider "aws" {
  region  = "eu-west-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }

  required_version = ">=0.13.2"

  backend "s3" {
    bucket = "example-tf"
    key    = "state/example/example.tfstate"
    region = "eu-west-1"
  }
}