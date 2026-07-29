# tf-module-state_machine

This module will create the baseline state machine and settings, including a KMS-encrypted CloudWatch log group and the IAM permissions required for the state machine role to write to it.

## Inputs

* `name_prefix` : The name prefix to apply to resource names.
* `environment` : The deployment environment (sand, dev, uat, perf, stage, prod, core, shared).
* `account_shortname` : Optional short name for the current account, used in resource name suffixes.
* `definition` : The JSON definition for the state machine.
* `lambda_arns` : List of lambdas executed by the state machine (optional).
* `tags` : Additional tags to apply to all resources (optional).

## Outputs

* `state_machine_name` : NAME of the state machine
* `state_machine_arn` : The ARN of the state machine
* `role_arn` :  The role ARN of the state machine's execution role
* `role_name` : The role NAME of the state machine's execution role

## IAM Permissions

The state machine's execution role is granted the following permissions:

* **CloudWatch Logs**: full log delivery actions scoped to the state machine's log group, for logging execution events.
* **KMS**: `Decrypt`, `Encrypt`, `GenerateDataKey`, and `DescribeKey` scoped to the state machine's own KMS key, required to write to the encrypted log group.
* **Lambda**: `InvokeFunction` scoped to the ARNs passed via `lambda_arns` (only created when the list is non-empty).
* **EventBridge**: permissions required for nested state machine executions.
