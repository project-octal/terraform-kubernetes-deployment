############################
## Deployment Information ##
############################
variable "namespace" {
  type        = string
  description = ""
}
variable "name" {
  type        = string
  description = ""
}
variable "component" {
  type        = string
  description = ""
}
variable "part_of" {
  type        = string
  description = ""
}
variable "labels" {
  type        = map(string)
  description = ""
}

##################
## Pod Security ##
##################
variable "service_account_name" {
  type        = string
  description = ""
  default     = null
}
variable "automount_service_account_token" {
  type        = bool
  description = ""
  default     = false
}

#####################
## Pod Replication ##
#####################
variable "replicas" {
  type        = number
  description = ""
  default     = 1
}

################################
## Pod Affinity and Placement ##
################################
variable "pod_affinity_topology_key" {
  type        = string
  description = ""
  default     = "failure-domain.beta.kubernetes.io/zone"
}
variable "preferred_node_selector" {
  type = list(object({
    weight   = number,
    key      = string,
    operator = string,
    values   = list(string)
  }))
  description = "A list of objects that define `preferredDuringSchedulingIgnoredDuringExecution` for this deployment"
  default     = []
}

#########################
## Pod Mounted Volumes ##
#########################
variable "empty_dir_volumes" {
  type = map(object({
    mount_path        = string,
    sub_path          = optional(string),
    mount_propagation = optional(string),
    read_only         = optional(bool)
  }))
  description = ""
  default     = {}
}
variable "secret_volumes" {
  type = map(object({
    mount_path        = string,
    sub_path          = optional(string),
    mount_propagation = optional(string),
    read_only         = optional(bool)
  }))
  description = ""
  default     = {}
}
variable "config_map_volumes" {
  type = map(object({
    mount_path        = string,
    sub_path          = optional(string),
    mount_propagation = optional(string),
    read_only         = optional(bool)
  }))
  description = ""
  default     = {}
}

####################
## Pod Containers ##
####################
variable "containers" {
  type = map(object({
    image_repository                = string,
    image_name                      = string,
    image_tag                       = optional(string),
    image_pull_policy               = optional(string),
    is_init                         = optional(bool),
    cpu_request                     = optional(string),
    memory_request                  = optional(string),
    cpu_limit                       = optional(string),
    memory_limit                    = optional(string),
    command                         = optional(string),
    simple_environment_variables    = optional(map(string)),
    secret_environment_variables    = optional(map(object({ name = string, key = string }))),
    configmap_environment_variables = optional(map(object({ name = string, key = string }))),
    # TODO: Add mapped_environment_variables for variable mapping support
    ports = optional(list(object({
      name           = optional(string),
      protocol       = optional(string),
      host_ip        = optional(string),
      host_port      = optional(number),
      container_port = number
    }))),
    http_get_liveness_probe = optional(list(object({
      path                  = string,
      port                  = number,
      initial_delay_seconds = optional(number),
      period_seconds        = optional(number)
    }))),
    http_get_readiness_probe = optional(list(object({
      path                  = string,
      port                  = number,
      initial_delay_seconds = optional(number),
      period_seconds        = optional(number)
    })))
  }))
  description = ""
  default     = {}
}