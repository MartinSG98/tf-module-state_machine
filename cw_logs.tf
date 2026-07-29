resource "aws_cloudwatch_log_group" "sfn_state_machine" {
  name              = "/${var.environment}/sfn/${var.name_prefix}-sfn-${module.helpers.name_suffix}"
  retention_in_days = (var.environment == "prod") ? 365 : 14
  tags              = local.tags
  kms_key_id        = aws_kms_key.sfn_state_machine.arn
}

resource "aws_kms_key" "sfn_state_machine" {
  description             = "IAM KMS Key encrypting state machine logs"
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "KMS Log group access"
        Effect = "Allow"
        Principal = {
          "AWS" = "arn:aws:iam::${module.helpers.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "logs.${module.helpers.region_name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${module.helpers.region_name}:${module.helpers.account_id}:log-group:/${var.environment}/sfn/${var.name_prefix}-sfn-${module.helpers.name_suffix}"
          }
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_kms_alias" "sfn_state_machine" {
  name          = "alias/${var.name_prefix}_sfn_cwlogs-key-${module.helpers.name_suffix}"
  target_key_id = aws_kms_key.sfn_state_machine.key_id
}
