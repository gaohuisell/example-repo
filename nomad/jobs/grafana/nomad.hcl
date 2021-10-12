job "grafana" {
  region      = var.region
  datacenters = var.datacenters
  type        = "service"

  group "grafana" {

    network {
      port "web" {
        # Default port used by grafana
        static = 3000
      }
    }

    count = 1

    task "grafana" {
      driver = "docker"
      user   = "nobody"

      config {
        image        = var.image
        network_mode = "host"
        # Use systemd-resolved to resolve external domains (download plugins)
        dns_servers = ["127.0.0.53"]
      }

      env {
        # https://grafana.com/docs/grafana/latest/installation/configure-docker/#default-paths
        GF_PATHS_CONFIG       = "/local/grafana.ini"
        GF_PATHS_PROVISIONING = "/local/provisioning"
      }

      template {
        data        = file("grafana.ini")
        destination = "local/grafana.ini"
      }

      template {
        data        = file("config.yml")
        destination = "local/provisioning/datasources/config.yml"
      }

      resources {
        cpu    = var.cpu
        memory = var.memory

      }

      service {
        name         = "grafana"
        port         = "web"
        address_mode = "host"
        check {
          name     = "Grafana HTTP Check"
          type     = "http"
          path     = "/api/health"
          interval = "10s"
          timeout  = "2s"
        }
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
  default     = "grafana/grafana:8.3.0"
}

variable "cpu" {
  description = "Specifies the CPU required in MHz."
  type        = number
  default     = 200
}

variable "memory" {
  description = "Specifies the memory required in MB."
  type        = number
  default     = 256
}

variable "consul_service_name" {
  description = "Name of the service which will be registered to Consul."
  type        = string
  default     = "grafana"
}

variable "consul_service_tags" {
  description = "A list of tags to associate with service registered to Consul."
  type        = list(string)
  default     = ["prometheus-metrics"]
}

variable "env" {
  description = "The name that is a nomad namespace."
  type        = string
  default     = "dev"
}
