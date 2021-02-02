// Required values to be set in terraform.tfvars
variable "project" {}
variable "region" {}
variable "zone" {}
variable "name" {}
variable "k8s_namespace" {}
variable "k8s_sa_name" {}
variable "db_username" {}
variable "db_password" {}
variable "service_account_iam_roles" {}
variable "service_account_custom_iam_roles" {}
variable "project_services" {}
variable "svcacc_scopes" {}
variable "image" {}
variable "k8s_ingress_ip" {}