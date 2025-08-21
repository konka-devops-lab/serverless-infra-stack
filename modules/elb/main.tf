locals {
  name           = "${var.environment}-${var.project}-${var.lb_name}"
  s3_bucket_name = "${local.name}-lb-logs"
}
resource "aws_s3_bucket" "example" {
  bucket        = local.s3_bucket_name
  force_destroy = true
  tags = merge(
    {
      Name = local.name
    },
    var.common_tags
  )
}
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "alb_log_delivery" {
  bucket = aws_s3_bucket.example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSALBLoggingPolicy"
        Effect = "Allow"
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.example.arn}/${local.name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_lb" "test" {
  name               = var.lb_name
  internal           = var.choose_internal_external
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_groups
  subnets            = var.subnets
  enable_zonal_shift = var.enable_zonal_shift

  enable_deletion_protection = var.enable_deletion_protection

  access_logs {
    bucket  = aws_s3_bucket.example.id
    prefix  = local.name
    enabled = true
  }

  tags = merge(
    {
      Name = local.name
    },
    var.common_tags
  )
}

resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = var.record_name
  type    = "A"

  alias {
    name                   = aws_lb.test.dns_name
    zone_id                = aws_lb.test.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_target_group" "example" {
  name     = var.lb_name
  port     = var.tg_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  tags = merge(
    {
      Name = local.name
    },
    var.common_tags
  )
}

# Internal ALB (HTTP only)
resource "aws_lb_listener" "http" {
  count             = var.choose_internal_external && var.enable_http ? 1 : 0
  load_balancer_arn = aws_lb.test.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

# External ALB (HTTPS + HTTP with conditional rules)
resource "aws_lb_listener" "https" {
  count             = !var.choose_internal_external && var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.test.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

resource "aws_lb_listener" "http_external" {
  count             = !var.choose_internal_external && var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.test.arn
  port              = 80
  protocol          = "HTTP"

  # Default action is redirect
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Rule to forward health checks on port 80
resource "aws_lb_listener_rule" "health_check" {
  depends_on = [aws_lb_listener.http_external]
  count      = !var.choose_internal_external && var.enable_https ? 1 : 0
  listener_arn = aws_lb_listener.http_external[0].arn
  priority     = 100  # Higher priority than default

  # Optional: Add conditions if needed (e.g., path_pattern, host_header)
  condition {
    path_pattern {
      values = [var.health_check_path]
    }
  }

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Healthy"  # Custom response message
      status_code  = "200"      # HTTP status code
    }
  }
}