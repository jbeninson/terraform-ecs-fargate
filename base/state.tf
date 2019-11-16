/*
 * state.tf
 * Generate a remote state bucket in S3 for use with later Terraform run
 * Uses a Turner created Terrafor module; more information at:
 * https://github.com/turnerlabs/terraform-remote-state/blob/master/readme.md
 *
 * To learn more about remote state:
 * https://www.terraform.io/docs/state/remote.html
 * 
 * To learn more about state locking:
 * https://www.terraform.io/docs/state/locking.html
 */

# s3 bucket for tf remote state
# https://github.com/turnerlabs/terraform-remote-state
module "tf_remote_state" {
  source = "github.com/turnerlabs/terraform-remote-state?ref=v2.2.0"

  role        = "${local.role_name}"
  application = "${var.aws_profile}-${var.app}"
  tags        = "${local.common_tags}"
}


# create a dynamodb table for locking the state file
# https://www.terraform.io/docs/providers/aws/r/dynamodb_table.html
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "terraform-state-lock-dynamo"
  hash_key = "LockID"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
  
 tags        = "${local.common_tags}"
}