variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  type    = string
  default = "nimbusops"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "alert_email" {
  description = "Email for CloudWatch/SNS and budget notifications"
  type        = string
  sensitive   = true
}

variable "monthly_budget_usd" {
  type    = number
  default = 5
}
