# ---------------------------------------------------------------------------------------------------------------------
# NOMAD JOB SPEC
# This is a nomad job written in HCL2.
# ---------------------------------------------------------------------------------------------------------------------
job "ksyun-bws" {
  region      = var.region
  datacenters = var.datacenters
  namespace   = var.namespace
  type        = "service"

  constraint {
    attribute = "${node.class}"
    value     = "backend"
  }

  group "ksyun-bws" {
    count = 1
    network {
      port http {}
    }

    task "ksyun-bws" {
      driver = "docker"
      config {
        image = var.image
        args = [
          "-addr",
          ":${NOMAD_PORT_http}",
          "-config",
          "/local/config.yml"
        ]

        network_mode = "host"
      }

      kill_timeout = "15s"

      template {
        data        = file("config.yml")
        destination = "local/config.yml"
        change_mode = "noop"
      }

      resources {
        cpu    = var.cpu
        memory = var.memory
      }

      service {
        name = local.consul_service_name
        port = "http"
        tags = var.consul_service_tags
        meta {
          instance_name = "ksyun-bws"
        }
      }
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# LOCAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
locals {
  consul_service_name = "${var.namespace}-${var.consul_service_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "region" {
  type = string
}

variable "datacenters" {
  type = list(string)
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "namespace" {
  description = "The namespace in which to execute the job."
  type        = string
  default     = "dev"
}

variable "image" {
  description = "The image can run instance."
  type        = string
  default     = "docker.shiyou.kingsoft.com/infra/kscmonitor-exporter:master-b2-20210621"
}

variable "cpu" {
  type    = number
  default = 100
}

variable "memory" {
  type    = number
  default = 64
}

variable "consul_service_name" {
  description = "Name of the service which will be registered to Consul."
  type        = string
  default     = "bws"
}

variable "consul_service_tags" {
  description = "A list of tags to associate with service registered to Consul."
  type        = list(string)
  default     = ["prometheus-metrics"]
}
