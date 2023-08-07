resource "aws_cloudwatch_metric_alarm" "example" {
  count               = length(var.asg_names)
  alarm_name          = "${var.asg_names[count.index]}_cpu_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric triggers when CPU exceeds 80%"
  ok_actions          = [aws_sns_topic.myasg_sns_topic.arn]  
  alarm_actions       = [
    aws_autoscaling_policy.example[count.index].arn,
    aws_sns_topic.myasg_sns_topic.arn ]
  dimensions = {
    AutoScalingGroupName = var.asg_names[count.index]
  }
}

resource "aws_autoscaling_policy" "example" {
  count                  = length(var.asg_names)
  name                   = "${var.asg_names[count.index]}_cpu_high"
  autoscaling_group_name = var.asg_names[count.index]
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
  depends_on = [
    aws_autoscaling_group.asg-web,
    aws_autoscaling_group.asg-app
  ]
}