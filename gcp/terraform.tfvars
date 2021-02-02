project       = "example-project"
region        = "europe-west2"
zone          = "europe-west2-a"
name          = "example"
k8s_namespace = "example"
k8s_sa_name   = "example"
db_username   = "exampleuser"
db_password = "pass4exampleuser"
image = "ubuntu-1804-bionic-v20201014"
k8s_ingress_ip = "0.0.0.0" # placeholder - currently route53 is used for domain name resolution


service_account_iam_roles = [
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter",
  "roles/monitoring.viewer",
]

service_account_custom_iam_roles = []

project_services = [
  "cloudresourcemanager.googleapis.com",
  "servicenetworking.googleapis.com",
  "container.googleapis.com",
  "compute.googleapis.com",
  "iam.googleapis.com",
  "logging.googleapis.com",
  "monitoring.googleapis.com",
  "sqladmin.googleapis.com",
  "securetoken.googleapis.com",
]

svcacc_scopes = [
  "https://www.googleapis.com/auth/compute",
  "https://www.googleapis.com/auth/cloud-platform"
]
