# Cluster
variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
  default     = "airflow-cluster"
}

variable "private_endpoint" {
  description = "If false, allow access through the public endpoint"
  type        = bool
  default     = false
}

variable "private_nodes" {
  description = "Enables the private cluster feature"
  type        = bool
  default     = true
}

variable "enable_master_global_access_config" {
  description = "Whether the cluster master is accessible globally or not"
  type        = bool
  default     = true
}

variable "autoscaling_profile" {
  description = "Choose whether the cluster autoscaler should optimize for resource utilization or resource availability when deciding to remove nodes from a cluster"
  type        = string
  default     = "OPTIMIZE_UTILIZATION"
}


# Core node
variable "core_node_pool_name" {
  description = "The name of the node pool"
  type        = string
  default     = "airflow-core"
}

variable "machine_type_core" {
  description = "The name of a Google Compute Engine machine type"
  type        = string
  default     = "t2d-standard-8"
}

variable "image_type_core" {
  description = "The image type to use for this node. Note that changing the image type will delete and recreate all nodes in the node pool."
  type        = string
  default     = "ubuntu_containerd"
}

variable "disk_type_core" {
  description = "Type of the disk attached to each node (e.g. 'pd-standard', 'pd-balanced' or 'pd-ssd')"
  type        = string
  default     = "pd-ssd"
}

variable "core_labels" {
  description = "he Kubernetes labels (key/value pairs) to be applied to each node"
  type        = map(any)
  default     = { "instance_type" = "core" }
}

variable "autoscaling_min_core_node" {
  description = "Minimum number of nodes in the NodePool"
  type        = number
  default     = 1
}

variable "autoscaling_max_core_node" {
  description = "Maximum number of nodes in the NodePool"
  type        = number
  default     = 2
}


# Webserver node
variable "webserver_node_pool_name" {
  description = "The name of the node pool"
  type        = string
  default     = "airflow-webserver"
}

variable "machine_type_webserver" {
  description = "The name of a Google Compute Engine machine type"
  type        = string
  default     = "t2d-standard-2"
}

variable "image_type_webserver" {
  description = "The image type to use for this node. Note that changing the image type will delete and recreate all nodes in the node pool."
  type        = string
  default     = "ubuntu_containerd"
}

variable "disk_type_webserver" {
  description = "Type of the disk attached to each node (e.g. 'pd-standard', 'pd-balanced' or 'pd-ssd')"
  type        = string
  default     = "pd-standard"
}

variable "disk_size_webserver" {
  description = "Size of the disk attached to each node, specified in GB. The smallest allowed disk size is 10GB"
  type        = number
  default     = 30
}

variable "autoscaling_min_webserver_node" {
  description = "Minimum number of nodes in the NodePool"
  type        = number
  default     = 1
}

variable "autoscaling_max_webserver_node" {
  description = "Maximum number of nodes in the NodePool"
  type        = number
  default     = 2
}

variable "webserver_labels" {
  description = "The Kubernetes labels (key/value pairs) to be applied to each node"
  type        = map(any)
  default     = { "purpose" = "webserver" }
}

variable "spot_taint" {
  description = "A list of Kubernetes taints to apply to nodes"
  type        = map(any)
  default = {
    effect = "NO_SCHEDULE"
    key    = "cloud.google.com/gke-spot"
    value  = "true"
  }
}


# Celery worker nodes
variable "celery_workers_node_pool_name" {
  description = "The name of the node pool"
  type        = string
  default     = "airflow-celery-workers"
}

variable "machine_type_celery_workers" {
  description = "The name of a Google Compute Engine machine type"
  type        = string
  default     = "n2-custom-4-16384"
}

variable "image_type_celery_workers" {
  description = "The image type to use for this node. Note that changing the image type will delete and recreate all nodes in the node pool."
  type        = string
  default     = "ubuntu_containerd"
}

variable "disk_type_celery_workers" {
  description = "Type of the disk attached to each node (e.g. 'pd-standard', 'pd-balanced' or 'pd-ssd')"
  type        = string
  default     = "pd-ssd"
}

variable "disk_size_celery_workers" {
  description = "Size of the disk attached to each node, specified in GB. The smallest allowed disk size is 10GB"
  type        = number
  default     = 30
}

variable "autoscaling_min_celery_workers_node" {
  description = "Minimum number of nodes in the NodePool"
  type        = number
  default     = 0
}

variable "autoscaling_max_celery_workers_node" {
  description = "Maximum number of nodes in the NodePool"
  type        = number
  default     = 4
}

variable "celery_workers_labels" {
  description = "The Kubernetes labels (key/value pairs) to be applied to each node"
  type        = map(any)
  default     = { "purpose" = "celery_worker" }
}


# Kubernetes worker nodes
variable "k8s_workers_node_pool_name" {
  description = "The name of the node pool"
  type        = string
  default     = "airflow-k8s-workers"
}

variable "machine_type_k8s_workers" {
  description = "The name of a Google Compute Engine machine type"
  type        = string
  default     = "c2-standard-8"
}

variable "image_type_k8s_workers" {
  description = "The image type to use for this node. Note that changing the image type will delete and recreate all nodes in the node pool."
  type        = string
  default     = "ubuntu_containerd"
}

variable "disk_type_k8s_workers" {
  description = "Type of the disk attached to each node (e.g. 'pd-standard', 'pd-balanced' or 'pd-ssd')"
  type        = string
  default     = "pd-ssd"
}

variable "disk_size_k8s_workers" {
  description = "Size of the disk attached to each node, specified in GB. The smallest allowed disk size is 10GB"
  type        = number
  default     = 30
}

variable "autoscaling_min_k8s_workers_node" {
  description = "Minimum number of nodes in the NodePool"
  type        = number
  default     = 0
}

variable "autoscaling_max_k8s_workers_node" {
  description = "Maximum number of nodes in the NodePool"
  type        = number
  default     = 2
}

variable "k8s_workers_labels" {
  description = "The Kubernetes labels (key/value pairs) to be applied to each node"
  type        = map(any)
  default     = { "purpose" = "k8s_worker" }
}