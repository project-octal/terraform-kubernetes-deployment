resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = merge({
      "app.kubernetes.io/name"      = var.name,
      "app.kubernetes.io/component" = var.component,
      "app.kubernetes.io/part-of"   = var.part_of
    }, var.labels)
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        "app.kubernetes.io/name" = var.name
      }
    }
    template {
      metadata {
        labels = merge({
          "app.kubernetes.io/name" = var.name
        }, var.labels)
      }
      spec {
        service_account_name            = var.service_account_name
        automount_service_account_token = var.automount_service_account_token

        dynamic "affinity" {
          for_each = var.preferred_node_selector
          content {
            node_affinity {
              preferred_during_scheduling_ignored_during_execution {
                weight = affinity.value["weight"]
                preference {
                  match_expressions {
                    key      = affinity.value["key"]
                    operator = affinity.value["operator"]
                    values   = affinity.value["values"]
                  }
                }
              }
            }
          }
        }

        ### Container ###
        dynamic "init_container" {
          for_each = {
            for key, value in local.containers :
            key => value
            if value["is_init"] == true
          }
          content {
            name              = init_container.value["name"]
            image             = "${init_container.value["image_repository"]}/${init_container.value["image_name"]}:${init_container.value["image_tag"]}"
            image_pull_policy = init_container.value["image_pull_policy"]
            command           = init_container.value["command"]

            ## Environment Variables ###
            dynamic "env" {
              for_each = init_container.value["environment_variables"] == null ? {} : init_container.value["environment_variables"]
              content {
                name  = env.key
                value = env.value
              }
            }

            ## Secret Environment Variables ###
            dynamic "env" {
              for_each = init_container.value["secret_environment_variables"] == null ? {} : init_container.value["secret_environment_variables"]
              content {
                name = env.key
                value_from {
                  secret_key_ref {
                    name = env.value["name"]
                    key  = env.value["key"]
                  }
                }
              }
            }

            ## Configmap Environment Variables ###
            dynamic "env" {
              for_each = init_container.value["configmap_environment_variables"] == null ? {} : init_container.value["configmap_environment_variables"]
              content {
                name = env.key
                value_from {
                  config_map_key_ref {
                    name = env.value["name"]
                    key  = env.value["key"]
                  }
                }
              }
            }

            ## Container Ports ##
            dynamic "port" {
              for_each = init_container.value["ports"] == null ? [] : init_container.value["ports"]
              content {
                name           = port.value["name"]
                protocol       = port.value["protocol"]
                host_ip        = port.value["host_ip"]
                host_port      = port.value["host_port"]
                container_port = port.value["container_port"]
              }
            }

            ## Resource Requests and Limits ##
            resources {
              requests = {
                cpu    = init_container.value["cpu_request"]
                memory = init_container.value["memory_request"]
              }
              limits = {
                cpu    = init_container.value["cpu_limit"]
                memory = init_container.value["memory_limit"]
              }
            }

            ## Livelness and Rediness Probes ##
            dynamic "liveness_probe" {
              for_each = init_container.value["http_get_liveness_probe"] == null ? [] : init_container.value["http_get_liveness_probe"]
              content {
                http_get {
                  path = liveness_probe.value["path"]
                  port = liveness_probe.value["port"]
                }
                initial_delay_seconds = liveness_probe.value["initial_delay_seconds"]
                period_seconds        = liveness_probe.value["period_seconds"]
              }
            }
            dynamic "readiness_probe" {
              for_each = init_container.value["http_get_readiness_probe"] == null ? [] : init_container.value["http_get_readiness_probe"]
              content {
                http_get {
                  path = readiness_probe.value["path"]
                  port = readiness_probe.value["port"]
                }
                initial_delay_seconds = readiness_probe.value["initial_delay_seconds"]
                period_seconds        = readiness_probe.value["period_seconds"]
              }
            }

            ## Volume Mounts ##
            dynamic "volume_mount" {
              for_each = local.deployment_volumes
              content {
                name       = volume_mount.key
                mount_path = volume_mount.value["mount_path"]
                read_only  = volume_mount.value["read_only"]
              }
            }
          }
        }

        ### Container ###
        dynamic "container" {
          for_each = {
            for key, value in local.containers :
            key => value
            if value["is_init"] == false
          }
          content {
            name              = container.value["name"]
            image             = "${container.value["image_repository"]}/${container.value["image_name"]}:${container.value["image_tag"]}"
            image_pull_policy = container.value["image_pull_policy"]
            command           = container.value["command"]

            ## Simple Environment Variables ###
            dynamic "env" {
              for_each = container.value["simple_environment_variables"] == null ? {} : container.value["simple_environment_variables"]
              content {
                name  = env.key
                value = env.value
              }
            }

            ## Secret Environment Variables ###
            dynamic "env" {
              for_each = container.value["secret_environment_variables"] == null ? {} : container.value["secret_environment_variables"]
              content {
                name = env.key
                value_from {
                  secret_key_ref {
                    name = env.value["name"]
                    key  = env.value["key"]
                  }
                }
              }
            }

            ## Configmap Environment Variables ###
            dynamic "env" {
              for_each = container.value["configmap_environment_variables"] == null ? {} : container.value["configmap_environment_variables"]
              content {
                name = env.key
                value_from {
                  config_map_key_ref {
                    name = env.value["name"]
                    key  = env.value["key"]
                  }
                }
              }
            }

            ## Container Ports ##
            dynamic "port" {
              for_each = container.value["ports"] == null ? [] : container.value["ports"]
              content {
                name           = port.value["name"]
                protocol       = port.value["protocol"]
                host_ip        = port.value["host_ip"]
                host_port      = port.value["host_port"]
                container_port = port.value["container_port"]
              }
            }

            ## Resource Requests and Limits ##
            resources {
              requests = {
                cpu    = container.value["cpu_request"]
                memory = container.value["memory_request"]
              }
              limits = {
                cpu    = container.value["cpu_limit"]
                memory = container.value["memory_limit"]
              }
            }

            ## Livelness and Rediness Probes ##
            dynamic "liveness_probe" {
              for_each = container.value["http_get_liveness_probe"] == null ? [] : container.value["http_get_liveness_probe"]
              content {
                http_get {
                  path = liveness_probe.value["path"]
                  port = liveness_probe.value["port"]
                }
                initial_delay_seconds = liveness_probe.value["initial_delay_seconds"]
                period_seconds        = liveness_probe.value["period_seconds"]
              }
            }
            dynamic "readiness_probe" {
              for_each = container.value["http_get_readiness_probe"] == null ? [] : container.value["http_get_readiness_probe"]
              content {
                http_get {
                  path = readiness_probe.value["path"]
                  port = readiness_probe.value["port"]
                }
                initial_delay_seconds = readiness_probe.value["initial_delay_seconds"]
                period_seconds        = readiness_probe.value["period_seconds"]
              }
            }

            ## Volume Mounts ##
            dynamic "volume_mount" {
              for_each = local.deployment_volumes
              content {
                name       = volume_mount.key
                mount_path = volume_mount.value["mount_path"]
                read_only  = volume_mount.value["read_only"]
              }
            }
          }
        }

        ### Volumes ###
        # Empty Dir
        dynamic "volume" {
          for_each = var.empty_dir_volumes
          content {
            name = volume.key
            empty_dir {}
          }
        }

        # Secrets
        dynamic "volume" {
          for_each = var.secret_volumes
          content {
            name = volume.key
            secret {
              secret_name = volume.value
            }
          }
        }

        # Config Maps
        dynamic "volume" {
          for_each = var.config_map_volumes
          content {
            name = volume.key
            config_map {
              name = volume.key
            }
          }
        }
      }
    }
  }
}