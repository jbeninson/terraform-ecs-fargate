/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

# The AWS region to use for the bucket and registry; typically `us-east-1`.
# Other possible values: `us-east-2`, `us-west-1`, or `us-west-2`.
# Currently, Fargate is only available in `us-east-1`.
variable "region" {
  description = "The AWS region to create things in."
  default = "us-west-1"
}

variable "aws_creds_file_path" {
  description = "The path to the aws creds file."
  default     = "{$HOME}/.aws/creds"
}

# The AWS profile to use, this would be the same value used in AWS_PROFILE.
variable "aws_profile" {
    description = "The profile to use from the aws creds file"
    default = "dev"
}

variable "app" {
  default = "slackapp"
}

# # A map of the tags to apply to various resources. The required tags are:
# # `application`, name of the app;
# # `environment`, the environment being created;
# # `team`, team responsible for the application;
# # `contact-email`, contact email for the _team_;
# # and `customer`, who the application was create for.
# variable "tags" {
#   type = "map"
# }
