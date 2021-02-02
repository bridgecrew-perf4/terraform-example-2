resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta

  name          = "${var.name}-priv-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.network.self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = google_compute_network.network.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

// Create the Google SA
resource "google_service_account" "db" {
  account_id = "${var.name}-db-sa"
}

// Make an IAM policy that allows the K8S SA to be a workload identity user
data "google_iam_policy" "db" {
  binding {
    role = "roles/iam.workloadIdentityUser"

    members = [
      format("serviceAccount:%s.svc.id.goog[%s/%s]", var.project, var.k8s_namespace, var.k8s_sa_name)
    ]
  }
}

// Bind the workload identity IAM policy to the GSA
resource "google_service_account_iam_policy" "db" {
  service_account_id = google_service_account.db.name
  policy_data        = data.google_iam_policy.db.policy_data
}

// Attach cloudsql access permissions to the Google SA.
resource "google_project_iam_binding" "db" {
  project = var.project
  role    = "roles/cloudsql.client"

  members = [
    format("serviceAccount:%s", google_service_account.db.email)
  ]
}

resource "google_sql_database_instance" "main" {
  project          = var.project
  name             = "${var.name}-db-instance"
  database_version = "MYSQL_5_7"
  region           = var.region

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]

  settings {
    tier              = "db-f1-micro"
    activation_policy = "ALWAYS"
    availability_type = "ZONAL"

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = google_compute_network.network.self_link
    }

    disk_autoresize = false
    disk_size       = "20"
    disk_type       = "PD_SSD"
    pricing_plan    = "PER_USE"

    location_preference {
      zone = var.zone
    }
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}

resource "google_sql_database" "main" {
  name       = "${var.name}-db"
  project    = var.project
  instance   = google_sql_database_instance.main.name
  depends_on = [google_sql_database_instance.main]
}

resource "google_sql_user" "main" {
  name       = var.db_username
  project    = var.project
  instance   = google_sql_database_instance.main.name
  password   = var.db_password
  depends_on = [google_sql_database_instance.main]
}


