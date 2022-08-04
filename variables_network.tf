# VPC network
variable "network" {
  description = "Network name on GCP"
  type        = string
  default     = "airflow-network"
}

variable "address_type" {
  description = "Address type for network"
  type        = string
  default     = "INTERNAL"
}

variable "internal_ip_range" {
  description = "Source range of Singapore"
  type        = string
  default     = "10.148.0.0/20"
}

variable "control_plan_ip_range" {
  description = "Control plane address range of Kubernetes Cluster"
  type        = string
  default     = "172.16.0.32/28"
}

variable "prometheus_ports" {
  description = "Ports of Prometheus services"
  type        = list(any)
  default     = ["9090", "9093", "9100"]
}

variable "airflow_ports" {
  description = "Ports of Airflow services"
  type        = list(any)
  default     = ["8080", "5555", "6379", "5432", "6543", "9127"]
}

variable "nfs_ports" {
  description = "Ports of NFS services"
  default     = ["2049"]
}