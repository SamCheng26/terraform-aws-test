A demostration of my work done.

![architect diagram](https://github.com/SamCheng26/terraform-aws-test/assets/65500466/07dd8096-9127-47dc-adc3-a142db239ea1)


What have been defined:
  
1. VPC Subnets:
private-subnet-1, 
private-subnet-2, 
private-subnet-3,
rds-subnet-1,
rds-subnet-2,
rds-subnet-3,
public-subnet (for basion host and verification purpose),
route-tables,
route-table-associations

2. ASG:
asg-web, 
asg-app,
launch-configuration for asg-web,
launch-configuration for asg-app
#both ASG are crossing two AZs. 

3. ALB:
ALB-Web #internal ALB,
ALB-App #internal ALB,
Register DNS Records in Route 53,
Create an SSL certificate using AWS Certificate Manager
  

4. Session Manager:
IAM profile for SSM.
Associate the profile with ASG instances by specifying the profile in LC.
Use AMI with SSM Agent pre-installed. Otherwise, install the agent in userdata.    

5. AWS Backup (Run after the main resources were created.):
Run after the ASG/RDS are created. To backup EBS and DB.

6. CloudWatch Monitoring:
Alarm for high cpu.
Autoscaling policy -scale if alarm is triggered.

7. ASG Scheduler (Run after the main resources were created.):
Ensure both ASG have 0 instances running after 6pm during weekday and whole weekends. 
