resource "aws_cloudwatch_log_group" "point_management" {
  name              = "/ecs/${var.cluster_name}/${var.task_point_management_name}"
  retention_in_days = 1
}
