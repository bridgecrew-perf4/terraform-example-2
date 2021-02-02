output "cluster_name" {
  value       = google_container_cluster.cluster.name
}

output "gcp_serviceaccount" {
  value       = google_service_account.db.email
}

output "db_instance" {
  value       = google_sql_database_instance.main.name
}

output "cluster_endpoint" {
  value       = google_container_cluster.cluster.endpoint
}

output "db_connection_string" {
  value       = format("%s:%s:%s", data.google_client_config.current.project, var.region, google_sql_database_instance.main.name)
}

output "db_private_ip" {
  value = google_sql_database_instance.main.private_ip_address
}

output "db_user" {
  value       = google_sql_user.main.name
}

output "db_password" {
  value       = google_sql_user.main.password
}

output "redis_connection" {
  value = google_redis_instance.cache.connection
}