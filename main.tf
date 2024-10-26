locals {
  # Python3.9 support introduced in version 3.55.0
  # https://github.com/hashicorp/terraform-provider-aws/blob/release/3.x/CHANGELOG.md#3550-august-19-2021
  python_version = "python3.9"

  # Python3.10 support introduced in version 4.64.0
  # https://github.com/hashicorp/terraform-provider-aws/blob/release/4.x/CHANGELOG.md#4640-april-20-2023
  # python_version = "python3.10"

  # Python3.11 support introduced in version 5.11.0
  # https://github.com/hashicorp/terraform-provider-aws/blob/main/CHANGELOG.md#5110-august--3-2023
  # python_version = "python3.11"

  kms_key_arn   = length(var.kms_key_arn) > 0 ? var.kms_key_arn : aws_kms_key.lacework_kms_key[0].arn
  lambda_zip    = "LaceworkIntegrationSetup1.1.3.zip"
  s3_lambda_key = "${var.cf_s3_prefix}/lambda/${local.lambda_zip}"
  template_url  = "https://${var.cf_s3_bucket}.s3.us-west-2.amazonaws.com/${var.cf_s3_prefix}/templates/lacework-aws-cfg-member.template.yml"
  version_file   = "${abspath(path.module)}/VERSION"
  module_name    = "terraform-aws-org-configuration"
  module_version = fileexists(local.version_file) ? file(local.version_file) : ""  
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

#tfsec:ignore:aws-s3-enable-bucket-encryption
#tfsec:ignore:aws-s3-enable-bucket-logging
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket" "lacework_org_lambda" {
  bucket_prefix = "lacework-org-lambda-"
  force_destroy = true
  tags = var.tags 
}

resource "aws_s3_bucket_versioning" "lacework_org_lambda" {
  bucket = aws_s3_bucket.lacework_org_lambda.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "lacework_org_lambda" {
  bucket = aws_s3_bucket.lacework_org_lambda.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "lacework_org_lambda" {
  bucket                  = aws_s3_bucket.lacework_org_lambda.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_lambda_function" "lacework_copy_zip_files" {
  description      = "Copies object from the Lacework S3 bucket to a new location"
  filename         = data.archive_file.lambda_zip_file.output_path
  function_name    = "lacework_copy_zip_files"
  handler          = "index.handler"
  role             = aws_iam_role.lacework_copy_zip_files_role.arn
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256
  timeout          = 240
  runtime          = local.python_version
  tags             = var.tags

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      src_bucket = var.cf_s3_bucket
      dst_bucket = aws_s3_bucket.lacework_org_lambda.id
      prefix     = var.cf_s3_prefix
      object     = "/lambda/${local.lambda_zip}"
    }
  }
}

data "archive_file" "lambda_zip_file" {
  excludes    = ["__init__.py", "*.pyc"]
  output_path = "${path.module}/lambda.zip"
  source_dir  = "${path.module}/python"
  type        = "zip"
}

