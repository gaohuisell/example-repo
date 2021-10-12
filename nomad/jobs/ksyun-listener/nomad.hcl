job "ksyun-listener" {
  region      = var.region
  datacenters = var.datacenters
  type        = "service"

  constraint {
    attribute = "${node.class}"
    value     = "prometheus"
  }

  group "ksyun-listener" {
    count = 1

    task "ksyun-scan" {
      driver       = "docker"
      kill_timeout = "15s"

      env {
        ACCESS_KEY_ID     = "AKLT1KskkLMVSBCkjKmlhoweXw"
        SECRET_ACCESS_KEY = "OAjL3hapX8evJvJJtaTkjSMQ2qsX2bzFO//Z/4EFLC/FpDyph5Fbmkf6RzZKY1zZmQ=="
        region            = "cn-beijing-6"
        vpc_id            = "8651e407-3b54-44d2-bc4a-a2f76988b266"
      }

      config {
        image = var.image
        args = [
          "python",
          "start.py",
          "kcs",
        ]
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
  default     = "docker.shiyou.kingsoft.com/infra/ksyun-scan:v1"
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
