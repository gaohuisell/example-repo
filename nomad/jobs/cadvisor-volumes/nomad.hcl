job "cadvisor2" {
  region      = var.region
  datacenters = var.datacenters
  type        = "system"

  priority = 100

  group "cadvisor" {

    network {
      port "http" {}
    }

    task "cadvisor" {
      driver = "docker"

      user = "root"

      kill_signal  = "SIGTERM"
      kill_timeout = "30s"

      config {
        image        = var.image
        network_mode = "host"
        args         = ["-port", "${NOMAD_PORT_http}"]

        devices = [
          {
            host_path      = "/dev/kmsg"
            container_path = "/dev/kmsg"
          }
        ]

        volumes = [
          "/:/rootfs",
          "/var/run:/var/run",
          "/sys:/sys",
          "/var/lib/docker:/var/lib/docker",
        ]
      }

      resources {
        cpu    = cpu
        memory = var.memory
      }

      service {
        name = "cadvisor"
        port = "http"
        tags = ["prometheus-metrics"]
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
  default     = "docker.shiyou.kingsoft.com/mirror/gcr.io/cadvisor/cadvisor:v0.37.5"
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
