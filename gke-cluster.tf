# Kubernetes
# resource "google_service_account" "default" {
#   account_id   = "terraform-airflow"
#   display_name = "Terraform Airflow"
# }

resource "google_container_cluster" "primary" {
  provider = google-beta
  project  = var.project
  name     = var.cluster_name
  location = var.zone
  network  = var.network
  private_cluster_config {
    master_ipv4_cidr_block  = var.control_plan_ip_range
    enable_private_endpoint = var.private_endpoint
    enable_private_nodes    = var.private_nodes
    master_global_access_config {
      enabled = var.enable_master_global_access_config
    }
  }
  ip_allocation_policy {
  }
  cluster_autoscaling {
    enabled             = false
    autoscaling_profile = var.autoscaling_profile
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "airflow-core" {
  name    = var.core_node_pool_name
  cluster = google_container_cluster.primary.id
  # node_count = 1
  autoscaling {
    min_node_count = var.autoscaling_min_core_node
    max_node_count = var.autoscaling_max_core_node
  }

  node_config {
    machine_type = var.machine_type_core
    disk_type    = var.disk_type_core
    image_type   = var.image_type_core
    labels       = var.core_labels


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
  name     = var.webserver_node_pool_name
  cluster  = google_container_cluster.primary.id
  # node_count = 1
  autoscaling {
    min_node_count = var.autoscaling_min_webserver_node
    max_node_count = var.autoscaling_max_webserver_node
  }

  node_config {
    machine_type = var.machine_type_webserver
    disk_type    = var.disk_type_webserver
    disk_size_gb = var.disk_size_webserver
    image_type   = var.image_type_webserver
    spot         = true
    labels       = var.webserver_labels
    taint = [var.spot_taint]

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
  name     = var.celery_workers_node_pool_name
  cluster  = google_container_cluster.primary.id
  autoscaling {
    min_node_count = var.autoscaling_min_celery_workers_node
    max_node_count = var.autoscaling_max_celery_workers_node
  }

  node_config {
    machine_type = var.machine_type_celery_workers
    disk_type    = var.disk_type_celery_workers
    disk_size_gb = var.disk_size_celery_workers
    image_type   = var.image_type_celery_workers
    spot         = true
    labels       = var.celery_workers_labels
    taint = [var.spot_taint]

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
  name     = var.k8s_workers_node_pool_name
  cluster  = google_container_cluster.primary.id
  autoscaling {
    min_node_count = var.autoscaling_min_k8s_workers_node
    max_node_count = var.autoscaling_max_k8s_workers_node
  }

  node_config {
    machine_type = var.machine_type_k8s_workers
    disk_type    = var.disk_type_k8s_workers
    disk_size_gb = var.disk_size_k8s_workers
    image_type   = var.image_type_k8s_workers
    spot         = true
    labels       = var.k8s_workers_labels
    taint = [var.spot_taint]

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