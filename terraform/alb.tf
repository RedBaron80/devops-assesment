resource "aws_lb" "main" {
  name               = "albcandidate"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnets
 
  enable_deletion_protection = false
}
 
resource "aws_alb_target_group" "main" {
  name        = "candidatetg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpcid
  target_type = "ip"
 
  health_check {
   healthy_threshold   = "3"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "3"
   path                = "/"
   unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

resource "aws_security_group" "alb" {
  name   = "alb-candidate"
  vpc_id = var.vpcid
 
  ingress {
   protocol         = "tcp"
   from_port        = 80
   to_port          = 5000
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }
 
  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }
}