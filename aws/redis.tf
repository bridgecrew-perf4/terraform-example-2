resource "aws_elasticache_replication_group" "redis" {
  at_rest_encryption_enabled    = "true"
  auto_minor_version_upgrade    = "true"
  automatic_failover_enabled    = "false"
  engine                        = "redis"
  engine_version                = "5.0.6"
  maintenance_window            = "fri:04:00-fri:05:00"
  node_type                     = "cache.t3.small"
  number_cache_clusters         = "1"
  parameter_group_name          = "default.redis5.0"
  port                          = "6379"
  replication_group_description = "${var.name}-redis"
  replication_group_id          = "${var.name}-redis"
  security_group_ids            = [aws_security_group.redis.id]
  snapshot_retention_limit      = "1"
  snapshot_window               = "02:30-03:30"
  subnet_group_name             = aws_elasticache_subnet_group.sn_group.name
  transit_encryption_enabled    = "false"
}

resource "aws_elasticache_subnet_group" "sn_group" {
  name       = "${var.name}-redis-sngroup"
  subnet_ids = [aws_subnet.sn1a.id,aws_subnet.sn1b.id]
}