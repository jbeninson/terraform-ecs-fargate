output "pipeline_topic_arn" {
  value = "${aws_sns_topic.codepipelines.id}"
  description = "The arn of the topic that is created."
}
