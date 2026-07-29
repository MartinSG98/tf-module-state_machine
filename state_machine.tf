resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "${var.name_prefix}-sfn-${module.helpers.name_suffix}"
  role_arn = aws_iam_role.provisioner_role.arn

  definition = var.definition

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.sfn_state_machine.arn}:*"
    include_execution_data = true
    level                  = "ERROR"
  }

  tags = local.tags
}
