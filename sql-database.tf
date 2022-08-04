# Cloud SQL
# See versions at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version
resource "google_sql_database_instance" "postgres_instance" {
  name             = var.database_instance_name
  region           = var.region
  database_version = var.database_version
  depends_on       = [google_service_networking_connection.private_vpc_connection]
  settings {
    tier      = var.db_machine_type
    disk_size = var.db_disk_size_gb
    disk_type = var.db_disk_type
    backup_configuration {
      enabled    = var.db_enable_backup
      start_time = var.db_backup_start_time
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

  deletion_protection = var.db_enable_deletion_protection
}

resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.postgres_instance.name
}

resource "google_sql_user" "users" {
  name     = var.database_username
  instance = google_sql_database_instance.postgres_instance.name
  password = var.database_password
}