resource "aws_iam_role" "lacework_copy_zip_files_role" {
  assume_role_policy = data.aws_iam_policy_document.lacework_copy_zip_files_assume_role.json
  tags               = var.tags

  inline_policy {
    name   = "zip-role"
    policy = data.aws_iam_policy_document.lacework_copy_zip_files_role.json
  }

  managed_policy_arns = [
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  name = "lacework_copy_zip_files_role"
  path = "/"
}

data "aws_iam_policy_document" "lacework_copy_zip_files_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lacework_copy_zip_files_role" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging",
    ]
    effect = "Allow"
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.cf_s3_bucket}/${var.cf_s3_prefix}/*"
    ]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:PutObjectTagging",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.lacework_org_lambda.arn}/${local.s3_lambda_key}",
    ]
  }

  version = "2012-10-17"
}

resource "aws_lambda_invocation" "lacework_copy_zip_files" {
  function_name = aws_lambda_function.lacework_copy_zip_files.arn

  input = jsonencode({})

  depends_on = [aws_lambda_function.lacework_copy_zip_files]
}

resource "aws_lambda_function" "lacework_setup_function" {
  description = "Sends HTTP requests to Lacework APIs to manage integrations"
  tags        = var.tags

  environment {
    variables = {
      LW_ACCOUNT    = var.lacework_account
      LW_INT_PREFIX = "AWS"
      LW_SUBACCOUNT = var.lacework_subaccount
    }
  }

  function_name = "lacework_setup_function"
  handler       = "lw_integration_lambda_function.handler"
  role          = aws_iam_role.lacework_setup_function_role.arn
  s3_bucket     = aws_s3_bucket.lacework_org_lambda.bucket
  s3_key        = local.s3_lambda_key
  timeout       = 900
  runtime       = local.python_version

  tracing_config {
    mode = "Active"
  }

  depends_on = [
    aws_lambda_invocation.lacework_copy_zip_files,
    aws_sns_topic.lacework_sns_topic,
    aws_secretsmanager_secret.lacework_api_credentials
  ]
}

resource "aws_iam_role" "lacework_setup_function_role" {
  assume_role_policy = data.aws_iam_policy_document.lacework_setup_function_assume_role.json
  tags               = var.tags

  inline_policy {
    name   = "lacework_setup_function_policy"
    policy = data.aws_iam_policy_document.lacework_setup_function_role.json
  }

  managed_policy_arns = [
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  name = "lacework_setup_function_role"
  path = "/"
}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "lacework_setup_function_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lacework_setup_function_role" {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "secretsmanager:GetSecretValue",
      "secretsmanager:UpdateSecret"
    ]
    effect = "Allow"
    resources = [
      aws_secretsmanager_secret.lacework_api_credentials.arn,
      local.kms_key_arn,
    ]
  }

  version = "2012-10-17"
}

resource "aws_lambda_permission" "lacework_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lacework_setup_function.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.lacework_sns_topic.arn
}

resource "aws_secretsmanager_secret" "lacework_api_credentials" {
  description             = "Lacework API Access Keys"
  kms_key_id              = local.kms_key_arn
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "lacework_api_credentials" {
  secret_id     = aws_secretsmanager_secret.lacework_api_credentials.id
  secret_string = "{\"AccessKeyID\": \"${var.lacework_access_key_id}\", \"SecretKey\": \"${var.lacework_secret_key}\", \"AccessToken\": \"0\", \"TokenExpiry\": 0}"
}

resource "aws_sns_topic" "lacework_sns_topic" {
  name              = "lacework_sns_topic"
  kms_master_key_id = local.kms_key_arn
  tags              = var.tags
}

#tfsec:ignore:aws-kms-auto-rotate-keys customer has option of enabling key rotation
resource "aws_kms_key" "lacework_kms_key" {
  count                   = length(var.kms_key_arn) > 0 ? 0 : 1
  description             = "A KMS key used to encrypt SNS topic messages and Secrets"
  deletion_window_in_days = var.kms_key_deletion_days
  multi_region            = var.kms_key_multi_region
  policy                  = data.aws_iam_policy_document.kms_key_policy.json
  enable_key_rotation     = var.kms_key_rotation
  tags                    = var.tags
}

data "aws_iam_policy_document" "kms_key_policy" {
  version = "2012-10-17"

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid    = "Enable Org member accounts to use key"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [var.organization_id]
    }

    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]

    resources = ["*"]
  }
}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.lacework_sns_topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "lwSNStopicpolicy"

  statement {
    actions = [
      "sns:Publish",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [var.organization_id]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = ["*"]
    sid       = "AllowWithinOrg"
  }
}

resource "aws_sns_topic_subscription" "lacework_sns_subscription" {
  endpoint  = aws_lambda_function.lacework_setup_function.arn
  protocol  = "lambda"
  topic_arn = aws_sns_topic.lacework_sns_topic.arn
}

resource "aws_cloudformation_stack" "lacework_stack" {
  capabilities = ["CAPABILITY_NAMED_IAM"]
  name         = var.cf_stack_name
  tags         = var.tags

  parameters = {
    LaceworkAccount    = var.lacework_account
    MainAccountSNS     = aws_sns_topic.lacework_sns_topic.arn
    ResourceNamePrefix = var.cf_resource_prefix
    SecretArn          = aws_secretsmanager_secret.lacework_api_credentials.id
  }
  template_url       = local.template_url
  timeout_in_minutes = 30
  depends_on = [ // depending on all this ensures the stackinstances can be torn down properly
    aws_s3_bucket.lacework_org_lambda,
    aws_sns_topic.lacework_sns_topic,
    aws_sns_topic_subscription.lacework_sns_subscription,
    aws_sns_topic_policy.default,
    aws_lambda_permission.lacework_lambda_permission,
    aws_secretsmanager_secret.lacework_api_credentials,
    aws_lambda_function.lacework_setup_function
  ]
}

resource "aws_cloudformation_stack_set" "lacework_stackset" {
  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  capabilities = ["CAPABILITY_NAMED_IAM"]
  name         = var.cf_stack_name

  // GROW-2584: Workaround due to https://github.com/hashicorp/terraform-provider-aws/issues/23464
  //            this block can be removed if there is a solution created for 23464
  lifecycle {
    ignore_changes = [administration_role_arn]
  }

  parameters = {
    LaceworkAccount    = var.lacework_account
    MainAccountSNS     = aws_sns_topic.lacework_sns_topic.arn
    ResourceNamePrefix = var.cf_resource_prefix
    SecretArn          = aws_secretsmanager_secret.lacework_api_credentials.id
  }

  managed_execution {
    active = var.stackset_managed_execution
  }

  permission_model = "SERVICE_MANAGED"
  template_url     = local.template_url
  tags             = var.tags

  depends_on = [ // depending on all this ensures the stackinstances can be torn down properly
    aws_s3_bucket.lacework_org_lambda,
    aws_sns_topic.lacework_sns_topic,
    aws_sns_topic_subscription.lacework_sns_subscription,
    aws_sns_topic_policy.default,
    aws_lambda_permission.lacework_lambda_permission,
    aws_secretsmanager_secret.lacework_api_credentials,
    aws_lambda_function.lacework_setup_function
  ]
}

resource "aws_cloudformation_stack_set_instance" "lacework_stackset_instances" {
  deployment_targets {
    organizational_unit_ids = var.organization_unit
  }

  operation_preferences {
    failure_tolerance_count = var.stackset_failure_tolerance_count
    max_concurrent_count    = var.stackset_max_concurrent_count
    region_concurrency_type = var.stackset_region_concurrency_type
  }

  timeouts {
    create = "1h"
    update = "1h"
    delete = "1h"
  }

  region         = data.aws_region.current.name
  stack_set_name = aws_cloudformation_stack_set.lacework_stackset.name
  depends_on = [ // depending on all this ensures the stackinstances can be torn down properly
    aws_s3_bucket.lacework_org_lambda,
    aws_sns_topic.lacework_sns_topic,
    aws_sns_topic_subscription.lacework_sns_subscription,
    aws_sns_topic_policy.default,
    aws_lambda_permission.lacework_lambda_permission,
    aws_secretsmanager_secret.lacework_api_credentials,
    aws_lambda_function.lacework_setup_function
  ]
}

data "lacework_metric_module" "lwmetrics" {
  name    = local.module_name
  version = local.module_version
}
