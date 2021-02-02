resource "google_container_cluster" "cluster" {
  provider = google-beta

  name     = var.name
  project  = var.project
  location = var.zone

  network    = google_compute_network.network.self_link
  subnetwork = google_compute_subnetwork.sn0.self_link

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  // Decouple the default node pool lifecycle from the cluster object lifecycle
  // by removing the node pool and specifying a dedicated node pool in a
  // separate resource below.
  remove_default_node_pool = "true"
  initial_node_count       = 1

  // Configure various addons
  addons_config {

    network_policy_config {
      disabled = false
    }
  }

  // Enable workload identity
  workload_identity_config {
    identity_namespace = "${var.project}.svc.id.goog"
  }

  // Disable basic authentication and cert-based authentication.
  // Empty fields for username and password are how to "disable" the
  // credentials from being generated.
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = "false"
    }
  }

  network_policy {
    enabled = "true"
  }

  // Allocate IPs in our subnetwork
  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.sn0.secondary_ip_range.0.range_name
    services_secondary_range_name = google_compute_subnetwork.sn0.secondary_ip_range.1.range_name
  }

  // Specify the list of CIDRs which can access the master's API
  master_authorized_networks_config {
    cidr_blocks {
      display_name = "bastion"
      cidr_block   = "${data.google_compute_instance.bastion.network_interface.0.network_ip}/32"
    }
  }

  // Configure the cluster to have private nodes and private control plane access only
  private_cluster_config {
    enable_private_endpoint = "true"
    enable_private_nodes    = "true"
    master_ipv4_cidr_block  = "172.16.0.16/28"
  }

  // Allow plenty of time for each operation to finish (default was 10m)
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  depends_on = [
    google_project_service.service,
    google_project_iam_member.gke_svcacc,
    google_project_iam_member.gke_svcacc_custom,
    google_compute_router_nat.nat,
  ]

}

// A dedicated/separate node pool where workloads will run.  A regional node pool
// will have "node_count" nodes per zone, and will use 3 zones.  This node pool
// will be 3 nodes in size and use a non-default service-account with minimal
// Oauth scope permissions.
resource "google_container_node_pool" "private_npool" {
  provider = google-beta

  name       = "private-npool"
  location   = var.zone
  cluster    = google_container_cluster.cluster.name
  node_count = "4"

  // Repair any issues but don't auto upgrade node versions
  management {
    auto_repair  = "true"
    auto_upgrade = "false"
  }

  node_config {
    machine_type = "e2-standard-4"
    disk_type    = "pd-balanced"
    disk_size_gb = 20
    image_type   = "COS"

    // Use the cluster created service account for this node pool
    service_account = google_service_account.gke_sa.email

    // Use the minimal oauth scopes needed
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]

    labels = {
      cluster = var.name
    }

    // Enable workload identity on this node pool
    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }

    metadata = {
      // Set metadata on the VM to supply more entropy
      google-compute-enable-virtio-rng = "true"
      // Explicitly remove GCE legacy metadata API endpoint
      disable-legacy-endpoints = "true"
    }
  }

  depends_on = [
    google_container_cluster.cluster,
  ]
}

