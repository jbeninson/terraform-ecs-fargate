output "pipeline_topic_arn" {
  value = "${aws_sns_topic.codepipelines.id}"
  description = "The arn of the topic that is created."
}


output "lambda_function_role_arn" {
  value = "${aws_iam_role.cw_processing_lambda.arn}"
}
