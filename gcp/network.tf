
resource "google_service_account" "gke_sa" {
  account_id   = "${var.name}-gke-sa"
  display_name = "GKE Service Account" 
  project = var.project
}

resource "google_project_iam_member" "gke_svcacc" {
  count   = length(var.service_account_iam_roles)
  project = var.project
  role    = element(var.service_account_iam_roles, count.index)
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "gke_svcacc_custom" {
  count   = length(var.service_account_custom_iam_roles)
  project = var.project
  role    = element(var.service_account_custom_iam_roles, count.index)
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}


resource "google_project_service" "service" {
  count   = length(var.project_services)
  project = var.project
  service = element(var.project_services, count.index)

  disable_on_destroy = false
}

resource "google_compute_network" "network" {
  name                    = "${var.name}-network"
  project                 = var.project
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.service,
  ]
}

resource "google_compute_subnetwork" "sn0" {
  name          = "${var.name}-sn0"
  project       = var.project
  network       = google_compute_network.network.self_link
  region        = var.region
  ip_cidr_range = "10.30.0.0/17"

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "${var.name}-pod-range"
    ip_cidr_range = "10.30.128.0/18"
  }

  secondary_ip_range {
    range_name    = "${var.name}-svc-range"
    ip_cidr_range = "10.30.192.0/18"
  }
}

resource "google_compute_address" "nat" {
  name    = "${var.name}-nat-ip"
  project = var.project
  region  = var.region

  depends_on = [
    google_project_service.service,
  ]
}

resource "google_compute_router" "router" {
  name    = "${var.name}-cloud-router"
  project = var.project
  region  = var.region
  network = google_compute_network.network.self_link

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name    = "${var.name}-cloud-nat"
  project = var.project
  router  = google_compute_router.router.name
  region  = var.region

  nat_ip_allocate_option = "MANUAL_ONLY"

  nat_ips = [google_compute_address.nat.self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.sn0.self_link
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]

    secondary_ip_range_names = [
      google_compute_subnetwork.sn0.secondary_ip_range.0.range_name,
      google_compute_subnetwork.sn0.secondary_ip_range.1.range_name,
    ]
  }
}

resource "google_compute_firewall" "network_all" {
  name    = "dev-all"
  network = google_compute_network.network.name
 
  allow {
    protocol = "tcp"
    ports = ["1-65535"]
  }
  allow {
    protocol = "udp"
    ports = ["1-65535"]
  }
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "esp"
  }
  allow {
    protocol = "ah"
  }
  allow {
    protocol = "sctp"
  }

  source_ranges = [
    google_compute_subnetwork.sn0.ip_cidr_range,
    google_compute_subnetwork.sn0.secondary_ip_range.0.range_name,
    google_compute_subnetwork.sn0.secondary_ip_range.1.range_name
  ]

  source_tags = ["example"]
  target_tags = ["example"]

}

