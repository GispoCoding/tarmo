# The application will be reachable from public internet via a publi Application Load Balancer
resource "aws_lb" "tileserver" {
  name               = "${var.prefix}-tileserver"
  internal           = false
  # We use Application Load Balancer: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = aws_subnet.public.*.id
  idle_timeout       = 900

  tags = merge(local.default_tags, { Name = "${var.prefix}-lb-tileserver" })
}

#
# Routing
#

# Targets to the load balancer are registered by IP address, into the following target group
resource "aws_lb_target_group" "tileserver" {
  name                 = "${var.prefix}-tileserver"
  port                 = var.pg_tileserv_port
  protocol             = "HTTP"
  deregistration_delay = 30
  vpc_id               = aws_vpc.main.id
  target_type          = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 10
  }

  depends_on = [
    aws_lb.tileserver
  ]

  tags = merge(local.default_tags, {
    Name = "${var.prefix}-lb-target-group"
  })

}

# The default route will point all traffic to the target group
resource "aws_lb_listener" "tileserver" {
  load_balancer_arn = aws_lb.tileserver.arn
  port              = var.enable_route53_record ? 443: 80
  protocol          = var.enable_route53_record ? "HTTPS" : "HTTP"
  ssl_policy        = var.enable_route53_record  ? "ELBSecurityPolicy-2016-08" : null
  certificate_arn   = var.enable_route53_record  ? aws_acm_certificate.tileserver[0].arn : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tileserver.arn
  }
  tags = merge(local.default_tags, { Name = "${var.prefix}-lb-default-listener" })
}

resource "aws_lb_listener" "http" {
  count             = var.enable_route53_record ? 1 : 0
  load_balancer_arn = aws_lb.tileserver.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
    target_group_arn = aws_lb_target_group.tileserver.arn
  }
  tags = merge(local.default_tags, { Name = "${var.prefix}-lb-http-listener" })
}
