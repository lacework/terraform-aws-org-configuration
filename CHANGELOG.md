# v1.1.4

## Other Changes
* chore: fix LW_ACCOUNT for devtest accounts (Pengyuan Zhao)([1020c7d](https://github.com/lacework/terraform-aws-org-configuration/commit/1020c7d2c4331842a5d00b57cfbf96f861065e09))
* ci: version bump to v1.1.4-dev (Lacework)([6c2830c](https://github.com/lacework/terraform-aws-org-configuration/commit/6c2830c0a299589a7adbf441ad8f348d2f49c8be))
---
# v1.1.3

## Other Changes
* ci: version bump to v1.1.3-dev (Lacework)([252f33d](https://github.com/lacework/terraform-aws-org-configuration/commit/252f33dd8d00b7ecfddb88c3c15babbb86fe2f0b))
---
# v1.1.2

## Bug Fixes
* fix: Fix the s3 template url by removing the version (Lei Jin)([9a72630](https://github.com/lacework/terraform-aws-org-configuration/commit/9a726304e378e3fcdd0cc34d038b21028ec3759f))
## Other Changes
* ci: version bump to v1.1.2-dev (Lacework)([fb372cd](https://github.com/lacework/terraform-aws-org-configuration/commit/fb372cdb4c54258e85f7f32d63afeb63b702308b))
---
# v1.1.1

## Bug Fixes
* fix: Fix the deprecated global s3 endpoints (Lei Jin)([954be21](https://github.com/lacework/terraform-aws-org-configuration/commit/954be21e9be93b58cf7cabbded25506db1095193))
## Other Changes
* chore(GROW-2952): add codeowners (#25) (Matt Cadorette)([b4d3f9d](https://github.com/lacework/terraform-aws-org-configuration/commit/b4d3f9d4d9834cd60ba3251957c76bd89455aa12))
* ci: update job name in test compat workflow (Timothy MacDonald)([2b76e4d](https://github.com/lacework/terraform-aws-org-configuration/commit/2b76e4d8571d285cdc96d0541252b5527af6fdda))
* ci: migrate from codefresh to github actions (Timothy MacDonald)([b3c92b9](https://github.com/lacework/terraform-aws-org-configuration/commit/b3c92b97299b1f315521cac2affbab3137b495fe))
* ci: version bump to v1.1.1-dev (Lacework)([fe49794](https://github.com/lacework/terraform-aws-org-configuration/commit/fe49794400f4edc9ec43cf7c8536a6d3d1a66e6b))
---
# v1.1.0

## Features
* feat: support user-supplied tags (#21) (Matt Cadorette)([9d89e57](https://github.com/lacework/terraform-aws-org-configuration/commit/9d89e57413857f8af78e7cd4dee4d7354037c43f))
## Other Changes
* ci: version bump to v1.0.2-dev (Lacework)([5944770](https://github.com/lacework/terraform-aws-org-configuration/commit/59447704fa4278483b31f6ec9ce2d0dafa7a813e))
---
# v1.0.1

## Other Changes
* chore: set local var module name (#19) (Darren)([44de944](https://github.com/lacework/terraform-aws-org-configuration/commit/44de9442551bad24df128317cbeb2312ea5f7489))
* ci: version bump to v1.0.1-dev (Lacework)([e27798e](https://github.com/lacework/terraform-aws-org-configuration/commit/e27798e3df0d3b016df34d7f23ebe2ff2388af9b))
---
# v1.0.0

## Other Changes
* chore: add lacework_metric_module datasource (Darren Murray)([8c09421](https://github.com/lacework/terraform-aws-org-configuration/commit/8c0942147216bf61b71e9105c950d0fdfda23120))
* chore: update lambda function version (Pengyuan Zhao)([8a6a8ac](https://github.com/lacework/terraform-aws-org-configuration/commit/8a6a8ac6e9369496498176cccf1e98cf5e8d2329))
* chore: update template_url (Pengyuan Zhao)([da8eaab](https://github.com/lacework/terraform-aws-org-configuration/commit/da8eaababc45450a3e1df4618897751fa3f8e467))
* chore: use secret ARN instead of secret name for Lacework API credentials (Pengyuan Zhao)([67c3366](https://github.com/lacework/terraform-aws-org-configuration/commit/67c3366db495acbf668a60849bd9a9fe304865a7))
* ci: version bump to v0.1.2-dev (Lacework)([bac2c6f](https://github.com/lacework/terraform-aws-org-configuration/commit/bac2c6ffd34445a41de9997c28693611699213b4))
---
# v0.1.1

## Bug Fixes
* fix: enable parallel stackset operations (#12) (Matt Cadorette)([06f3c0c](https://github.com/lacework/terraform-aws-org-configuration/commit/06f3c0c6ca56eb174f414fc819bb82ac74dd4cca))
* fix(GROW-2584): resolve constant drift in stackset (#13) (Matt Cadorette)([31fb424](https://github.com/lacework/terraform-aws-org-configuration/commit/31fb42417de2af787dedb000ec231e9a9aa1393d))
## Other Changes
* chore: version bump v0.1.1-dev (#11) (Salim Afiune)([da2686e](https://github.com/lacework/terraform-aws-org-configuration/commit/da2686e8afbd45e70c952574ad532aceb8bd230d))
---
# v0.1.0

## Features
* feat: doc update (jon-stewart)([5923a38](https://github.com/lacework/terraform-aws-org-configuration/commit/5923a38e427f6493bbf9cec2a4f55a9f3c9177e6))
## Refactor
* refactor: lots of fixes + cleanup  (#3) (Salim Afiune)([07903b0](https://github.com/lacework/terraform-aws-org-configuration/commit/07903b02080adb64bb77fb992bb3f7bb02ca0c15))
## Bug Fixes
* fix: policy to copy S3 lambda (#9) (Salim Afiune)([c403edc](https://github.com/lacework/terraform-aws-org-configuration/commit/c403edc8b2e5b5f89e875b593051b6a3286f98fd))
* fix: more and more fixes (#7) (Salim Afiune)([e112df9](https://github.com/lacework/terraform-aws-org-configuration/commit/e112df9bf84fbdb8c2b596d3836634ad358061a7))
* fix: update kms key policy, sns policy, stackset instance creation (#6) (Matt Cadorette)([9caae48](https://github.com/lacework/terraform-aws-org-configuration/commit/9caae482e5552b4b6986a608f3197aedd473abb6))
* fix: external_id should always use account (#2) (Matt Cadorette)([3259480](https://github.com/lacework/terraform-aws-org-configuration/commit/32594809e7c9d4986aac63783ebfb427b9694ba6))
* fix: docs (jon-stewart)([d858616](https://github.com/lacework/terraform-aws-org-configuration/commit/d858616d3a3b7675df2518e840d57f57fdebe872))
* fix: further impr (jon-stewart)([2682b6b](https://github.com/lacework/terraform-aws-org-configuration/commit/2682b6be36809572efb743299b36bb13503947b6))
* fix: make tfdocs (jon-stewart)([13075fd](https://github.com/lacework/terraform-aws-org-configuration/commit/13075fd3a953ea7dca544d21d5996fd3bc7b1b3f))
* fix: tf docs (jon-stewart)([3807572](https://github.com/lacework/terraform-aws-org-configuration/commit/38075727ead23be91cb277c97a876b5b9b9359e4))
* fix: improvements (jon-stewart)([787cdf2](https://github.com/lacework/terraform-aws-org-configuration/commit/787cdf21895daf70dc9fcdc38f124e17453d8308))
* fix: archive and invoke (jon-stewart)([9bb57ce](https://github.com/lacework/terraform-aws-org-configuration/commit/9bb57ce7aae72011023c952009f182c1b6d7cb6b))
---
