# https://www.terraform.io/docs/providers/aws/r/codepipeline.html
# https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements
resource "aws_codepipeline" "pipeline" {
  name     = "${var.cluster_name}-pipeline"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.source.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        Owner  = "${var.git_repository_owner}"
        Repo   = "${var.git_repository_name}"
        Branch = "${var.git_repository_branch}"
        OAuthToken = "${var.OAuthToken}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["imagedefinitions"]

      configuration {
        ProjectName = "${var.cluster_name}-codebuild"
      }
    }
  }

  # stage {
  #   name = "Production"

  #   action {
  #     name            = "Deploy"
  #     category        = "Deploy"
  #     owner           = "AWS"
  #     provider        = "ECS"
  #     input_artifacts = ["imagedefinitions"]
  #     version         = "1"

  #     configuration {
  #       ClusterName = "${var.cluster_name}"
  #       ServiceName = "${var.app_service_name}"
  #       FileName    = "imagedefinitions.json"
  #     }
  #   }
  # }
}
