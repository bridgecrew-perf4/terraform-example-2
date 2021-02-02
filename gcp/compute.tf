resource "google_service_account" "vpc_proxy" {
  account_id   = "${var.name}-gke-proxy"
  display_name = "GKE Proxy SA"
}

resource "google_compute_instance" "vpc_proxy" {
  name         = "${var.name}-vpc-proxy"
  machine_type = "f1-micro"
  zone         = "${var.region}-a"
  allow_stopping_for_update = true

  tags = ["dev", "vpc-proxy"]

  boot_disk {
    initialize_params {
      size = "10"
      type = "pd-standard"
      image = var.image
    }
  }

  network_interface {
    network = google_compute_network.network.id
    subnetwork = google_compute_subnetwork.sn0.id
  }

  service_account {
    email = google_service_account.vpc_proxy.email
    scopes = var.svcacc_scopes
  }

  scheduling {
    preemptible = false
    on_host_maintenance = "MIGRATE"
    automatic_restart = true
  }

  metadata = {
  }

  provisioner "remote-exec" {
    script = "./provisioning/proxy.sh" # not tested
  }

}

# Disks for Persistent Volumes

resource "google_compute_disk" "web" {
  name  = "${var.name}-web-pd"
  type  = "pd-balanced"
  zone  = var.zone
  size  = 10
  labels = {
    environment = var.name
  }
  physical_block_size_bytes = 4096
}

resource "google_compute_disk" "api" {
  name  = "${var.name}-api-pd"
  type  = "pd-balanced"
  zone  = var.zone
  size  = 10
  labels = {
    environment = var.name
  }
  physical_block_size_bytes = 4096
}

resource "google_compute_disk" "rep" {
  name  = "${var.name}-rep-pd"
  type  = "pd-balanced"
  zone  = var.zone
  size  = 10
  labels = {
    environment = var.name
  }
  physical_block_size_bytes = 4096
}

resource "google_compute_disk" "cat" {
  name  = "${var.name}-cat-pd"
  type  = "pd-balanced"
  zone  = var.zone
  size  = 20
  labels = {
    environment = var.name
  }
  physical_block_size_bytes = 4096
}
