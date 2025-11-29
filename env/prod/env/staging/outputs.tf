output "staging_asg_name" {
  value = module.staging.asg_name
}

output "alb_dns_name" {
  value = data.terraform_remote_state.network.outputs.alb_dns_name
}
