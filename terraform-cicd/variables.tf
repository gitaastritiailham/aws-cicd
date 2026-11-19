variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "cicd-research"
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
  default     = "public.ecr.aws/nginx/nginx:latest"
}

variable "desired_count" {
  description = "Number of task instances to run"
  type        = number
  default     = 1
}

variable "allowed_cidr" {
  description = "CIDR allowed to access HTTP (80)"
  type        = string
  default     = "10.0.0.0/16"
}