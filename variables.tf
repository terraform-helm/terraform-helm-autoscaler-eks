variable "images" {
  description = "Map of images"
  type = object({
    main = optional(string)
  })
  default = {
    main = null
  }
}

variable "install_helm" {
  description = "Do you want to install helm chart?"
  type        = bool
  default     = true
}

variable "release_version" {
  description = "version of helm release"
  type        = string
  default     = null
}

variable "service_account_name" {
  description = "Name of the service account to have right to autoscale your cluster"
  type        = string
  default     = "cluster-autoscaler-sa"
}

variable "kubernetes_namespace" {
  description = "Namespace to install autoscaler pod"
  type        = string
  default     = "kube-system"
}

variable "irsa_iam_role_name" {
  type        = string
  description = "IAM role name for IRSA"
  default     = "eks-autoscaler"
}

variable "cluster_id" {
  description = "EKS cluster name"
  type        = string
}

variable "region" {
  description = "Region of you eks cluster"
  type        = string
}
