resource "aws_cloudwatch_event_rule" "start_weekdays" {
  name                = "start-weekdays"
  schedule_expression = "cron(0 1 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_rule" "stop_weekdays" {
  name                = "stop-weekdays"
  schedule_expression = "cron(0 10 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "start_asg_weekdays" {
  rule      = aws_cloudwatch_event_rule.start_weekdays.name
  target_id = "startASG"
  arn       = aws_lambda_function.autoscale_schedule.arn
  input     = <<EOF
{
  "time": "01:00:00"
}
EOF
}

resource "aws_cloudwatch_event_target" "stop_asg_weekdays" {
  rule      = aws_cloudwatch_event_rule.stop_weekdays.name
  target_id = "stopASG"
  arn       = aws_lambda_function.autoscale_schedule.arn
  input     = <<EOF
{
  "time": "10:00:00"
}
EOF
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.autoscale_schedule.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_weekdays.arn
}

/*
resource "aws_lambda_permission" "allow_cloudwatch_to_call_stop" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.autoscale_schedule.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_weekdays.arn
}
*/
