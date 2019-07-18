variable "sns_endpoint" {
  default = "https://slackappdevops.navex-dev.com/sns"
}

variable "accountnumber" {
  description = "the account to publish/subscribe sns to"
  default = "552242929734"
}

variable "app" {
  default = "SlackApp"
}

variable "environment" {
    default = "dev"
}
