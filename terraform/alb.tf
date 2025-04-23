# Aplication Load Balancer
resource "aws_lb" "fastlog_alb" {
  name               = "fastlog-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.conexao_backend.id]
  subnets            = [
    aws_subnet.public-fastlog-east_1a.id,
    aws_subnet.public-fastlog-east_1b.id
  ]
}

resource "aws_lb_target_group" "fastlog_tg" {
  name     = "fastlog-target-group"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-fastlog.id
}

resource "aws_lb_listener" "fastlog_listener" {
  load_balancer_arn = aws_lb.fastlog_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fastlog_tg.arn
  }
}