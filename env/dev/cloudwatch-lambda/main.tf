
 terraform {
  required_version = "~> 0.11"
 }

locals {
    sns_topic_arn_split =  "${split(":","${var.sns_topic_arn}")}"
    # extract the region from the account to pass to the cloudwatch processing lambda template 
    sns_topic_region = "${element("${local.sns_topic_arn_split}", 3)}"
}