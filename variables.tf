variable "ecs_cluster_arn" {
  type        = string
  description = "The ECS cluster ARN where this service will be deployed"
}

variable "log_group_label_order" {
  default     = null
  description = "Order of labels to use to generate the log group name"
  type        = list(string)
}

variable "log_retention_in_days" {
  type        = number
  description = "The number of days you want to retain log events in the specified log group"
  default     = 1
}

variable "network_mode" {
  default     = null
  description = "The networking mode used for task, can be null or awsvpc"
  type        = string
}

variable "region" {
  type        = string
  description = "The AWS Region"
  default     = "eu-central-1"
}

variable "service_discovery_dns_namespace_id" {
  type        = string
  description = "The id of the aws_service_discovery_private_dns_namespace resource for xray service registration"
}

variable "vpc_id" {
  default     = ""
  description = "The vpc id used in case the networking mode is set to awsvpc"
  type        = string
}
