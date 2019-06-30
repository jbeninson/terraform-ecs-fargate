# The SAML role to use for adding users to the ECR policy
# variable "saml_role" {}

# creates an application role that the container/task runs as
resource "aws_iam_role" "app_role" {
  name               = "${var.app}-${var.environment}"
  assume_role_policy = "${data.aws_iam_policy_document.app_role_assume_role_policy.json}"
}

# assigns the app policy
resource "aws_iam_role_policy" "app_policy" {
  name   = "${var.app}-${var.environment}"
  role   = "${aws_iam_role.app_role.id}"
  policy = "${data.aws_iam_policy_document.app_policy.json}"
}

data "aws_iam_policy_document" "app_policy" {
  statement {
    actions = [
      "ecs:DescribeClusters",
    ]

    resources = [
      "${aws_ecs_cluster.app.arn}",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy2" {
  role       = "${aws_iam_role.app_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineReadOnlyAccess"
}


data "aws_caller_identity" "current" {}

locals {
  caller_arn = "${data.aws_caller_identity.current.arn}"
  # split the caller_arn into its elements
  # caller_arn_split = [
  #     arn:aws:sts::552242929734:assumed-role,
  #     DevOps,
  #     jbeninsonDEV
  # ]
  caller_arn_split = "${split("/","${local.caller_arn}")}"

  # extract role name from caller_arn_split -> 'DevOps'
  role_name = "${element("${local.caller_arn_split}", 1)}"
  account_id = "${data.aws_caller_identity.current.account_id}"

  role_arn = "arn:aws:iam::${local.account_id}:role/${local.role_name}"
  common_tags = {
      Service = "${var.app}"
      Owner   = "${local.role_name}"
      Terraform = "True"
  }
}

# allow role to be assumed by ecs and local saml users (for development)
data "aws_iam_policy_document" "app_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    principals {
      type = "AWS"

      # identifiers = [
      #   "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${var.saml_role}/me@example.com",
      # ]
      identifiers = [
        "${local.role_arn}",
      ]
    }
  }
}
