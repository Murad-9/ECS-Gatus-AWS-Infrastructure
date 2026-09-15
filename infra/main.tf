# VPC Module

module "vpc" {
  source = "./modules/vpc"
}


# ECS Module

module "ecs" {
  source         = "./modules/ecs"
  repository_url = module.ecr.repository_url
  image_tag = var.image_tag
  vpc_id         = module.vpc.vpc_id

  subnet_ids = [
    module.vpc.public_subnet_1_id,
    module.vpc.public_subnet_2_id
  ]

  alb_security_group_id = module.alb.security_group_id
  target_group_arn      = module.alb.target_group_arn

}


# ALB Module


module "alb" {
  source = "./modules/alb"

  vpc_id = module.vpc.vpc_id

  subnet_ids = [
    module.vpc.public_subnet_1_id,
    module.vpc.public_subnet_2_id
  ]


  certificate_arn = module.acm.certificate_arn
}


# ECR Module

module "ecr" {
  source = "./modules/ecr"
}


# Route53 Module


module "route53" {
  source = "./modules/route53"

  domain_validation_options = module.acm.domain_validation_options

  alb_dns_name = module.alb.load_balancer_dns_name
  alb_zone_id  = module.alb.load_balancer_zone_id
}


# ACM Module


module "acm" {
  source = "./modules/acm"

  validation_record_fqdns = module.route53.validation_record_fqdns
}



# provider

provider "aws" {
  region = "eu-west-1"

}

