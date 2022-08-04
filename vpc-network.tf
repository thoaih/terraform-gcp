# VPC Network 
resource "google_compute_network" "vpc_network" {
  name = var.network
}

resource "google_compute_global_address" "private_ip_address" {
  # provider = google-beta
  project = var.project

  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = var.address_type
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  # provider = google-beta

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
    ports    = var.prometheus_ports
  }

  source_ranges = [var.internal_ip_range, var.control_plan_ip_range]
}

resource "google_compute_firewall" "allow-airflow" {
  name    = "allow-airflow"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = var.airflow_ports
  }

  source_ranges = [var.internal_ip_range, var.control_plan_ip_range]
}

resource "google_compute_firewall" "airflow-allow-nfs" {
  name    = "airflow-allow-nfs"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = var.nfs_ports
  }

  source_ranges = [var.internal_ip_range, var.control_plan_ip_range]
}