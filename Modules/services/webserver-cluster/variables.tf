variable "server_port" {
    description = "The port the server will use for HTTP requests"
    type        = number
}

variable "alb_name" {
    description = "App load balancer name"
    type = string
}

variable "instance_security_group_name" {
    description = "The name of the SG for the EC2 instances"
    type = string
}

variable "alb_security_group_name" {
    description = "The name of the SG for the ALB"
    type = string
}

variable "env" {
    description = "Environment name prefix"
    type = string
}

variable "db_remote_state_bucket" {
    description = "The name of the S3 bucket for the database's remote state"
    type = string
}

variable "db_remote_state_key" {
    description = "The path for the database's remote state in S3"
    type = string
}

variable "instance_type" {
    description = "The type of EC2 Instances to run (e.g. t2.micro)"
    type = string
}

variable "min_size" {
    description = "The minimum number of EC2 Instances in the ASG"
    type = number
}

variable "max_size" {
    description = "The maximum number of EC2 Instances in the ASG"
    type = number
}

variable "desired_capacity" {
    description = "The desired number of EC2 Instances in the ASG"
    type = number
}

variable "custom_tags" {
    description = "Custom tags to set on the Instances in the ASG"
    type        = map(string)
    default     = {}
}