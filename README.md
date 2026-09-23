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


## From ClickOps to Infrastructure as Code

Before building the final infrastructure with Terraform, I first deployed the architecture manually through the AWS Console.

This helped me understand how the individual AWS services connected before trying to automate everything.

During the ClickOps stage I worked with services including:

- VPC networking, public subnets, routing and an Internet Gateway
- Amazon ECR for storing the Docker image
- Amazon ECS with Fargate
- ECS task definitions and services
- Application Load Balancer and target groups
- Security groups
- Route 53
- AWS Certificate Manager for HTTPS
- CloudWatch logging

Once I had the application working manually, I removed the manually created resources and rebuilt the infrastructure using reusable Terraform modules.

The final stage was automating the deployment with GitHub Actions so that changes to the application could build a new Docker image, push it to ECR and apply any required infrastructure changes and deploy the updated ECS service.

This gave me experience with the same architecture through three stages:

**ClickOps → Terraform → CI/CD**



## Implementation Walkthrough

### 1. Containerising Gatus

I started by creating my own multi-stage Dockerfile for Gatus.

The build stage uses a Go Alpine image to install dependencies and compile the application. The final stage uses a minimal `scratch` image so the runtime container only contains what it needs.

I also run the application as a non-root user instead of root.

Gatus listens on port `8080`. ECS exposes this container port, while the Application Load Balancer receives traffic on ports `80` and `443` and forwards requests through the target group to the ECS task on port `8080`.

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


### 4. Adding the Application Load Balancer

I added an internet-facing Application Load Balancer across both public subnets to provide a single entry point for the application.

The ALB receives incoming web traffic and forwards it to the ECS task through a target group.

The target group uses `ip` as its target type because Fargate tasks use their own network interfaces and IP addresses. Traffic is forwarded to the Gatus container on port `8080`.

I configured the target group to use `/health` for health checks. This allows the ALB to check whether the Gatus task is healthy before sending traffic to it.

The ALB security group allows inbound traffic on ports `80` and `443`, while the ECS security group only allows traffic on port `8080` when it comes from the ALB security group.



### 5. Adding a Custom Domain and HTTPS

I used Route 53 to connect the custom domain `tm.gatuslabs.online` to the Application Load Balancer.

The Route 53 `A` record is configured as an alias to the ALB, so requests to the domain are sent to the load balancer.

I used AWS Certificate Manager to request an SSL/TLS certificate for `tm.gatuslabs.online`.

The certificate uses DNS validation, and Terraform creates the required Route 53 validation record automatically.

The ALB has an HTTPS listener on port `443` using the ACM certificate. Requests arriving on port `80` are redirected to HTTPS on port `443`.

This means the application can be accessed securely through the custom domain rather than directly through the ALB DNS name.


### 6. Terraform Modules and Remote State

I initially built the Terraform configuration in a single file so I could get the infrastructure working and understand how the resources connected.

Once the deployment was working, I refactored the configuration into separate modules for the VPC, ECS, ECR, Application Load Balancer, Route 53 and ACM.

This made the infrastructure easier to read, maintain and reuse.

The root Terraform configuration connects these modules together by passing outputs between them. For example, the VPC module provides the VPC and subnet IDs required by the ALB and ECS modules, while the ECR module provides the repository URL used by the ECS task definition.

Instead of storing the Terraform state locally, I configured an Amazon S3 remote backend.

The state is stored in the `gatus-ecs-terraform-state` S3 bucket with encryption enabled.

I also enabled native S3 state locking using `use_lockfile = true`. This prevents multiple Terraform processes from changing the same state at the same time, reducing the risk of conflicting changes or state corruption.



### 7. Automating Deployment with GitHub Actions and OIDC

I automated the deployment process using GitHub Actions.

When changes are pushed to the `main` branch, the workflow checks out the repository, configures AWS credentials, initialises Terraform, builds the Docker image, pushes it to Amazon ECR and applies any required Terraform changes.

Docker images are tagged using the Git commit SHA instead of only using a `latest` tag. This makes it possible to trace a deployed container image back to the exact commit that produced it.

For AWS authentication, I used OpenID Connect (OIDC) rather than storing long-lived AWS access keys as GitHub secrets.

GitHub Actions assumes the `GitHubActions-Gatus` IAM role and receives temporary AWS credentials for the workflow run.

After the Terraform deployment completes, the workflow forces a new ECS service deployment so the latest task definition and container image are used.

README and architecture-only changes are excluded from the deployment trigger, so documentation updates do not unnecessarily rebuild or redeploy the application.