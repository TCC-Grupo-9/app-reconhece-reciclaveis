# Aplication Load Balancer
resource "aws_lb" "lb-fastlog" {
  name               = "alb-fastlog"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.conexao_backend.id]
  subnets            = [
    aws_subnet.public-fastlog-east_1a.id,
    aws_subnet.public-fastlog-east_1b.id
  ]
}

resource "aws_lb_target_group" "tg-fastlog" {
  name     = "fastlog-target-group"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-fastlog.id
}

resource "aws_lb_listener" "listener-fastlog" {
  load_balancer_arn = aws_lb.lb-fastlog.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-fastlog.arn
  }
}