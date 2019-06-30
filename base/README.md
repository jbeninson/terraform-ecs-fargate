# Base Terraform

Creates the foundational infrastructure for the application's infrastructure.
These Terraform files will create a [remote state][state] and a [registry][ecr].
Most other infrastructure pieces will be created within the `environments` directory.


## Included Files

+ `main.tf`  
The main entry point for the Terraform run.

+ `variables.tf`  
Common variables to use in various Terraform files.

+ `state.tf`  
Generate a [remote state][state] bucket in S3 and a state locking db table to protect against concurrent changes from multiple team members for use with later Terraform runs.

+ `ecr.tf`  
Creates an AWS [Elastic Container Registry (ECR)][ecr] for the application.


## Usage

Typically, the base Terraform will only need to be run once, and then should only
need changes very infrequently.

```
# Sets up Terraform to run
$ terraform init

# Executes the Terraform run
$ terraform apply
```


## Variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| app | Name of the application. This value should usually match the application tag below. | string |  | yes |
| aws_profile | The AWS profile to use, this would be the same value used in AWS_PROFILE. | string |  | yes |
| region | The AWS region to use for the bucket and registry| string | `us-west-1` | yes |


## Outputs

| Name | Description |
|------|-------------|
| bucket | Returns the name of the S3 bucket that will be used in later Terraform files |
| docker_registry | Returns the name of the ECR registry, this will be used later in various scripts |
| dynamodb-terraform-state-lock| Returns the name of the table to protect the remote state from concurrent users

## Additional Information

+ [Terraform remote state][state]

+ [Terraform state locking][state-locking]

+ [Terraform providers][provider]

+ [AWS ECR][ecr]



[state]: https://www.terraform.io/docs/state/remote.html
[state-locking]: https://www.terraform.io/docs/state/locking.html
[provider]: https://www.terraform.io/docs/providers/
[ecr]: https://aws.amazon.com/ecr/
