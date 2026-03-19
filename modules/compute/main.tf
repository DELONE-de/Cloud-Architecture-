# --- Launch Template ---
resource "aws_launch_template" "app" {
  name_prefix   = "${var.env}-app-"
  image_id      = var.ami_id
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_sg_id]
  }

  user_data = filebase64("${path.module}/init.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.env}-app-server"
    }
  }
}

# --- Auto Scaling Group ---
resource "aws_autoscaling_group" "app" {
  name                      = "${var.env}-app-asg"
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 4
  vpc_zone_identifier       = [var.private_subnet_id]
  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.env}-app-asg"
    propagate_at_launch = true
  }
}

# --- Auto Scaling Policy (CPU-based) ---
resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.env}-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}

# --- Application Load Balancer (public subnet) ---
resource "aws_lb" "app" {
  name               = "${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = [var.public_subnet_id]

  tags = {
    Name = "${var.env}-alb"
  }
}

# --- Target Group (private EC2 instances) ---
resource "aws_lb_target_group" "app" {
  name     = "${var.env}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
  }
}

# --- ALB Listener ---
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
