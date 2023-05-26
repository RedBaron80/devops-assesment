variable vpcid {
  type        = string
  default     = "vpc-c1fa01ab"
  description = "vpc id"
}

variable subnets {
  type        = list(string)
  default     = ["subnet-ddb3ada0","subnet-577f921b","subnet-8d9d3ee7"]
  description = "subnets of main vpc"
}

variable rolearn {
  type        = string
  default     = "arn:aws:iam::303981612052:role/ecsTaskExecutionRole"
  description = "description"
}

variable container_port {
  type        = string
  default     = "5000"
  description = "container port"
}
