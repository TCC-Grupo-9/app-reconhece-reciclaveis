# Aplication Load Balancer
resource "aws_lb" "lb-tcc" {
  name               = "alb-tcc"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.sg-backend.id
  ]

  subnets = [
    aws_subnet.public-tcc-east_1a.id,
    aws_subnet.public-tcc-east_1b.id
  ]
}

resource "aws_lb_target_group" "tg-tcc" {
  name     = "tcc-target-group"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-tcc.id
}

resource "aws_lb_listener" "listener-tcc" {
  load_balancer_arn = aws_lb.lb-tcc.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-tcc.arn
  }
}