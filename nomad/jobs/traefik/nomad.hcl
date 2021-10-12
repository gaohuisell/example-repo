job "traefik" {
  region      = var.region
  datacenters = var.datacenters
  type        = "service"

  group "traefik" {
    count = 1

    network {
      port "http" {
        static = 8080
      }

      port "api" {
        static = 8081
      }
    }

    service {
      name = local.server_name
      tags = var.consul_service_tags
      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:v2.2"
        network_mode = "host"

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
      }

      template {
        data        = file(traefik.toml)
        destination = "local/traefik.toml"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# LOCAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
locals {
  service_name = "${var.consul_service_name}-${var.env}"
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

variable "image" {
  description = "The image that run a docker instance."
  type        = string
  default     = "traefik:v2.2"
}

variable "cpu" {
  description = "Specifies the CPU required in MHz."
  type        = number
  default     = 100
}

variable "memory" {
  description = "Specifies the memory required in MB."
  type        = number
  default     = 64
}

variable "consul_service_name" {
  description = "Name of the service which will be registered to Consul."
  type        = string
  default     = "traefik"
}

variable "consul_service_tags" {
  description = "A list of tags to associate with service registered to Consul."
  type        = list(string)
  default     = []
}
