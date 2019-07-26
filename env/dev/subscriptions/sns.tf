

resource "aws_sns_topic" "codepipelines" {
  name = "SlackApp-Codepipeline-Topic"
}

resource "aws_iam_role" "cw_processing_lambda" {
  name = "SlackAppCloudwatchProcessingLambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_role" {
  role       = "${aws_iam_role.cw_processing_lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "sns_policy" {
  name   = "lambda_logs_and_sns_publish"
  role   = "${aws_iam_role.cw_processing_lambda.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
            "SNS:Publish"
            ],
          "Resource": "${aws_sns_topic.codepipelines.arn}"
      }
  ]
}
EOF
}