# create the source code for the lambda which processes the cw events, adds Message Attributes, and forwards to the topic
# this is necessary because subscription filters require a "message attributes" key which isn't generated from cloudwatch
data "template_file" "cw_processing_lambda" {
  # a double $$ is needed to access vars within a data template in terraform < 0.12
  vars = {
    region_name = "${local.sns_topic_region}"
    topic_arn = "${var.sns_topic_arn}"
  }

  template = <<EOF
import json
import boto3

# https://docs.aws.amazon.com/sns/latest/dg/sns-message-attributes.html
def lambda_handler(event, context):
    sns = boto3.client('sns', region_name="$${region_name}")

    TopicArn="$${topic_arn}"
    Message=json.dumps({"default": json.dumps(event)})
    MessageAttributes={
      'resources': {
          'DataType': 'String.Array',
          'StringValue': json.dumps(event['resources'])
      },
      'detail-type': {
          'DataType': 'String',
          'StringValue': event['detail-type']
      }
    }

    response = sns.publish(
        TopicArn=TopicArn,
        Message=Message,
        Subject='Forwarded From CW',
        MessageStructure='json',
        MessageAttributes=MessageAttributes
    )
    
    r = {'TopicArn': TopicArn, 'Message': Message, 'MessageAttributes': MessageAttributes, 'Response': response}
    print(r)
    return response
EOF
}

# Generates an archive from content, a file, or directory of files.
# https://www.terraform.io/docs/providers/archive/d/archive_file.html
data "archive_file" "cw_processing_lambda" {
  type                    = "zip"
  source_content          = "${data.template_file.cw_processing_lambda.rendered}"
  source_content_filename = "lambda_function.py"
  output_path             = "cw_processing_lambda.zip"
}

# allow the lamdba to be triggered by the cloudwatch rule
# https://www.terraform.io/docs/providers/aws/r/lambda_permission.html
resource "aws_lambda_permission" "cw_processing_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.cw_processing_lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.pipelines.arn}"
}

# use the data blocks to create the lambda function resource
# https://www.terraform.io/docs/providers/aws/r/lambda_function.html
resource "aws_lambda_function" "cw_processing_lambda" {
  function_name    = "${var.app}-cw-processing-lambda"
  role             = "${var.lambda_function_role_arn}"
  filename         = "${data.archive_file.cw_processing_lambda.output_path}"
  source_code_hash = "${data.archive_file.cw_processing_lambda.output_base64sha256}"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.7"
}

# Creates a Lambda function alias. Creates an alias that points to the specified Lambda function version.
# https://www.terraform.io/docs/providers/aws/r/lambda_alias.html
resource "aws_lambda_alias" "cw_processing_lambda" {
  name             = "${aws_lambda_function.cw_processing_lambda.function_name}"
  description      = "latest"
  function_name    = "${aws_lambda_function.cw_processing_lambda.function_name}"
  function_version = "$LATEST"
}
