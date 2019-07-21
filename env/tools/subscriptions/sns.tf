

resource "aws_sns_topic" "codepipelines" {
  name = "SlackApp-Codepipeline-Topic"
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "__default_statement_ID",
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "*"
#       },
#       "Action": [
#         "SNS:GetTopicAttributes",
#         "SNS:SetTopicAttributes",
#         "SNS:AddPermission",
#         "SNS:RemovePermission",
#         "SNS:DeleteTopic",
#         "SNS:Subscribe",
#         "SNS:ListSubscriptionsByTopic",
#         "SNS:Publish",
#         "SNS:Receive"
#       ],
#       "Resource": "arn:aws:sns:us-west-1:552242929734:SlackApp-Codepipeline-Topic2",
#       "Condition": {
#         "StringEquals": {
#           "AWS:SourceOwner": "552242929734"
#         }
#       }
#     },
#     {
#       "Sid": "__subscriptions_statement_id",
#       "Principal": {
#         "AWS": "*"
#       },
#       "Effect": "Allow",
#       "Action": [
#         "sns:Subscribe",
#         "sns:Receive"
#       ],
#       "Resource": "arn:aws:sns:us-west-1:552242929734:SlackApp-Codepipeline-Topic2",
#       "Condition": {
#         "StringLike": {
#           "sns:Endpoint": "${var.sns_endpoint}"
#         }
#       }
#     }
#   ]
# }
# EOF
}
