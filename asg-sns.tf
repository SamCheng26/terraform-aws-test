# Autoscaling Notifications
## AWS Bug for SNS Topic: https://stackoverflow.com/questions/62694223/cloudwatch-alarm-pending-confirmation
## Due to that create SNS Topic with unique name 

## SNS - Topic
resource "aws_sns_topic" "myasg_sns_topic" {
  name = "myasg-sns-topic"
}

## SNS - Subscription
resource "aws_sns_topic_subscription" "myasg_sns_topic_subscription" {
  topic_arn = aws_sns_topic.myasg_sns_topic.arn
  protocol  = "email"
  endpoint  = "sam.cheng.sg@gmail.com"
}

## Create Autoscaling Notification Resource
resource "aws_autoscaling_notification" "asg-web_notifications" {
  group_names = [aws_autoscaling_group.asg-web.id]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
  topic_arn = aws_sns_topic.myasg_sns_topic.arn 
}

resource "aws_autoscaling_notification" "asg-app_notifications" {
  group_names = [aws_autoscaling_group.asg-app.id]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
  topic_arn = aws_sns_topic.myasg_sns_topic.arn 
}