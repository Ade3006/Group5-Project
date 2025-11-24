terraform {
  required_version = ">= 1.3.0"

  backend "s3" {
    bucket = "my-staging-env-bucket05"
    key    = "terraform/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "my-network-state-bucket05"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

module "staging" {
  source = "../../modules/env"

  env_name        = "staging"
  instance_type   = "t3.small"
  asg_min_size    = 3
  asg_max_size    = 4
  bucket_name     = "my-staging-env-bucket05"
  images_prefix   = "images/"

  key_name           = "vockey"
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
  web_sg_id          = data.terraform_remote_state.network.outputs.web_sg_id
  target_group_arn   = data.terraform_remote_state.network.outputs.tg_staging_arn
}
