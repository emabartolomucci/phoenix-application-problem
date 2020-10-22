# Phoenix Application problem


## An attempt at solving the Phoenix Application kata with the public cloud. 

This repository contains the code of the Phoenix Application and the CloudFormation templates required to deploy it on Amazon Web Services. The deployment is managed by two AWS CloudFormation templates, one to create a CI/CD pipeline and another one to create the relevant resources for a high-available infrastructure. 

The application is containerized and deployed on AWS Fargate in two Availability Zones for both resiliency and high availability. DocumentDB is used as a managed service to provide the MongoDB database required by the _Node.js_ application. The AWS Code Suite services (CodePipeline, CodeBuild, CodeDeploy) handle the CI/CD requirement.

The CloudFormation templates allow to deploy multiple stages (Development, QA, Production, etc.) creating replicas of the infrastructure. Once the pipeline is in place, a new build is created, uploaded to ECR and deployed on the Fargate cluster automatically every time a change is committed and pushed to the source code on GitHub. CodeDeploy is in charge of updating the existing infrastructure stack once the CodeBuild build is successful and uploaded to ECR.  

Here's a list of the AWS services that have been leveraged for this solution:

- CloudFormation
- Fargate
- ECR
- DocumentDB
- CodeBuild
- CodeDeploy
- CodePipeline
- VPC
- S3
- IAM
- CloudWatch


### Solution installation

These are the steps to launch the infrastructure:

1. Fork this repository or download and re-upload the code to another repo;

2. [Generate a new OAuth token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token) for the GitHub repository;

3. Launch the _Pipeline.yml_ template in CloudFormation filling in the input parameters accordingly;

4. Wait for all resources to be launched. This includes the second CloudFormation stack;

5. Open the link found under the Outputs tabs of the infrastructure stack to reach the endpoint of the running application. 


### Resource deletion

1. Delete the last stack that was automatically deployed by the pipeline first, the one related to the infrastructure;

2. In the first pipeline stack, under the Resources stack, open the S3 bucket and the ECR repository and empty them. If they are not empty, the stack deletion will fail;

3. Delete the pipeline stack. 


### Requirements 

1. _Automate the creation of the infrastructure and the setup of the application._

   This is done by leveraging CloudFormation as an IaC service. 

2. _Recover from crashes. Implement a method autorestart the service on crash_

   The application will always have the requested number of running tasks thanks to the ECS service. If one of more tasks are killed, new ones are launched to reach the number set by the _DesiredCount_ property.

3. _Backup the logs and database with rotation of 7 days_

   Logs from the Fargate containers and DocumentDB database are automatically exported to CloudWatch. 

4. _Notify any CPU peak_

    This has not been implemented (due to time constraints), but it can be easily achieved by setting up CloudWatch Alarms and one or more SNS topics that send an email to the interested parties to alert them. 

5. _Implements a CI/CD pipeline for the code_

    Done through CodePipeline as a native AWS service. Jenkins is probably the most popular alternative out there.

6. _Scale when the number of request are greater than 10 req /sec_

    This has not been implemented, at least not with the number of incoming requests as requested. The infrastructure CloudFormation template uses Application AutoScaling to automatically scale the number of running tasks based on the CPU utilization in the cluster (implementation not finalized nor tested due to time constraints).


### Potential improvements

- To improve overall security, deploy resources inside private subnets rather than public ones, especially when using physical EC2 instances and databases over serverless services. Bastion hosts in public subnets can be used to allow ingress SSH access to the instances in private subnets, as well as NAT Gateways for egress if needed. 

- The _AwsvpcConfiguration_ parameter for Fargate is set to use _AssignPublicIp: ENABLED_. It can be changed to DISABLED if private subnets that have access to a NAT gateway are used in the VPC.       

- The _rds-combined-ca-bundle.pem_ certificate file provided by AWS and necessary to connect to the DocumentDB cluster is included inside the application code. 

- GitHub is leveraged for this solution but CodeCommit could replace it for a more integrated service. 

- A different Infrastructure as code (IaC) tool such as Terraform or AWS CDK can be used to deploy the solution. CloudFormation is the native IaC service on AWS and it's very powerful, but it also has several flaws when compared to other services. 
