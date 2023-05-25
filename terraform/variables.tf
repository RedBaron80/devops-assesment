variable vpcid {
  type        = string
  default     = "vpc-0c8f4678352761944"
  description = "vpc id"
}

variable subnets {
  type        = list(string)
  default     = ["subnet-08a144e77a69a06c8","subnet-018a7369f0d0d009c"]
  description = "subnets of main vpc"
}

variable rolearn {
  type        = string
  default     = "arn:aws:iam::123667557107:role/tp"
  description = "description"
}

variable container_port {
  type        = string
  default     = "5000"
  description = "container port"
}
