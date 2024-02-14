variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_blocks" {
  description = "CIDR blocks for the subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  default     = "10.0.3.0/24"
}

variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {
    Environment = "Production"
    Application = "MyWebApp"
  }
}
