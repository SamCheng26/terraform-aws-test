import boto3
import os

autoscaling = boto3.client('autoscaling')

def lambda_handler(event, context):
    asg_names = os.environ['ASG_NAMES'].split(',')
    for asg_name in asg_names:
        response = autoscaling.describe_auto_scaling_groups(
            AutoScalingGroupNames=[
                asg_name,
            ]
        )

        asg = response['AutoScalingGroups'][0]

        if event['time'] < '10:00:00':
            autoscaling.update_auto_scaling_group(
                AutoScalingGroupName=asg_name,
                MinSize=asg['MinSize'],
                MaxSize=asg['MaxSize'],
                DesiredCapacity=asg['DesiredCapacity']
            )
        else:
            autoscaling.update_auto_scaling_group(
                AutoScalingGroupName=asg_name,
                MinSize=0,
                MaxSize=0,
                DesiredCapacity=0
            )
