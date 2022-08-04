# Google Cloud Platform general config
variable "project" {
  description = "Project ID on Google Cloud Platform"
  type        = string
  default     = "ila-collab"
}

variable "GOOGLE_CREDENTIALS" {
  # default = "/Users/thoai.ho/Downloads/ila-collab-terraform.json"
  description = "service account key file json"
  type        = string
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



