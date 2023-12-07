resource "aws_security_group" "linux-application-load-balancer-security-group" {
  name        = "${lower(var.app_name)}-${var.app_environment}-linux-application-load-balancer-security-group"
  description = "Allow web traffic to the load balancer"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "linux-application-load-balancer-security-group"
    Environment = var.app_environment
  }
}

resource "aws_lb" "linux-application-load-balancer" {
  name               = "linux-application-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.linux-application-load-balancer-security-group.id]
  
  subnets = [
    aws_subnet.public-network-1.id,
    aws_subnet.public-network-2.id
  ]

  enable_deletion_protection = false
  enable_http2               = false

  tags = {
    Name        = "linux-application-load-balancer"
    Environment = var.app_environment
  }
}

resource "aws_lb_target_group" "linux-application-load-balancer-target-group-http" {
  name     = "load-balancer-target-group-http"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  load_balancing_algorithm_type = "round_robin"

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  health_check {
    path                = "/"
    port                = 80
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_alb_target_group_attachment" "linux-application-load-balancer-target-group-http-attach" {
  count = var.ec2_count
  target_group_arn = aws_lb_target_group.linux-application-load-balancer-target-group-http.arn
  target_id        = aws_instance.linux-server[count.index].id
  port             = 80
}

resource "aws_lb_listener" "linux-application-load-balancer-listener-http" {
  depends_on = [
    aws_lb.linux-application-load-balancer,
    aws_lb_target_group.linux-application-load-balancer-target-group-http
  ]

  load_balancer_arn = aws_lb.linux-application-load-balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.linux-application-load-balancer-target-group-http.arn
    type             = "forward"
  }
}