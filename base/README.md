# Base Terraform

Creates the foundational infrastructure for the application's infrastructure.
These Terraform files will create a [remote state][state] with [state locking][state-locking] and an [elastic container registry][ecr].
Most other infrastructure pieces will be created within the `environments` directory.

## Included Files

+ `main.tf`  
The main entry point for the Terraform run.

+ `variables.tf`  
Common variables to use in various Terraform files.

+ `state.tf`  
Generate a [remote state][state] bucket in S3 and a [state locking][state-locking] dynamo table to protect against concurrent changes from multiple team members for use with later Terraform runs.

+ `ecr.tf`  
Creates an AWS [Elastic Container Registry (ECR)][ecr] to store versions of the application.

## Usage

Typically, the base Terraform will only need to be run once, and then should only
need changes very infrequently. The output will be needed for resources created in the env folders.

```bash
# Sets up Terraform to run
$ terraform init

# Executes the Terraform run
$ terraform apply
```

## Important (after initial `terraform apply`)

The generated base `.tfstate` is not stored in the remote state S3 bucket. Ensure the base `.tfstate` is checked into your infrastructure repo. The default Terraform `.gitignore` [generated by GitHub](https://github.com/github/gitignore/blob/master/Terraform.gitignore) will ignore all `.tfstate` files; you'll need to modify this!

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| app | The name of the application. | string | `slackapp` | yes |
| aws_profile | The [AWS named profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) to use, this would be the same value used in the AWS_PROFILE.| string |  | yes |
| region | The AWS region to use for the remote state bucket, dynamo db, and container registry.| string | `us-west-1` | yes |

## Outputs

| Name | Description |
|------|-------------|
| bucket | Returns the name of the S3 bucket that will be needed when utilizing the Terraform files in the env folders|
| docker_registry | Returns the name of the ECR registry, this will be used later in the env folders |
| dynamodb-terraform-state-lock| Returns the name of the table to protect the remote state from concurrent users, this will be used later in the env folders

## Utilizing The State Store

To utilize the remote state feature in your env templates, configure the terraform block of your target template with the outputs that were generated from this template.

```bash
terraform {
  backend "s3" {
    region  = "us-west-1"
    profile = "dev"
    bucket  = "tf-state-slackapp"
    key     = "dev.terraform.tfstate"
    dynamodb_table = "terraform-state-lock-dynamo"
  }
}
```

## Additional Information

+ [Terraform remote state][state]

+ [Terraform state locking][state-locking]

+ [Terraform providers][provider]

+ [AWS ECR][ecr]

[state]: https://www.terraform.io/docs/state/remote.html
[state-locking]: https://www.terraform.io/docs/state/locking.html
[provider]: https://www.terraform.io/docs/providers/
[ecr]: https://aws.amazon.com/ecr/
