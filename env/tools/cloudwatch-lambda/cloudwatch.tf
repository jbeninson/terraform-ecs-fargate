
# create a topic which will pick up any changes to codepipelines
resource "aws_cloudwatch_event_rule" "pipelines" {
  name        = "SlackAppPipelineEvents2"
  description = "Capture each AWS Pipeline Activity"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.codepipeline"
  ]
}
PATTERN
}

# targets a lambda for all events collected by the pipelines cloudwatch rule resource
resource "aws_cloudwatch_event_target" "lambda" {
  rule      = "${aws_cloudwatch_event_rule.pipelines.name}"
  target_id = "SlackAppCloudwatchProcessor"
  arn       = "${aws_lambda_function.cw_processing_lambda.arn}"
}