# Default AWS Org Configuration Assessment with Lacework

This scenario integrates an AWS Organzation with Lacework for cloud resource configuration assessment.

## Sample Code

```hcl
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
  source  = "lacework/org-configuration/aws"
  version = "~> 0.1"

  lacework_account       = "account"
  lacework_subaccount    = "sub-account"
  organization_id        = "o-organizationid"
  organization_unit      = "org-unit"
  cf_resource_prefix     = "prefix"

  // Do not hardcode senstive values here.
  // Use command-line, environment variables or git-ignored secrets.tfvars file
  lacework_access_key_id = var.lacework_access_key_id
  lacework_secret_key    = var.lacework_secret_key
}
```

For detailed information on integrating Lacework with AWS Organizations see [AWS Organizations and StackSets](https://docs.lacework.net/onboarding/aws-integration-with-cloudformation#aws-organizations-and-stacksets)
