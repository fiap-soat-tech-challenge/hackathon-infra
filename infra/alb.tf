resource "aws_security_group" "security_group_alb" {
  name        = "${var.app_name}-alb-sg"
  description = "Security Group ALB"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_lb_target_group" "point_management" {
  name        = "target-group-point-management"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200,301,302"
    path                = "/health"
    timeout             = "5"
    unhealthy_threshold = "5"
  }
}

resource "aws_lb" "alb" {
  name               = "${var.app_name}-alb"
  internal           = true
  security_groups    = [aws_security_group.security_group_alb.id]
  load_balancer_type = "application"

  subnets = aws_subnet.private_subnet.*.id

  tags = local.tags
}

resource "aws_lb_listener" "listener_alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.point_management.id
    type             = "forward"
  }
}
