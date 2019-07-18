# create the source code for the lambda which processes the cw events, adds Message Attributes, and forwards to the topic
# this is necessary because subscription filters require a "message attributes" key which isn't generated from cloudwatch
data "template_file" "cw_processing_lambda" {
  # a double $$ is needed to access vars within a data template
  vars = {
    topic_arn = "${aws_sns_topic.codepipelines.id}"
  }

  template = <<EOF
import json
import boto3

# https://docs.aws.amazon.com/lambda/latest/dg/python-context-object.html
def lambda_handler(event, context):
    sns = boto3.client('sns')
    response = sns.publish(
        TopicArn="$${topic_arn}",
        Message=json.dumps({"default": json.dumps(event)}),
        Subject='Forwarded From CW',
        MessageStructure='json',
        MessageAttributes={
            'resources': {
                'DataType': 'String.Array',
                'StringValue': json.dumps(event['resources'])
            }
        }
    )
    
    print(response)
    return response
EOF
}

data "archive_file" "cw_processing_lambda" {
  type                    = "zip"
  source_content          = "${data.template_file.cw_processing_lambda.rendered}"
  source_content_filename = "lambda_function.py"
  output_path             = "cw_processing_lambda.zip"
}

# allow the lamdba to be triggered by the cloudwatch rule
resource "aws_lambda_permission" "cw_processing_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.cw_processing_lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.pipelines.arn}"
}

# use the data blocks to create the lambda function resource 
resource "aws_lambda_function" "cw_processing_lambda" {
  function_name    = "${var.app}-${var.environment}-cw-processing-lambda"
  role             = "${aws_iam_role.cw_processing_lambda.arn}"
  filename         = "${data.archive_file.cw_processing_lambda.output_path}"
  source_code_hash = "${data.archive_file.cw_processing_lambda.output_base64sha256}"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.7"
}

resource "aws_lambda_alias" "cw_processing_lambda" {
  name             = "${aws_lambda_function.cw_processing_lambda.function_name}"
  description      = "latest"
  function_name    = "${aws_lambda_function.cw_processing_lambda.function_name}"
  function_version = "$LATEST"
}

resource "aws_iam_role" "cw_processing_lambda" {
  name = "${aws_cloudwatch_event_rule.pipelines.name}"

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
          "Resource": "${aws_sns_topic.codepipelines.id}"
      }
  ]
}
EOF
}