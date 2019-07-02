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

# output

# Command to view the status of the Fargate service
output "status" {
  value = "fargate service info"
}

# # Command to deploy a new task definition to the service using Docker Compose
# output "deploy" {
#   value = "fargate service deploy -f docker-compose.yml"
# }

# # Command to scale up cpu and memory
# output "scale_up" {
#   value = "fargate service update -h"
# }

# # Command to scale out the number of tasks (container replicas)
# output "scale_out" {
#   value = "fargate service scale -h"
# }

# Command to set the AWS_PROFILE
output "aws_profile" {
  value = "${var.aws_profile}"
}

output "vpc" {
  value = "${module.vpc.vpc_id}"
}
