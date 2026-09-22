# Gatus AWS Architecture
An end-to-end deployment of Gatus on AWS ECS Fargate, provisioned with Terraform and automatically deployed through GitHub Actions.


## Technology Stack

### AWS & Infrastructure

![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazonaws&logoColor=white)
![ECS](https://img.shields.io/badge/Amazon-ECS-FF9900?logo=amazonaws&logoColor=white)
![Fargate](https://img.shields.io/badge/AWS-Fargate-FF9900?logo=amazonaws&logoColor=white)
![ECR](https://img.shields.io/badge/Amazon-ECR-FF9900?logo=amazonaws&logoColor=white)
![ALB](https://img.shields.io/badge/Application-Load_Balancer-8C4FFF?logo=amazonaws&logoColor=white)
![VPC](https://img.shields.io/badge/Amazon-VPC-8C4FFF?logo=amazonaws&logoColor=white)
![Route53](https://img.shields.io/badge/Amazon-Route_53-8C4FFF?logo=amazonaws&logoColor=white)
![ACM](https://img.shields.io/badge/AWS-Certificate_Manager-DD344C?logo=amazonaws&logoColor=white)
![IAM](https://img.shields.io/badge/AWS-IAM-DD344C?logo=amazonaws&logoColor=white)
![CloudWatch](https://img.shields.io/badge/Amazon-CloudWatch-FF4F8B?logo=amazonaws&logoColor=white)
![S3](https://img.shields.io/badge/Amazon-S3-569A31?logo=amazons3&logoColor=white)

### Infrastructure as Code & Containers

![Terraform](https://img.shields.io/badge/IaC-Terraform-844FBA?logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Container-Docker-2496ED?logo=docker&logoColor=white)
![Gatus](https://img.shields.io/badge/Monitoring-Gatus-2D3748)
![Go](https://img.shields.io/badge/Language-Go-00ADD8?logo=go&logoColor=white)

### CI/CD & Authentication

![GitHub Actions](https://img.shields.io/badge/CI/CD-GitHub_Actions-2088FF?logo=githubactions&logoColor=white)
![OIDC](https://img.shields.io/badge/Auth-OIDC-EB5424?logo=openid&logoColor=white)

### Development

![Git](https://img.shields.io/badge/Version_Control-Git-F05032?logo=git&logoColor=white)
![VS Code](https://img.shields.io/badge/Editor-VS_Code-007ACC?logo=visualstudiocode&logoColor=white)
![YAML](https://img.shields.io/badge/Config-YAML-CB171E?logo=yaml&logoColor=white)
![AWS CLI](https://img.shields.io/badge/CLI-AWS_CLI-232F3E?logo=amazonaws&logoColor=white)


## Project Overview


### What is this application?

Gatus is an open-source health monitoring application written in Go. It monitors endpoints such as websites and APIs and displays their availability, response time and health status through a web interface.

For this project, I containerised Gatus using my own multi-stage Dockerfile and deployed it to AWS ECS Fargate. The application runs on port 8080 behind an Application Load Balancer and is accessed through the custom domain `tm.gatuslabs.online` over HTTPS.

The infrastructure is provisioned using Terraform and the deployment process is automated using GitHub Actions. Docker images are built and tagged using the Git commit SHA before being pushed to Amazon ECR and deployed to ECS.


### Why did I choose Gatus?

I chose Gatus because it is a lightweight application that works well in a containerised environment while still giving me the opportunity to build a realistic cloud deployment around it.

Rather than focusing mainly on application development, I wanted this project to focus on DevOps skills such as Docker, Terraform, AWS networking, ECS, load balancing, HTTPS, CI/CD and secure authentication.


### Why did I host it on ECS?


I chose ECS Fargate because I wanted to deploy and manage a containerised application without having to manage the underlying EC2 servers.

Using a traditional virtual machine would mean provisioning the server, installing Docker, managing the operating system and maintaining the instance myself. Fargate allows AWS to manage the underlying compute while I focus on the container, networking and infrastructure configuration.

Services such as Vercel or Netlify would make deployment simpler, but they would abstract away many of the AWS and DevOps concepts that I wanted to practise in this project.

Using ECS allowed me to work directly with services such as ECR, IAM, VPC networking, Application Load Balancers, CloudWatch and Terraform.


### How many users am I expecting?

This is a portfolio and learning project rather than a production application with a large user base, so I expect very low traffic.

Because of this, the ECS service currently runs with a desired count of one Fargate task. The Application Load Balancer still spans two Availability Zones, and the ECS service is configured with both public subnets so the task can be placed in either Availability Zone.

If the application needed to support significantly more traffic in the future, the architecture could be extended by increasing the number of ECS tasks and introducing ECS Service Auto Scaling.



## Architecture

The infrastructure is deployed in AWS `eu-west-1` using Terraform.

The application runs on Amazon ECS Fargate inside a custom VPC with two public subnets across two Availability Zones. An internet-facing Application Load Balancer distributes traffic to the ECS service, while Route 53 provides DNS and AWS Certificate Manager provides HTTPS.

Docker images are built through GitHub Actions, tagged with the Git commit SHA and pushed to Amazon ECR. ECS then runs the image as a Fargate task.

Terraform uses an encrypted Amazon S3 backend with native state locking to store and protect the remote Terraform state. Application logs are sent from ECS to Amazon CloudWatch Logs.

<p align="center">
  <img src="assets/architecture/GATUS_AWS.jpeg" alt="Gatus AWS Architecture" width="100%">
</p>


## Project Structure

The repository is organised into separate areas for the application, infrastructure, CI/CD and project documentation.


```text
ECS-Gatus-AWS-Infrastructure/
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── app/
│   ├── main.go
│   ├── config.yaml
│   ├── go.mod
│   ├── go.sum
│   └── ...Gatus application source code
│
├── assets/
│   └── architecture/
│       └── GATUS_AWS.jpeg
│
├── infra/
│   ├── modules/
│   │   ├── acm/
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   │
│   │   ├── alb/
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   │
│   │   ├── ecr/
│   │   │   ├── main.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── ecs/
│   │   │   ├── main.tf
│   │   │   └── variables.tf
│   │   │
│   │   ├── route53/
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   │
│   │   └── vpc/
│   │       ├── main.tf
│   │       └── outputs.tf
│   │
│   ├── backend.tf
│   ├── main.tf
│   └── variables.tf
│
├── Dockerfile
├── .dockerignore
├── .gitignore
└── README.md
``` 

- **`app/`** contains the Gatus application source code and configuration.
- **`infra/`** contains the Terraform configuration and reusable infrastructure modules.
- **`.github/workflows/`** contains the GitHub Actions CI/CD workflow.
- **`assets/`** contains images used by the README, including the architecture diagram.
- **`Dockerfile`** contains the multi-stage container build used to package Gatus.



## Implementation Walkthrough

### 1. Containerising Gatus

I started by creating my own multi-stage Dockerfile for Gatus.

The build stage uses a Go Alpine image to install dependencies and compile the application. The final stage uses a minimal `scratch` image so the runtime container only contains what it needs.

I also run the application as a non-root user instead of root.

Gatus runs on port `8080`, which is the port later used by ECS and the Application Load Balancer.

### 2. Building the AWS Network

I created a custom VPC using the CIDR range `10.0.0.0/16`.

Inside the VPC I created two public subnets across two Availability Zones:

- `10.0.1.0/24` in `eu-west-1a`
- `10.0.2.0/24` in `eu-west-1b`

Both subnets use a route table with a default route through an Internet Gateway.

For this project I chose public subnets rather than private subnets with a NAT Gateway to keep the architecture simpler and avoid the extra NAT Gateway cost.

The ECS task still isn't directly open on port `8080` because its security group only allows traffic from the ALB security group.

### 3. Deploying with ECS Fargate

I used ECS Fargate to run the Gatus container without having to manage the underlying EC2 instances.

The ECS service currently uses:

- `desired_count = 1`
- `0.25 vCPU`
- `512 MiB` memory
- Port `8080`

A desired count of `1` means ECS keeps one Gatus task running.

The service is configured with both public subnets, so AWS can place the task in either Availability Zone.