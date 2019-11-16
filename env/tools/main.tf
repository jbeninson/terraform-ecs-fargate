terraform {
  required_version = "~> 0.11"

# The backend configuration is loaded by Terraform extremely early, before
# the core of Terraform can be initialized. This is necessary because the backend
# dictates the behavior of that core. The core is what handles interpolation
# processing. Because of this, interpolations cannot be used in backend
# configuration.

# If you'd like to parameterize backend configuration, we recommend using
# partial configuration with the "-backend-config" flag to "terraform init".
# TODO update backend from base output


# Outputs:

# bucket = tf-state-tools-slackapp
# docker_registry = 518070709175.dkr.ecr.us-west-1.amazonaws.com/slackapp
# dynamodb-terraform-state-lock = terraform-state-lock-dynamo



  backend "s3" {
    region  = "us-west-1"
    profile = "tools"
    bucket  = "tf-state-tools-slackapp"
    key     = "tools.terraform.tfstate"
    dynamodb_table = "terraform-state-lock-dynamo"
  }
}



provider "aws" {
  version = ">= 1.53.0"
  region  = "${var.region}"
  profile = "${var.aws_profile}"
}

provider "aws" {
  alias  = "usw2"
  region = "us-west-2"
  profile = "${var.aws_profile}"
}

locals {
    common_tags = {
      Service = "${var.app}"
      Owner   = "${local.role_name}"
      Terraform = "True"
  }
}

# TODO update repository_url from base output
module "pipeline" {
  source                = "./pipeline"
  cluster_name          = "${aws_ecs_cluster.app.name}"
  container_name        = "${var.container_name}"
  app_repository_name   = "${var.app}"
  git_repository_owner  = "jbeninson"
  git_repository_name   = "slackApp"
  git_repository_branch = "master"
  repository_url        = "${var.ecr_repo}"
  app_service_name      = "${aws_ecs_service.app.name}"
  vpc_id                = "${module.vpc.vpc_id}"
  region                = "${var.region}"
  OAuthToken            = "${var.OAuthToken}"

  subnet_ids = [
    "${module.vpc.private_subnets}"
  ]
}


module "subscriptions" {
    source                = "./subscriptions"
    app                   = "SlackApp"
}

module "cloudwatch_lambda" {
  source = "./cloudwatch-lambda"
  lambda_function_role_arn = "${module.subscriptions.lambda_function_role_arn}"
  sns_topic_arn = "${module.subscriptions.pipeline_topic_arn}"
}

module "cloudwatch_lambda_us-west-2" {
  source = "./cloudwatch-lambda"
  lambda_function_role_arn = "${module.subscriptions.lambda_function_role_arn}"
  sns_topic_arn = "${module.subscriptions.pipeline_topic_arn}"
  providers = {
    aws = "aws.usw2"
  }
}


output "aws_profile" {
  value = "${var.aws_profile}"
}

output "vpc" {
  value = "${module.vpc.vpc_id}"
}

output "pipeline_topic_arn" {
  value = "${module.subscriptions.pipeline_topic_arn}"
  description = "The arn of the pipeline topic. This should be added to the SlackApp awsclient 'TopicArn' so it can subscribe and receive messages."
}
