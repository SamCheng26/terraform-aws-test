resource "aws_launch_configuration" "agent-lc-app" {
    name_prefix = "agent-lc-app-"
    image_id = var.ami
    instance_type = var.instance_type
    key_name = aws_key_pair.key_pair.key_name
    #iam_instance_profile = aws_iam_instance_profile.session_manager_profile.name
    iam_instance_profile   = aws_iam_instance_profile.dev-resources-iam-profile.name
    security_groups = [aws_security_group.websg.id]
    user_data = file("lc-userdata-app.sh")

    lifecycle {
        create_before_destroy = true
    }

    root_block_device {
        volume_type = "gp2"
        volume_size = "8"
    }
}
