job "webapp" {
  region      = var.region
  datacenters = var.datacenters
  namespace   = var.namespace
  type        = "service"

  group "webapp" {
    count = 1

    network {
      port "http" {
        to = -1
      }
    }

    service {
      name = local.consul_service_name
      tags = concat([
        "traefik.enable=true",
        "traefik.http.routers.http.rule=Path(`/myapp`)",
        "traefik.http.routers.webapp.rule=Host(`example.com`)",
        "urlprefix-/webapp/myapp strip=/webapp",
      ], var.consul_service_tags)
      port = "http"
      check {
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }
    }

    task "webapp" {
      env {
        PORT    = "${NOMAD_PORT_http}"
        NODE_IP = "${NOMAD_IP_http}"
      }

      driver = "docker"

      config {
        image = var.image
        ports = ["http"]
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
  description = "The image that run a docker instance."
  type        = string
  default     = "hashicorp/demo-webapp-lb-guide"
}

variable "consul_service_name" {
  description = "Name of the service which will be registered to Consul."
  type        = string
  default     = "webapp"
}

variable "consul_service_tags" {
  description = "A list of tags to associate with service registered to Consul."
  type        = list(string)
  default     = []
}
