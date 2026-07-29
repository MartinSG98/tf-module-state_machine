output "state_machine_name" {
  description = "The NAME of the state machine"
  value       = aws_sfn_state_machine.sfn_state_machine.name
}

output "state_machine_arn" {
  description = "The ARN of the state machine"
  value       = aws_sfn_state_machine.sfn_state_machine.arn
}

output "role_arn" {
  description = "The ROLE ARN of the state machine's execution role"
  value       = aws_iam_role.provisioner_role.arn
}

output "role_name" {
  description = "The ROLE NAME of the state machine's execution role"
  value       = aws_iam_role.provisioner_role.name
}
