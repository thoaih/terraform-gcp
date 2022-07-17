variable "project" {
  default = "ila-collab"
}

variable "GOOGLE_CREDENTIALS" {
  # default = "/Users/thoai.ho/Downloads/ila-collab-terraform.json"
  description = "service account key file json"
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