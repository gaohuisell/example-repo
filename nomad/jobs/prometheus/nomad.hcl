job "prometheus" {
  region = var.region
  datacenters =var.datacenters
  type        = "service"

  constraint {
    attribute = "${node.class}"
    value     = "prometheus"
  }

  group "prometheus" {
    count = 1

    network {
      port "prometheus" {
        static = 9090
      }
    }

    volume "data" {
      type   = "host"
      source = "prometheus"
    }

    task "prometheus" {
      driver       = "docker"
      kill_timeout = "60s"

      volume_mount {
        volume      = "data"
        destination = "/prometheus"
      }

      config {
        image = var.image
        args = [
          "--storage.tsdb.max-block-duration=5m",
          "--storage.tsdb.min-block-duration=5m",
          "--config.file=/local/prometheus.yml",
          "--storage.tsdb.path=/prometheus",
          "--storage.tsdb.retention.time=14d",
          "--enable-feature=remote-write-receiver",
          "--web.console.libraries=/usr/share/prometheus/console_libraries",
          "--web.console.templates=/usr/share/prometheus/consoles",
          "--web.route-prefix=/",
        ]
        network_mode = "host"
      }

      user = "nobody"

      template {
        data        = file("prometheus.yml")
        destination = "local/prometheus.yml"
      }

      resources {
        cpu    = var.cpu
        memory = var.memory
      }

      service {
        name = var.consul_service_name
        port = "prometheus"
        check {
          name     = "Prometheus HTTP Check"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
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
  default     = "prom/prometheus:v2.31.1"
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
  default     = "prometheus"
}

variable "consul_service_tags" {
  description = "A list of tags to associate with service registered to Consul."
  type        = list(string)
  default     = []
}
