variable "name" {
  description = "Name used for the regional application resources."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "source_dir" {
  description = "Directory containing the Python Lambda source files."
  type        = string
}

variable "deployment_region" {
  description = "AWS region reported by this deployment when runtime metadata is unavailable."
  type        = string
}

variable "deployment_role" {
  description = "Regional deployment role reported by the application."
  type        = string

  validation {
    condition     = contains(["PRIMARY", "DR"], var.deployment_role)
    error_message = "deployment_role must be PRIMARY or DR."
  }
}

variable "service_name" {
  description = "Logical service name reported by the API."
  type        = string
  default     = "dr-gameday-api"
}

variable "service_version" {
  description = "Application version reported by the API."
  type        = string
  default     = "1.0.0"
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period."
  type        = number
  default     = 14

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365], var.log_retention_days)
    error_message = "log_retention_days must be a supported CloudWatch Logs retention value."
  }
}

variable "tags" {
  description = "Additional tags applied to application resources."
  type        = map(string)
  default     = {}
}
