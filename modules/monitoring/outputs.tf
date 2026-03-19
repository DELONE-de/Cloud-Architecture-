output "sns_topic_arn" {
  value = aws_sns_topic.alarms.arn
}

output "ec2_cpu_alarm_name" {
  value = aws_cloudwatch_metric_alarm.ec2_cpu.alarm_name
}

output "alb_5xx_alarm_name" {
  value = aws_cloudwatch_metric_alarm.alb_5xx.alarm_name
}

output "rds_storage_alarm_name" {
  value = aws_cloudwatch_metric_alarm.rds_storage.alarm_name
}

output "dashboard_name" {
  value = aws_cloudwatch_dashboard.main.dashboard_name
}
