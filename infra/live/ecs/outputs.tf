output "alb_arn" {
  value = module.alb.arn
}
output "ecs_cluster_id" {
  value = module.ecs_cluster.cluster_id
}
output "ecs_cluster_arn" {
  value = module.ecs_cluster.cluster_arn
}
output "target_group_backend_arn" {
  value = module.alb.target_groups["backend_ecs"].id
}
output "target_group_frontend_arn" {
  value = module.alb.target_groups["frontend_ecs"].id
}
output "security_group_ids" {
  value = [module.autoscaling_sg.security_group_id]
}