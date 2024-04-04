variable "ecs_cluster_arn" {
  type        = string
  description = "The ECS cluster ARN where this service will be deployed"
}

variable "label_orders" {
  type = object({
    cloudwatch = optional(list(string), ["environment", "stage", "name", "attributes"]),
    ecs        = optional(list(string), ["stage", "name"]),
    iam        = optional(list(string)),
    vpc        = optional(list(string))
  })
  default     = {}
  description = "Overrides the `labels_order` for the different labels to modify ID elements appear in the `id`"
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

variable "service_discovery_dns_namespace_id" {
  type        = string
  description = "The id of the aws_service_discovery_private_dns_namespace resource for xray service registration"
}

variable "vpc_id" {
  default     = ""
  description = "The vpc id used in case the networking mode is set to awsvpc"
  type        = string
}
