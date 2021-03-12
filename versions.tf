terraform {
  required_version = ">= 0.14"

  # Optional attributes and the defaults function are
  # both experimental, so we must opt in to the experiment.
  experiments = [module_variable_optional_attrs]

  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    k8s = {
      version = ">= 0.8.0"
      source  = "banzaicloud/k8s"
    }
  }
}