# provider

provider "aws" {
  region = "eu-west-1"

}


## VPC with public subnets

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

}

resource "aws_subnet" "public_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

}

resource "aws_subnet" "public_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

}

# Internet Gateway

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

}

# route table

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id

  }


}

# route table association

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.main.id

}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.main.id

}

# ECR

resource "aws_ecr_repository" "gatus" {
  name = "gatus-terraform"

}

# ECS Cluster

resource "aws_ecs_cluster" "main" {
  name = "gatus"

}

# IAM Role

resource "aws_iam_role" "ecs_execution_role" {
  name = "gatus_ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })


}

# IAM policy attatchment

resource "aws_iam_role_policy_attachment" "excecution_role_attatchment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

}

# Security Groups

resource "aws_security_group" "alb" {
  name   = "gatus_alb_sg"
  vpc_id = aws_vpc.main.id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}


resource "aws_security_group" "gatus" {
  name   = "gatus_sg"
  vpc_id = aws_vpc.main.id



  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]

  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}

# ALB

resource "aws_lb" "main" {
  name            = "gatus-alb"
  security_groups = [aws_security_group.alb.id]
  internal        = false

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id


  ]


}

# alb target group

resource "aws_lb_target_group" "gatus_tg" {
  name        = "target-group"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path = "/health"
  }

}

# ALB listener

resource "aws_lb_listener" "port-80-listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_lb_listener" "listener-443" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.gatus.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gatus_tg.arn
  }

}

# ACM 

resource "aws_acm_certificate" "gatus" {
  domain_name       = "tm.gatuslabs.online"
  validation_method = "DNS"

}

# route 53 zone

data "aws_route53_zone" "primary" {
  name = "gatuslabs.online"

}

# route 53 record

resource "aws_route53_record" "validation" {
  zone_id = data.aws_route53_zone.primary.zone_id


  for_each = {
    for dvo in aws_acm_certificate.gatus.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type

}

# route 53 record

resource "aws_route53_record" "gatus" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "tm.gatuslabs.online"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# ACM certif validation

resource "aws_acm_certificate_validation" "gatus" {
  certificate_arn         = aws_acm_certificate.gatus.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]

}

# ECS config

resource "aws_ecs_task_definition" "gatus" {
  family                   = "gatus"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn



  container_definitions = jsonencode([
    {
      name  = "gatus"
      image = "${aws_ecr_repository.gatus.repository_url}:latest"

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.gatus.name
          "awslogs-region"        = "eu-west-1"
          "awslogs-stream-prefix" = "ecs"
        }



      }
    }



  ])

}

# CloudWatch 

resource "aws_cloudwatch_log_group" "gatus" {
  name              = "/ecs/gatus"
  retention_in_days = 7

}


# ECS Service 

resource "aws_ecs_service" "gatus-ecs-service" {
  name            = "gatus-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.gatus.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.gatus_tg.arn
    container_name   = "gatus"
    container_port   = 8080
  }


  network_configuration {
    subnets = [
      aws_subnet.public_1.id,
      aws_subnet.public_2.id
    ]



    security_groups = [aws_security_group.gatus.id]

    assign_public_ip = true


  }




}