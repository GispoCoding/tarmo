# The application will be reachable from public internet via a publi Application Load Balancer
resource "aws_lb" "tileserver" {
  name               = "tarmo-tileserver"
  internal           = false
  # We use Application Load Balancer: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = aws_subnet.public.*.id
  idle_timeout       = 900
}

#
# Routing
#

# Targets to the load balancer are registered by IP address, into the following target group
resource "aws_lb_target_group" "tileserver" {
  name                 = "tarmo-tileserver"
  port                 = var.pg_tileserv_port
  protocol             = "HTTP"
  deregistration_delay = 30
  vpc_id               = aws_vpc.main.id
  target_type          = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = "/api/status"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  depends_on = [
    aws_lb.tileserver
  ]

  tags = {
    Name = "tarmo-lb-target-group"
  }

}

# The default route will point all traffic to the target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.tileserver.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tileserver.arn
  }
}
