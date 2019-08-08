# Terraform ECS Fargate

A set of Terraform templates used for provisioning web application stacks on [AWS ECS Fargate][fargate].

![diagram](diagram.png)

The templates are designed to be customized.  The optional components can be removed by simply deleting the `.tf` file.

The templates are used for managing infrastructure concerns and, as such, the templates deploy a [default backend docker image](env/dev/ecs.tf#L26).  We recommend using the [fargate CLI](https://github.com/turnerlabs/fargate) for managing application concerns like deploying your actual application images and environment variables on top of this infrastructure.  The fargate CLI can be used to deploy applications from your laptop or in CI/CD pipelines.

## Components

### base

These templates are reused for each target. See the [base module's README][br] for more info.

| Name | Description | Optional |
|------|-------------|:---:|
| [main.tf][bm] | AWS provider, output |  |
| [state.tf][bs] | S3 bucket backend for storing Terraform remote state  |  |
| [ecr.tf][be] | ECR repository for application (all environments share)  |  ||

### env modules

Modules are currently copied for each environment in their respective subdirectory. This strategy was used to allow for variance (testing and such) between the two target environments (currently, the dev and tools accounts). There is a corresponding directory for each environment that is needed. This will be replaced with [terraform workspaces](https://www.terraform.io/docs/state/workspaces.html) or [terragrunt](https://github.com/gruntwork-io/terragrunt) in the future. The following links target env/dev.

| Name | Description | Optional |
|------|-------------|:----:|
| [main.tf][edm] | Terrform remote state, AWS provider, output |  |
| [ecs.tf][ede] | ECS Cluster, Service, Task Definition, ecsTaskExecutionRole, CloudWatch Log Group |  |
| [lb.tf][edl] | ALB, Target Group, S3 bucket for access logs  |  |
| [nsg.tf][edn] | NSG for ALB and Task |  |
| [lb-http.tf][edlhttp] | HTTP listener, NSG rule. Delete if HTTPS only | Yes |
| [lb-https.tf][edlhttps] | HTTPS listener, NSG rule. Delete if HTTP only | Yes |
| [dashboard.tf][edd] | CloudWatch dashboard: CPU, memory, and HTTP-related metrics | Yes |
| [role.tf][edr] | Application Role for container | Yes |
| [cicd.tf][edc] | IAM user that can be used by CI/CD systems | Yes |
| [autoscale-perf.tf][edap] | Performance-based auto scaling | Yes |
| [autoscale-time.tf][edat] | Time-based auto scaling | Yes |
| [logs-logzio.tf][edll] | Ship container logs to logz.io | Yes |
| [secretsmanager.tf][edsm] | Add a base secret to Secretsmanager | Yes |
| [ecs-event-stream.tf][ees] | Add an ECS event log dashboard | Yes |

## Usage

Typically, the base Terraform will only need to be run once, and then should only
need changes very infrequently. After the base is built, each environment can be built.

```bash
# Move into the base directory
$ cd base

# Sets up Terraform to run
$ terraform init

# Executes the Terraform run
$ terraform apply

# Now, move into the dev environment
$ cd ../env/dev

# Sets up Terraform to run
$ terraform init

# Executes the Terraform run
$ terraform apply
```

create an input vars file (`terraform.tfvars`) in each env folder that contains your variables for that environment.

```hcl
# app/env to scaffold
app = "my-app"
environment = "dev"

internal = "true"
container_port = "8080"
replicas = "1"
health_check = "/health"
region = "us-east-1"
aws_profile = "default"
saml_role = "admin"
vpc = "vpc-123"
private_subnets = "subnet-123,subnet-456"
public_subnets = "subnet-789,subnet-012"
tags = {
  application   = "my-app"
  environment   = "dev"
  team          = "my-team"
  customer      = "my-customer"
  contact-email = "me@example.com"
}
```

## Additional Information

+ [Base README][base]

+ [Environment `dev` README][env-dev]

[fargate]: https://aws.amazon.com/fargate/
[bm]: ./base/main.tf
[br]: ./base/README.md
[bs]: ./base/state.tf
[be]: ./base/ecr.tf
[edm]: ./env/dev/main.tf
[ede]: ./env/dev/ecs.tf
[edl]: ./env/dev/lb.tf
[edn]: ./env/dev/nsg.tf
[edlhttp]: ./env/dev/lb-http.tf
[edlhttps]: ./env/dev/lb-https.tf
[edd]: ./env/dev/dashboard.tf
[edr]: ./env/dev/role.tf
[edc]: ./env/dev/cicd.tf
[edap]: ./env/dev/autoscale-perf.tf
[edat]: ./env/dev/autoscale-time.tf
[edll]: ./env/dev/logs-logzio.tf
[edsm]: ./env/dev/secretsmanager.tf
[ees]: ./env/dev/ecs-event-stream.tf
[base]: ./base/README.md
[env-dev]: ./env/dev/README.md
