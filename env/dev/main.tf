terraform {
  required_version = ">= 0.11.0"

# The backend configuration is loaded by Terraform extremely early, before
# the core of Terraform can be initialized. This is necessary because the backend
# dictates the behavior of that core. The core is what handles interpolation
# processing. Because of this, interpolations cannot be used in backend
# configuration.

# If you'd like to parameterize backend configuration, we recommend using
# partial configuration with the "-backend-config" flag to "terraform init".
  backend "s3" {
    region  = "us-west-1"
    profile = "dev"
    bucket  = "tf-state-slackapp"
    key     = "dev.terraform.tfstate"
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

# GITHUB_TOKEN

module "pipeline" {
  source                = "./pipeline"
  cluster_name          = "${aws_ecs_cluster.app.name}"
  container_name        = "${var.container_name.}"
  app_repository_name   = "${var.app}"
  git_repository_owner  = "jbeninson"
  git_repository_name   = "slackApp"
  git_repository_branch = "slackful"
  repository_url        = "552242929734.dkr.ecr.us-west-1.amazonaws.com/slackapp"
  app_service_name      = "${aws_ecs_service.app.name}"
  account_id            = "${data.aws_caller_identity.current.account_id}"
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
