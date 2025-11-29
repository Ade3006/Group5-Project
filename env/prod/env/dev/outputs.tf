output "dev_asg_name" {
  value = module.dev.asg_name
}

output "alb_dns_name" {
  value = data.terraform_remote_state.network.outputs.alb_dns_name
}

output "bastion_public_ip" {
  value = data.terraform_remote_state.network.outputs.bastion_public_ip
}
