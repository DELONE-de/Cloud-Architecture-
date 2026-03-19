# --- SNS Topic for alarm notifications ---
resource "aws_sns_topic" "alarms" {
  name = "${var.env}-alarm-notifications"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# --- EC2 Alarm: CPU > 80% ---
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name          = "${var.env}-ec2-cpu-high"
  alarm_description   = "EC2 CPU utilization exceeded 80%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
}

# --- ALB Alarm: 5xx errors ---
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.env}-alb-5xx-errors"
  alarm_description   = "ALB 5xx error count is too high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
}

# --- RDS Alarm: Free storage < 10GB ---
resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "${var.env}-rds-low-storage"
  alarm_description   = "RDS free storage is below 10GB"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 10737418240 # 10GB in bytes

  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
}

# --- CloudWatch Dashboard ---
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.env}-infrastructure"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "EC2 CPU Utilization"
          metrics = [["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name]]
          period = 120
          stat   = "Average"
        }
      },
      {
        type = "metric"
        properties = {
          title  = "ALB 5xx Errors"
          metrics = [["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", var.alb_arn_suffix]]
          period = 60
          stat   = "Sum"
        }
      },
      {
        type = "metric"
        properties = {
          title  = "RDS Free Storage"
          metrics = [["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.db_identifier]]
          period = 300
          stat   = "Average"
        }
      }
    ]
  })
}
