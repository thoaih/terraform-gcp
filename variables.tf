variable "project" {
  default = "ila-collab"
}

variable "credentials_file" {
  default = "/var/nfs/airflow/connections/ila-collab-terraform.json"
}

variable "region" {
  default = "asia-southeast1"
}

variable "zone" {
  default = "asia-southeast1-a"
}

variable "network" {
  default = "airflow-network"
}
