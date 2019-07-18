provider "aws" {
  region  = "us-west-1"
  profile = "dev"
}


variable "app" {
  default = "SlackApp"
}


variable "environment" {
    default = "dev"
}
