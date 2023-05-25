terraform {
  required_version = ">= 1.1.4, < 1.5.0"

    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = ">= 4.67"
      }
    }
}
provider "aws"{
  region = "eu-central-1"
}
# data "aws_iam_role" "task_ecs" {
#   name = "ecsTaskExecutionRole"
# }

# Create the ECS cluster
resource "aws_ecs_cluster" "cluster" {
  name = "candidateCluster"
  setting {
    name = "containerInsights"
    value = "enabled"
  }
}

# Create the ECS task definition
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "helloWorld"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = "arn:aws:iam::303981612052:role/ecsTaskExecutionRole"
  task_role_arn = "arn:aws:iam::303981612052:role/ecsTaskExecutionRole"
  container_definitions = <<EOF
  [
    {
      "name": "candidate-app",
      "image": "redbarondr1/cadidate-app:1.0",
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000,
          "protocol": "tcp",
          "appProtocol": "http"
        }
      ],
      "essential": true
    }
  ]
  EOF
  }

# Create the ECS service
resource "aws_ecs_service" "service" {
  name            = "candidate-app"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2

  launch_type = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.service.id]
    subnets = ["subnet-ddb3ada0","subnet-577f921b","subnet-8d9d3ee7"]
    assign_public_ip = true
  }
}

# Create the security group for the ECS service
resource "aws_security_group" "service" {
  name        = "your_service_security_group"
  description = "Security group for your ECS service"

  vpc_id = "vpc-c1fa01ab"

  ingress {
    from_port   = 80
    to_port     = 5000
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


