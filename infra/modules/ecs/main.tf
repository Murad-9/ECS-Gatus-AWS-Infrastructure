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


# IAM Policy Attatchment


resource "aws_iam_role_policy_attachment" "excecution_role_attatchment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

}


# CloudWatch Log Group


resource "aws_cloudwatch_log_group" "gatus" {
  name              = "/ecs/gatus"
  retention_in_days = 7

}


# ECS Task Definition


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
      image = "${var.repository_url}:${var.image_tag}"

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


# ECS Service 


resource "aws_ecs_service" "gatus-ecs-service" {
  name            = "gatus-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.gatus.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "gatus"
    container_port   = 8080
  }


  network_configuration {
    subnets = var.subnet_ids

    security_groups = [aws_security_group.gatus.id]

    assign_public_ip = true


  }




}


# Security Group



resource "aws_security_group" "gatus" {
  name   = "gatus_sg"
  vpc_id = var.vpc_id



  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]

  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}