# terraform {
#   required_providers {
#     google = {
#       source  = "hashicorp/google"
#       version = "4.24.0"
#     }
#   }
# }

provider "google" {
  # credentials = file(var.credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}


# VPC Network 
resource "google_compute_network" "vpc_network" {
  name = var.network
}

resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta
  project  = var.project

  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}


# Firewall rule
resource "google_compute_firewall" "airflow-allow-ssh" {
  name    = "airflow-allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "airflow-allow-http" {
  name    = "airflow-allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "airflow-allow-https" {
  name    = "airflow-allow-https"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# resource "google_compute_firewall" "allow-voip" {
#   name    = "allow-voip"
#   network = google_compute_network.vpc_network.name

#   allow {
#     protocol = "tcp"
#     ports    = ["1112"]
#   }

#   source_ranges = ["10.148.0.0/20"]
# }

resource "google_compute_firewall" "airflow-allow-icmp" {
  name    = "airflow-allow-icmp"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "airflow-allow-prometheus" {
  name    = "airflow-allow-prometheus"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["9090", "9093", "9100"]
  }

  source_ranges = ["10.148.0.0/20", "172.16.0.32/28"]
}

resource "google_compute_firewall" "allow-airflow" {
  name    = "allow-airflow"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["8080", "5555", "6379", "5432", "6543", "9127"]
  }

  source_ranges = ["10.148.0.0/20", "172.16.0.32/28"]
}

resource "google_compute_firewall" "airflow-allow-nfs" {
  name    = "airflow-allow-nfs"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["2049"]
  }

  source_ranges = ["10.148.0.0/20", "172.16.0.32/28", "10.59.248.146"]
}

# Cloud NAT
resource "google_compute_router" "router" {
  project = var.project
  name    = "airflow-nat-router"
  network = var.network
  region  = var.region
}

module "cloud-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 2.0.0"
  project_id                         = var.project
  region                             = var.region
  router                             = google_compute_router.router.name
  name                               = "airflow-nat-config"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}


# Kubernetes
# resource "google_service_account" "default" {
#   account_id   = "terraform-airflow"
#   display_name = "Terraform Airflow"
# }

resource "google_container_cluster" "primary" {
  provider = google-beta
  project  = var.project
  name     = "ila-airflow-cluster"
  location = var.zone
  network  = var.network
  private_cluster_config {
    master_ipv4_cidr_block  = "172.16.0.32/28"
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_global_access_config {
      enabled = true
    }
  }
  ip_allocation_policy {
  }
  cluster_autoscaling {
    enabled             = false
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
  }

  addons_config {
    gcp_filestore_csi_driver_config {
      enabled = true
    }
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "airflow-core" {
  name    = "airflow-core"
  cluster = google_container_cluster.primary.id
  # node_count = 1
  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  node_config {
    machine_type = "n2-custom-8-16384"
    disk_type    = "pd-balanced"
    image_type   = "ubuntu_containerd"
    labels       = { "instance_type" = "core" }


    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    # service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }
  initial_node_count = 1
}

resource "google_container_node_pool" "airflow-webserver" {
  provider = google-beta
  name     = "airflow-webserver"
  cluster  = google_container_cluster.primary.id
  # node_count = 1
  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  node_config {
    machine_type = "e2-standard-2"
    disk_type    = "pd-standard"
    disk_size_gb = 30
    image_type   = "ubuntu_containerd"
    spot         = true
    labels       = { "purpose" = "webserver" }
    taint = [{
      effect = "NO_SCHEDULE"
      key    = "cloud.google.com/gke-spot"
      value  = "true"
    }]

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    # service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }
  initial_node_count = 1
}

resource "google_container_node_pool" "airflow-celery-workers" {
  provider = google-beta
  name     = "airflow-celery-workers"
  cluster  = google_container_cluster.primary.id
  autoscaling {
    min_node_count = 0
    max_node_count = 2
  }

  node_config {
    machine_type = "n2-custom-8-16384"
    disk_type    = "pd-ssd"
    disk_size_gb = 30
    image_type   = "ubuntu_containerd"
    spot         = true
    labels       = { "purpose" = "celery_worker" }
    taint = [{
      effect = "NO_SCHEDULE"
      key    = "cloud.google.com/gke-spot"
      value  = "true"
    }]

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    # service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }
  initial_node_count = 1
}

resource "google_container_node_pool" "airflow-k8s-workers" {
  provider = google-beta
  name     = "airflow-k8s-workers"
  cluster  = google_container_cluster.primary.id
  autoscaling {
    min_node_count = 0
    max_node_count = 2
  }

  node_config {
    machine_type = "c2-standard-8"
    disk_type    = "pd-ssd"
    disk_size_gb = 30
    image_type   = "ubuntu_containerd"
    spot         = true
    labels       = { "purpose" = "k8s_worker" }
    taint = [{
      effect = "NO_SCHEDULE"
      key    = "cloud.google.com/gke-spot"
      value  = "true"
    }]

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    # service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }
  initial_node_count = 1
}

# Cloud SQL

resource "google_sql_database" "database" {
  name     = "airflow-db"
  instance = google_sql_database_instance.postgres_instance.name
}

# See versions at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version
resource "google_sql_database_instance" "postgres_instance" {
  name             = "airflow-database"
  region           = var.region
  database_version = "POSTGRES_13"
  depends_on       = [google_service_networking_connection.private_vpc_connection]
  settings {
    tier      = "db-custom-1-4096"
    disk_size = 10
    disk_type = "PD_SSD"
    backup_configuration {
      enabled    = true
      start_time = "20:00"
      location   = var.region
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc_network.id
    }
    location_preference {
      zone = var.zone
    }
  }

  deletion_protection = "true"
}

resource "google_sql_user" "users" {
  name     = "bi"
  instance = google_sql_database_instance.postgres_instance.name
  password = "biteam@1234"
}
