# Cloud SQL

variable "database_instance_name" {
  description = "The name of the instance"
  type        = string
  default     = "airflow-database"
}

variable "database_version" {
  description = "The MySQL, PostgreSQL or SQL Server version to use"
  type        = string
  default     = "POSTGRES_13"
}

variable "db_machine_type" {
  description = "The machine type to use"
  type        = string
  default     = "db-custom-1-4096"
}

variable "db_disk_size_gb" {
  description = "The size of data disk, in GB"
  type        = number
  default     = 15
}

variable "db_disk_type" {
  description = "The type of data disk: PD_SSD or PD_HDD"
  type        = string
  default     = "PD_SSD"
}

variable "db_enable_backup" {
  description = "True if backup configuration is enabled"
  type        = bool
  default     = true
}

variable "db_backup_start_time" {
  description = "HH:MM format time indicating when backup configuration starts"
  type        = string
  default     = "20:00"
}

variable "db_enable_deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the instance"
  type        = bool
  default     = true
}

variable "database_name" {
  description = "The name of the database in the Cloud SQL instance"
  type        = string
  default     = "airflow-db"
}

variable "database_username" {
  description = "The name of the user. Changing this forces a new resource to be created"
  type        = string
  sensitive   = true
}

variable "database_password" {
  description = "The password for the user. Can be updated"
  type        = string
  sensitive   = true
}