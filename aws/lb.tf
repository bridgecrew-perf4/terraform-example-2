resource "aws_lb" "alb_front" {
  drop_invalid_header_fields = "false"
  enable_deletion_protection = "false"
  enable_http2               = "true"
  idle_timeout               = "60"
  internal                   = "false"
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  name                       = "${var.name}-lb-front"
  security_groups            = [aws_security_group.front.id]

//  subnet_mapping {
//    subnet_id = aws_subnet.sn1a_pub.id
//  }
//
//  subnet_mapping {
//    subnet_id = aws_subnet.sn1b_pub.id
//  }
//
//  subnet_mapping {
//    subnet_id = aws_subnet.sn1c_pub.id
//  }

  subnets = [aws_subnet.sn1a_pub.id, aws_subnet.sn1b_pub.id]
}

###
# Certificates
###

data "aws_acm_certificate" "issued" {
  domain   = "*.example.com"
  statuses = ["ISSUED"]
}

###
# Load Balancer Listeners
###

resource "aws_lb_listener" "front_https" {
  certificate_arn = data.aws_acm_certificate.issued.arn

  default_action {
    order            = "1"
    target_group_arn = aws_lb_target_group.app.arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.alb_front.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}

resource "aws_lb_listener" "front_http" {
  default_action {
    order = "1"

    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }

    type = "redirect"
  }

  load_balancer_arn = aws_lb.alb_front.arn
  port              = "80"
  protocol          = "HTTP"
}

###
# Listener Rules
###

resource "aws_lb_listener_rule" "api" {
  action {
    order            = "1"
    target_group_arn = aws_lb_target_group.api.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = ["api.example.com"]
    }
  }

  listener_arn = aws_lb_listener.front_https.arn
  priority     = "2"
}

resource "aws_lb_listener_rule" "web" {
  action {
    order = "1"
    target_group_arn = aws_lb_target_group.app.arn
    type = "forward"
  }

  condition {
    host_header {
      values = [
        "web.example.com"]
    }
  }

  listener_arn = aws_lb_listener.front_https.arn
  priority = "4"
}

###
# Target Groups
###

resource "aws_lb_target_group" "api" {
  deregistration_delay = "300"

  health_check {
    enabled             = "true"
    healthy_threshold   = "5"
    interval            = "30"
    matcher             = "200"
    path                = "/healthz"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
    unhealthy_threshold = "2"
  }

  load_balancing_algorithm_type = "round_robin"
  name                          = "${var.name}-tg-api"
  port                          = var.api_port
  protocol                      = "HTTP"
  slow_start                    = "0"

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }

  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id
}


resource "aws_lb_target_group" "app" {
  deregistration_delay = "300"

  health_check {
    enabled             = "true"
    healthy_threshold   = "5"
    interval            = "30"
    matcher             = "200"
    path                = "/healthz"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
    unhealthy_threshold = "2"
  }

  load_balancing_algorithm_type = "round_robin"
  name                          = "${var.name}-tg-app"
  port                          = var.web_port
  protocol                      = "HTTP"
  slow_start                    = "0"

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }

  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id
}

###
# Target group attachments
###

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = module.web.id
}

resource "aws_lb_target_group_attachment" "api" {
  target_group_arn = aws_lb_target_group.api.arn
  target_id        = module.api.id
}

