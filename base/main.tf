/**
 * main.tf
 * The main entry point for Terraform run
 * See variables.tf for common variables
 * See ecr.tf for creation of Elastic Container Registry for all environments
 * See state.tf for creation of S3 bucket for remote state
 */

# Using the AWS Provider
# https://www.terraform.io/docs/providers/
provider "aws" {
  region  = "${var.region}"
  profile = "${var.aws_profile}"
  shared_credentials_file = "${var.aws_creds_file_path}"
  version = "~> 2.17"
}

# get your authorized identity
data "aws_caller_identity" "current" {}

locals {
  caller_arn = "${data.aws_caller_identity.current.arn}"
  # split the caller_arn into its elements
  # caller_arn_split = [
  #     arn:aws:sts::552242929734:assumed-role,
  #     DevOps,
  #     jbeninsonDEV
  # ]
  caller_arn_split = "${split("/","${local.caller_arn}")}"

  # extract role name from caller_arn_split -> 'DevOps'
  role_name = "${element("${local.caller_arn_split}", 1)}"
  account_id = "${data.aws_caller_identity.current.account_id}"

  role_arn = "arn:aws:iam::${local.account_id}:role/${local.role_name}"
  common_tags = {
      Service = "${var.app}"
      Owner   = "${local.role_name}"
      Terraform = "True"
  }
}

/*
 * Outputs
 * Results from a successful Terraform run (terraform apply)
 * To see results after a successful run, use `terraform output [name]`
 */

# Returns the name of the ECR registry, this will be used later in various scripts
output "docker_registry" {
  value = "${aws_ecr_repository.app.repository_url}"
}

# Returns the name of the S3 bucket that will be used in later Terraform files
output "bucket" {
  value = "${module.tf_remote_state.bucket}"
}

output "dynamodb-terraform-state-lock"  {
  value = "${aws_dynamodb_table.dynamodb-terraform-state-lock.name}"
}