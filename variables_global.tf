# Google Cloud Platform general config
variable "project" {
  description = "Project ID on Google Cloud Platform"
  type        = string
  default     = "uit-cloud-computing"
}

variable "GOOGLE_CREDENTIALS" {
  description = "service account key file json"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Location of project GCP"
  type        = string
  default     = "asia-southeast1"
}

variable "zone" {
  description = "Specified zone in location"
  type        = string
  default     = "asia-southeast1-a"
}
