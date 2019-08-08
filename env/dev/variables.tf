/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

# The AWS region to use for the dev environment's infrastructure
variable "region" {
  default = "us-west-1"
}

# The AWS Profile to use
variable "aws_profile" {
  default = "dev"
}

# Tags for the infrastructure
variable "tags" {
  type = "map"
  default =  {
        Service = "SlackApp"
        Owner   = "DevOps"
        Terraform = "True"
    }
}

# The application's name
variable "app" {
  default = "slackapp"
}

# The environment that is being built
variable "environment" {
  default = "dev"
}

# The port the container will listen on, used for load balancer health check
# Best practice is that this value is higher than 1024 so the container processes
# isn't running at root.
variable "container_port" {
  default = "80"
}

# The port the load balancer will listen on
variable "lb_port" {
  default = "80"
}

# The protocol to use for routing traffic to the targets. 
variable "lb_protocol" {
  default = "HTTP"
}

variable "SLACK_OAUTH_ACCESS_TOKEN" {
  description = "Used to connect to Slack"
}

variable "OAuthToken" {
  description = "Github OauthToken"
}

variable "SLACK_VERIFICATION_TOKEN"{
  description = "Used to verify requests originate from Slack"
}

variable "SLACK_BOT_USER_OAUTH_ACCESS_TOKEN" {
  description = "Used to connect to Slack as a bot user"
}

variable "SLACK_AWS_PROFILE_NAME" {
  default = "dev"
}

variable "SLACK_AWS_ACCOUNT_ID" {
  default = "552242929734"
}

variable "ecr_repo" {
  description = "The ECR repository that was created in the base module to hold versions of the application"
  default = "552242929734.dkr.ecr.us-west-1.amazonaws.com/slackapp"
}