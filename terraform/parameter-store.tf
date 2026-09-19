resource "aws_ssm_parameter" "app_name" {
  name  = "/${var.project_name}/${var.environment}/app-name"
  type  = "String"
  value = "NimbusOps"
}
