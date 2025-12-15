provider "aws" {
  region = "us-west-2"
}

variable "lacework_access_key_id" {
  type      = string
  sensitive = true
}

variable "lacework_secret_key" {
  type      = string
  sensitive = true
}

module "aws_org_configuration" {
  source = "../../"

  lacework_account       = "account"
  lacework_subaccount    = "sub-account"
  organization_id        = "o-organizationid"
  organization_unit      = ["ou-abcd-12345678"]
  cf_resource_prefix     = "prefix"

  // Do not hardcode senstive values here.
  // Use command-line arguments, environment variables or git-ignored secrets.tfvars file
  lacework_access_key_id = var.lacework_access_key_id
  lacework_secret_key    = var.lacework_secret_key
}
