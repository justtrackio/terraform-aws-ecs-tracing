module "example" {
  source = "../.."

  label_order                        = ["name", "attributes"]
  name                               = "tracing"
  aws_region                         = "eu-central-1"
  stage                              = "stage"
  environment                        = "env"
  ecs_cluster_arn                    = "arn:aws:ecs:eu-central-1:123456789012:cluster/my-cluster"
  service_discovery_dns_namespace_id = "ns-12345678"
}
