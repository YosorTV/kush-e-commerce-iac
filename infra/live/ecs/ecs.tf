module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name                          = local.name
  default_capacity_provider_use_fargate = false
  autoscaling_capacity_providers = {
    autoscaling_capacity_prod = {
      auto_scaling_group_arn         = module.autoscaling.autoscaling_group_arn
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 1
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 60
      }

      default_capacity_provider_strategy = {
        weight = 60
        base   = 20
      }
    }
  }

  tags = local.tags
}

