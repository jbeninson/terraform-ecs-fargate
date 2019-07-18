

resource "aws_sns_topic" "codepipelines" {
  name = "SlackApp-Codepipeline-Topic2"

#   policy = <<EOF
# {
#   "Version": "2008-10-17",
#   "Id": "__default_policy_ID",
#   "Statement": [
#     {
#       "Sid": "__default_statement_ID",
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "*"
#       },
#       "Action": [
#         "SNS:Publish",
#         "SNS:RemovePermission",
#         "SNS:SetTopicAttributes",
#         "SNS:DeleteTopic",
#         "SNS:ListSubscriptionsByTopic",
#         "SNS:GetTopicAttributes",
#         "SNS:Receive",
#         "SNS:AddPermission",
#         "SNS:Subscribe"
#       ],
#       "Resource": "arn:aws:sns:us-west-1:${var.accountnumber}:SlackApp-Codepipeline-Topic2",
#       "Condition": {
#         "StringEquals": {
#           "AWS:SourceOwner": "${var.accountnumber}"
#         }
#       }
#     },
#     {
#       "Sid": "__console_pub_0",
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "arn:aws:iam::${var.accountnumber}:root"
#       },
#       "Action": "SNS:Publish",
#       "Resource": "arn:aws:sns:us-west-1:${var.accountnumber}:SlackApp-Codepipeline-Topic2"
#     },
#     {
#       "Sid": "__console_sub_0",
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "*"
#       },
#       "Action": [
#         "SNS:Subscribe",
#         "SNS:Receive"
#       ],
#       "Resource": "arn:aws:sns:us-west-1:${var.accountnumber}:SlackApp-Codepipeline-Topic2",
#       "Condition": {
#         "StringLike": {
#           "SNS:Endpoint": "${var.sns_endpoint}"
#         }
#       }
#     }
#   ]
# }
# EOF
}