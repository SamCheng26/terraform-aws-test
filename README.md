A demostration of my work done.

![architect diagram](https://github.com/SamCheng26/terraform-test/assets/65500466/3e0aaffd-697e-46c9-ab1c-0d02abdeae1d)


Deploy EC2 instances in multiple AZs using Auto Scaling Groups, with an INTERMAL Application Load Balancer and ACM.

What will be deployed:
  
1. VPC
Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc

Subnets:
private-subnet-1 
private-subnet-2 
rds-subnet-1
rds-subnet-2
rds-subnet-3
public-subnet (for basion host and verification purpose)

route-table
route-table-association

2. ASG
asg-web 
asg-app
launch-configuration for asg-web
launch-configuration for asg-app
#both ASG are crossing two AZs. 

3. ALB
ALB-Web #internal ALB.
ALB-App #internal ALB
Register DNS Records in Route 53
Create an SSL certificate using AWS Certificate Manager
  

5. Session Manager
IAM profile for SSM.
Associate the profile with ASG instances by specifying the profile in LC.
Use AMI with SSM Agent pre-installed. Otherwise, install the agent in userdata.    

6. AWS Backup (Run after the main resources were created.)
Run after the ASG/RDS are created. To backup EBS and DB.

7. CloudWatch Monitoring
Alarm for high cpu.
Autoscaling policy -scale if alarm is triggered.

8. ASG Scheduler (Run after the main resources were created.)
Ensure both ASG have 0 instances running after 6pm during weekday and whole weekends. 
