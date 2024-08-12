variable "kubeconfig" {
  default     = "~/.kube/config"
  description = "path to kubeconfig"
  type        = string
}

variable "domain_root" {
  default     = "local"
  description = "domain root"
  type        = string
}

variable "worker_node_ip" {
  default     = "127.0.0.1"
  description = ""
  type        = string
}