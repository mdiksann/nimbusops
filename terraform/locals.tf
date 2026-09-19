locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = "NimbusOps"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Portfolio   = "CloudEngineer"
  }
}
