# Create the ECS cluster
resource "aws_ecs_cluster" "cluster" {
  name = "candidateCluster"
  setting {
    name = "containerInsights"
    value = "enabled"
  }
}

# Create the ECS task definition. This can be removed once the cluster is installed, as it should get deployed by the CD pipeline.
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "helloWorld"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.resources.example-service.cpu
  memory                   = var.resources.example-service.memory

  execution_role_arn = var.rolearn
  task_role_arn = var.rolearn

  container_definitions = <<EOF
  [
    {
      "name": "candidate-app",
      "image": "redbarondr1/candidate-app:sha-b15667b",
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000,
          "protocol": "tcp",
          "appProtocol": "http"
        }
      ],
      "essential": true,
      "HealthCheck": {
        "Command": [
            "CMD-SHELL",
            "curl -f http://localhost:5000/ || exit 1"
        ],
        "Interval": 10,
        "Timeout": 2,
        "Retries": 3,
        "StartPeriod": 10
      }
    }
  ]
  EOF
  }

# Create the ECS service, consisting of a two load-balanced tasks, using the three subnets.
resource "aws_ecs_service" "service" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2

  launch_type = "FARGATE"

  network_configuration {
    subnets = data.aws_subnets.default.ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.arn
    container_name   = var.app_name
    container_port   = var.container_port
 }
}

