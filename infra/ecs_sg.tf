resource "aws_security_group" "ecs" {
  name        = "${var.cluster_name}-ecs-task-sg"
  description = "Security Group for ECS Task"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = var.container_port_point_management
    to_port         = var.container_port_point_management
    security_groups = [aws_security_group.security_group_alb.id]
    cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}