locals {
  xray_service_placement_constraints = module.this.environment == "prod" ? [{
    type       = "memberOf"
    expression = "attribute:spotinst.io/container-instance-lifecycle==od"
  }] : []
}

module "log_group_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.this.context

  label_order = var.log_group_label_order
}

resource "aws_cloudwatch_log_group" "xray" {
  name              = "${module.log_group_label.id}-xray"
  tags              = module.log_group_label.tags
  retention_in_days = var.log_retention_in_days
}

resource "aws_service_discovery_service" "xray" {
  name = "xray"

  dns_config {
    namespace_id = var.service_discovery_dns_namespace_id

    dns_records {
      ttl  = 60
      type = "SRV"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = module.this.tags
}

module "xray_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  container_image              = "public.ecr.aws/xray/aws-xray-daemon:3.3.5"
  container_name               = "xray-daemon"
  container_cpu                = module.this.environment == "prod" ? 100 : 25
  container_memory_reservation = module.this.environment == "prod" ? 100 : 50

  port_mappings = [
    {
      containerPort = 2000
      hostPort      = 0
      protocol      = "udp"
    },
  ]

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.xray.name
      awslogs-region        = var.aws_region
      awslogs-stream-prefix = "ecs"
    }
  }
}

module "ecs_xray_task" {
  source  = "cloudposse/ecs-alb-service-task/aws"
  version = "0.68.0"

  task_policy_arns          = ["arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"]
  network_mode              = var.network_mode
  container_definition_json = "[${module.xray_definition.json_map_encoded}]"
  scheduling_strategy       = "REPLICA"
  service_registries = [{
    registry_arn   = aws_service_discovery_service.xray.arn
    container_name = "xray-daemon"
    container_port = 2000
  }]
  ecs_cluster_arn                    = var.ecs_cluster_arn
  launch_type                        = "EC2"
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  desired_count                      = 1
  vpc_id                             = var.vpc_id
  propagate_tags                     = "SERVICE"
  context                            = module.this.context
  service_placement_constraints      = local.xray_service_placement_constraints
  tags = {
    "spotinst.io/restrict-scale-down" = true
  }
}
