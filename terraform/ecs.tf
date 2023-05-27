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
  cpu                      = "1024"
  memory                   = "2048"

  execution_role_arn = var.rolearn
  task_role_arn = var.rolearn

  container_definitions = <<EOF
  [
    {
      "name": "candidate-app",
      "image": "redbarondr1/candidate-app:2.2",
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
    subnets = var.subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.arn
    container_name   = "candidate-app"
    container_port   = var.container_port
 }
}

# Create the security group for the ECS service
resource "aws_security_group" "service" {
  name        = "your_service_security_group"
  description = "Security group for your ECS service"

  vpc_id = var.vpcid

  ingress {
    from_port   = 80
    to_port     = var.container_port
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
