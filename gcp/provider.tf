provider "google" {
  credentials = file("./account.json")
  project = var.project
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  credentials = file("./account.json")
  project = var.project
  region  = var.region
  zone    = var.zone
}

data "google_client_config" "current" {}

terraform {
  required_providers {
    google = {
      version = ">= 1.19.0"
      source = "hashicorp/google"
    }
  }

  required_version = ">=0.13.2"

  backend "gcs" {
    credentials = "./account.json"
    bucket      = "example-tf"
    prefix      = "terraform/gke"

  }
}