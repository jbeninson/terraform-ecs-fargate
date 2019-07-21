# create ci/cd user with access keys (for build system)
resource "aws_iam_user" "cicd" {
  name = "srv_${var.app}_${var.environment}_cicd"
}

resource "aws_iam_access_key" "cicd_keys" {
  user = "${aws_iam_user.cicd.name}"
}

# grant required permissions to deploy
data "aws_iam_policy_document" "cicd_policy" {
  # allows user to push/pull to the registry
  statement {
    sid = "ecr"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]

    resources = [
      "${data.aws_ecr_repository.ecr.arn}",
    ]
  }

  # allows user to deploy to ecs
  statement {
    sid = "ecs"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:UpdateService",
      "ecs:RegisterTaskDefinition",
    ]

    resources = [
      "*",
    ]
  }

  # allows user to run ecs task using task execution and app roles
  statement {
    sid = "approle"

    actions = [
      "iam:PassRole",
    ]

    resources = [
      "${aws_iam_role.app_role.arn}",
      "${aws_iam_role.ecsTaskExecutionRole.arn}",
    ]
  }
}

# store an environment variable in AWS systems manager agent
resource "aws_ssm_parameter" "SLACK_OAUTH_ACCESS_TOKEN" {
  name        = "SLACK_OAUTH_ACCESS_TOKEN"
  description = "This token is used to connect to the Slack API."
  type        = "SecureString"
  value       = "${var.SLACK_OAUTH_ACCESS_TOKEN}"

  tags="${var.tags}"
}


resource "aws_ssm_parameter" "SLACK_BOT_USER_OAUTH_ACCESS_TOKEN" {
  name        = "SLACK_BOT_USER_OAUTH_ACCESS_TOKEN"
  description = "This token is used to connect to the Slack API."
  type        = "SecureString"
  value       = "${var.SLACK_BOT_USER_OAUTH_ACCESS_TOKEN}"

  tags="${var.tags}"
}

resource "aws_ssm_parameter" "SLACK_VERIFICATION_TOKEN" {
  name        = "SLACK_VERIFICATION_TOKEN"
  description = "This token is used to verify that a request originated from Slack."
  type        = "SecureString"
  value       = "${var.SLACK_VERIFICATION_TOKEN}"

  tags="${var.tags}"
}

resource "aws_ssm_parameter" "SLACK_AWS_PROFILE_NAME" {
  name        = "SLACK_AWS_PROFILE_NAME"
  description = "The profile (i.e. dev or tools) that the app will be operating in."
  type        = "String"
  value       = "${var.SLACK_AWS_PROFILE_NAME}"

  tags="${var.tags}"
}

resource "aws_ssm_parameter" "SLACK_AWS_ACCOUNT_ID" {
  name        = "SLACK_AWS_ACCOUNT_ID"
  description = "The account id of the account that the infrastructure resides in"
  type        = "String"
  value       = "${var.SLACK_AWS_ACCOUNT_ID}"

  tags="${var.tags}"
}

resource "aws_iam_user_policy" "cicd_user_policy" {
  name   = "${var.app}_${var.environment}_cicd"
  user   = "${aws_iam_user.cicd.name}"
  policy = "${data.aws_iam_policy_document.cicd_policy.json}"
}

data "aws_ecr_repository" "ecr" {
  name = "${var.app}"
}

# The AWS keys for the CICD user to use in a build system
output "cicd_keys" {
  value = "terraform state show aws_iam_access_key.cicd_keys"
}

# The URL for the docker image repo in ECR
output "docker_registry" {
  value = "${data.aws_ecr_repository.ecr.repository_url}"
}
