resource "google_redis_instance" "cache" {
  name           = "ha-memory-cache"
  tier           = "BASIC"
  memory_size_gb = 4

  location_id    = "europe-west2-a"

  authorized_network = google_compute_network.network.id

  redis_version     = "REDIS_4_0"
  display_name      = "${var.name} Redis Instance"
  reserved_ip_range = "192.168.0.0/29"
}