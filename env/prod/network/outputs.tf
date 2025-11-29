output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "web_sg_id" {
  value = aws_security_group.web.id
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "tg_dev_arn" {
  value = aws_lb_target_group.tg_dev.arn
}

output "tg_staging_arn" {
  value = aws_lb_target_group.tg_staging.arn
}

output "tg_prod_arn" {
  value = aws_lb_target_group.tg_prod.arn
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}
