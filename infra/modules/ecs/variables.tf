# Subnet Variable


variable "subnet_ids" {
  type = list(string)
}


# Target Group ARN


variable "target_group_arn" {
  type = string
}

# ECR 


variable "repository_url" {
  type = string
}


# ALB Security Group


variable "alb_security_group_id" {
  type = string
}


# VPC ID


variable "vpc_id" {
  type = string
}



variable "image_tag" {
  type = string
}