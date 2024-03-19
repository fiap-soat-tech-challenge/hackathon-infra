/*==== Global project variables ======*/
variable "environment" {
  type = string
  default = "hackathon"
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "cluster_name" {
  type    = string
  default = "point-management-cluster"
}

variable "app_name" {
  type    = string
  default = "point-management"
}

variable "user_github_actions" {
  type    = string
  default = "github-actions"
}
/*==== End global project variables ======*/


/*==== Variables for VPC ======*/
variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "public_subnets_cidr" {
  type    = list
  default = ["192.168.0.0/20", "192.168.16.0/20"]
}

variable "private_subnets_cidr" {
  type    = list
  default = ["192.168.128.0/20", "192.168.144.0/20"]
}

variable "availability_zones" {
  type    = list
  default = ["us-east-2a", "us-east-2b"]
}
/*==== End variables for VPC ======*/


/*==== Point Management Service variables ======*/
variable "task_point_management_name" {
  type    = string
  default = "point-management-task"
}

variable "container_name_point_management" {
  type    = string
  default = "point-management-service"
}

variable "container_image_point_management" {
  type    = string
  default = "377639963020.dkr.ecr.us-east-2.amazonaws.com/point-management-service:latest"
}

variable "container_port_point_management" {
  type    = number
  default = 3000
}

variable "db_name_point_management" {
  type    = string
  default = "pontos"
}
/*==== End Point Management Service variables ======*/


variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}


/*==== MongoDB variables ======*/
variable "cosmos_mongodb_url" {
  type = string
  sensitive = true
}
/*==== End MongoDB variables ======*/


variable "iam_policy_arn" {
  type = list
  default = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::377639963020:policy/AllowSSMMessagesECSTasks",
    "arn:aws:iam::377639963020:policy/AllowECSExecuteCommand"
  ]
}