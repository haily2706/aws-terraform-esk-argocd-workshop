# terraform/variables.tf
# ─────────────────────────────────────────────────────────────────
# Input variables — configure your cluster without changing code.
# ─────────────────────────────────────────────────────────────────

variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"          # ← cheapest region, best spot pool
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "workshop-eks"
}

variable "cluster_version" {
  description = "Kubernetes version (use standard support — NOT extended!)"
  type        = string
  default     = "1.32"               # ← standard support = $0.10/hr
                                     #    extended support = $0.60/hr (6x!)
}