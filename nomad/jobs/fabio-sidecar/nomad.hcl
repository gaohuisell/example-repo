# ---------------------------------------------------------------------------------------------------------------------
# NOMAD JOB SPEC
# This is a nomad job written in HCL2.
# ---------------------------------------------------------------------------------------------------------------------
job "fabio-sidecar" {
  region      = var.region
  datacenters = var.datacenters
  type        = "system"

  priority = 100

  group "fabio" {

    network {
      port "http" {
        static = var.fabio_http_port
      }
      port "ui" {
        static = var.fabio_ui_port
      }
      port "grpc" {
        static = var.fabio_grpc_port
      }
    }

    task "fabio" {
      driver = "docker"

      user = "nobody"
      config {
        image        = var.image
        args         = ["-cfg", "/local/fabio.properties"]
        network_mode = "host"
      }

      template {
        data        = file("fabio.properties")
        destination = "local/fabio.properties"
      }

      resources {
        cpu    = var.cpu
        memory = var.memory
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
  default     = "fabiolb/fabio:1.5.15-go1.15.5"
}

variable "cpu" {
  description = "Specifies the CPU required in MHz."
  type        = number
  default     = 100
}

variable "memory" {
  description = "Specifies the memory required in MB."
  type        = number
  default     = 128
}

variable "fabio_http_port" {
  description = "The port for proxy http."
  type        = number
  default     = 9999
}

variable "fabio_ui_port" {
  description = "The port for web ui."
  type        = number
  default     = 9998
}

variable "fabio_grpc_port" {
  description = "The port for protocol grpc."
  type        = number
  default     = 8888
}

variable "domains" {
  type = map(string)
  default = {
    prometheus = "wotv-dev-prometheus.seayoo.com"
    grafana    = "wotv-dev-grafana.seayoo.com"
  }
}

variable "consul_service_discovery_name" {
  type    = string
  default = "elasticsearch"
}

variable "custer_info" {
  type = list(object(
    {
      name = string
      ip   = string
    }
  ))
  default = [
    {
      name = "shanyong-pc"
      ip   = "127.0.0.1"
    },
    {
      name = "shanyong-pc"
      ip   = "127.0.0.1"
    },
    {
      name = "shanyong-pc"
      ip   = "127.0.0.1"
    }
  ]
}