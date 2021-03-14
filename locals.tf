locals {
  deployment_volumes = merge(var.empty_dir_volumes, var.secret_volumes, var.config_map_volumes)
  containers = defaults(var.containers, {
    image_tag                       = "latest"
    image_pull_policy               = "IfNotPresent"
    is_init                         = false
    cpu_request                     = "25m"
    memory_request                  = "32Mi"
    cpu_limit                       = "50m"
    memory_limit                    = "64Mi"
    simple_environment_variables    = {}
    secret_environment_variables    = {}
    configmap_environment_variables = {}
    ports                           = []
    http_get_liveness_probe         = []
    http_get_readiness_probe        = []
  })
}