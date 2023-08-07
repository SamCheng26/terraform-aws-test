resource "aws_autoscaling_group" "asg-web" {
    #availability_zones = ["ap-southeast-1a","ap-southeast-1b"]
    name = "asg-web"
    max_size = "4"
    min_size = "2"
    health_check_grace_period = 300
    health_check_type = "EC2"
    desired_capacity = 2
    force_delete = true
    vpc_zone_identifier  = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
    launch_configuration = aws_launch_configuration.agent-lc-web.name
    target_group_arns = [aws_lb_target_group.alb-web-target-group-http.arn]

    tag {
        key = "Name"
        value = "Web Agent Instance"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_group" "asg-app" {
    #availability_zones = ["ap-southeast-1a","ap-southeast-1b"]
    name = "asg-app"
    max_size = "4"
    min_size = "2"
    health_check_grace_period = 300
    health_check_type = "EC2"
    desired_capacity = 2
    force_delete = true
    vpc_zone_identifier  = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
    launch_configuration = aws_launch_configuration.agent-lc-app.name
    target_group_arns = [aws_lb_target_group.alb-app-target-group-http.arn]

    tag {
        key = "Name"
        value = "App Agent Instance"
        propagate_at_launch = true
    }
}