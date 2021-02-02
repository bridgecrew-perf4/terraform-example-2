output "vpc" {
  value = aws_vpc.vpc.id
}

output "web_id" {
  value = module.web.id
}

output "api_id" {
  value = module.api.id
}

output "db" {
  value = aws_db_instance.db.endpoint
}

output "web_ip" {
  value = module.web.private_ip
}

output "api_ip" {
  value = module.api.private_ip
}