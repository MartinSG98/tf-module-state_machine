# Inputs into this module

variable "environment" {
  type        = string
  description = "The name of the environment in which this module is being invoked"
  validation {
    condition     = contains(["sand", "dev", "uat", "perf", "stage", "prod", "core", "shared"], var.environment)
    error_message = "Environment must be one of sand, dev, uat, perf, stage, prod, core or shared."
  }
}

# Tags to add on to the default set on the provider
variable "tags" {
  type        = map(string)
  description = "Additional tags to be applied to all resources created by this module"
  default     = {}
}

# Used to build name of objects we create
variable "name_prefix" {
  type        = string
  description = "Used for naming all resources created"
  validation {
    condition = (
      can(regex("^[a-z0-9_]+$", var.name_prefix)) && (length(var.name_prefix) <= 18)
    )
    error_message = "Name prefix must be numbers, lowercase letters and underscores."
  }
}

variable "definition" {
  type        = string
  description = "JSON definition of the state machine"
}

variable "lambda_arns" {
  type        = list(string)
  description = "A list of the lambdas executed by the state machine (to add an IAM policy)"
  default     = []
}

variable "account_shortname" {
  type        = string
  description = "Optional short name for the current account, used in resource name suffixes. Falls back to the raw account ID when not set."
  default     = null
}
