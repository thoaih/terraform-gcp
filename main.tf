terraform {
  cloud {
    organization = "uit-cloud-computing"

    workspaces {
      name = "terraform-gcp"
    }
  }
}

provider "google" {
  credentials = var.GOOGLE_CREDENTIALS

  project = var.project
  region  = var.region
  zone    = var.zone
}