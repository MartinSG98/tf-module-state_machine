# tf-module-state_machine

Creates a Step Functions state machine from your JSON definition, with the execution role it runs as and a CloudWatch log group encrypted with a KMS key of its own. You write the definition, and the module adds the logging, the encryption and the baseline permissions around it.

The state machine is named `<name_prefix>-sfn-<suffix>`, with the name suffix from [tf-module-helpers](https://github.com/MartinSG98/tf-module-helpers), and is a Standard workflow. It logs errors, including execution data, to `/<environment>/sfn/<state machine name>`, which keeps logs for 365 days in `prod` and 14 days elsewhere. The module needs the AWS provider 6.x.

```hcl
module "workflow" {
  source = "git::https://github.com/MartinSG98/tf-module-state_machine.git?ref=1.0.0"

  environment = var.environment
  name_prefix = "myapp_flow"
  definition  = file("${path.module}/workflow.asl.json")

  lambda_arns = [
    module.step_one.lambda_function_arn,
    module.step_two.lambda_function_arn,
  ]

  tags = local.tags
}
```

## IAM permissions

The execution role, `<name_prefix>-role-<suffix>`, can be assumed by Step Functions (and by ECS), and gets these permissions:

- **CloudWatch Logs.** The log delivery actions, scoped to the state machine's log group.
- **KMS.** `Decrypt`, `Encrypt`, `GenerateDataKey` and `DescribeKey` on the state machine's own key, which it needs to write to the encrypted log group.
- **Lambda.** `InvokeFunction` on the functions in `lambda_arns`.
- **EventBridge.** Managing the rule `StepFunctionsGetEventsForStepFunctionsExecutionRule`, which Step Functions uses to wait for nested state machine executions.

The Lambda and EventBridge permissions share one policy, which is only created when `lambda_arns` is not empty. The role has no `states:StartExecution`, so a definition that starts other state machines, or calls any other service, needs its own policy on the role. Attach it through the `role_name` output.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `environment` | `string` | required | Environment the module is used in: `sand`, `dev`, `uat`, `perf`, `stage`, `prod`, `core` or `shared` |
| `name_prefix` | `string` | required | Prefix for all resource names, in lower-case letters, digits and underscores, 18 characters at most |
| `definition` | `string` | required | JSON definition of the state machine, in Amazon States Language |
| `lambda_arns` | `list(string)` | `[]` | Lambda functions the state machine invokes, which the role is allowed to call |
| `account_shortname` | `string` | `null` | Short name for the current account in name suffixes. Falls back to the account ID |
| `tags` | `map(string)` | `{}` | Extra tags for all resources. An `InfraModule` tag is added with `tf-module-state_machine`, followed by any `InfraModule` value you pass here |

## Outputs

| Name | Description |
|---|---|
| `state_machine_name` | Name of the state machine |
| `state_machine_arn` | ARN of the state machine |
| `role_arn` | ARN of the state machine's execution role |
| `role_name` | Name of the state machine's execution role |
