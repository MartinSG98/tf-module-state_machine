resource "aws_iam_role" "provisioner_role" {
  name = "${var.name_prefix}-role-${module.helpers.name_suffix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ecs.amazonaws.com", "states.amazonaws.com"]
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "log_access_pol" {
  name = "log_access-pol-${module.helpers.name_suffix}"
  role = aws_iam_role.provisioner_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogDelivery",
          "logs:CreateLogStream",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutLogEvents",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ],
        "Resource" : "${aws_cloudwatch_log_group.sfn_state_machine.arn}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "kms_access_pol" {
  name = "kms_access-pol-${module.helpers.name_suffix}"
  role = aws_iam_role.provisioner_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.sfn_state_machine.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "execute_lambda_pol" {
  count = length(var.lambda_arns) > 0 ? 1 : 0
  name  = "provisioner-pol-${module.helpers.name_suffix}"
  role  = aws_iam_role.provisioner_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction"
        ]
        Effect = "Allow"
        "Resource" : var.lambda_arns
      },
      {
        Action = [
          "events:PutTargets",
          "events:PutRule",
          "events:DescribeRule",
          "events:DeleteRule",
          "events:RemoveTargets"
        ]
        Effect = "Allow"
        "Resource" : [
          # https://stackoverflow.com/questions/60612853/nested-step-function-in-a-step-function-unknown-error-not-authorized-to-cr
          "arn:aws:events:${module.helpers.region_name}:${module.helpers.account_id}:rule/StepFunctionsGetEventsForStepFunctionsExecutionRule"
        ]
      }
    ]
  })
}