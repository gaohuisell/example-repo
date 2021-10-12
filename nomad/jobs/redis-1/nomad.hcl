# ---------------------------------------------------------------------------------------------------------------------
# NOMAD JOB SPEC
# This is a nomad job written in HCL2.
# ---------------------------------------------------------------------------------------------------------------------

job "sso-redis" {
  region      = var.region
  datacenters = var.datacenters
#  namespace   = var.namespace
  type        = "service"

#  constraint {
#    attribute = "${node.class}"
#    value     = var.node_class
#  }

  update {
    max_parallel = 1
  }

  group "sso-redis" {

    network {
      port "redis" {
        static = var.redis_port
      }
      port "exporter" {}
    }

    task "redis" {

      meta {
        memory = var.redis_memory
      }

      driver       = "docker"
      kill_timeout = "60s"

      config {
        image        = var.redis_image
        args         = ["/local/redis.conf"]
        network_mode = "host"
      }

      template {
        data        = file("redis.conf")
        destination = "local/redis.conf"
      }

      resources {
        cpu    = var.redis_cpu
        memory = var.redis_memory
      }

      service {
        name         = "sso-redis"
        port         = "redis"
        address_mode = "host"
        check {
          name     = "Redis TCP Check"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      leader = true
    }
    task "redis-prometheus-exporter" {
      driver = "docker"

      config {
        image = var.exporter_image
        args = [
          "-redis-only-metrics",
          "-redis.addr=${NOMAD_ADDR_redis}",
          "-web.listen-address=:${NOMAD_PORT_exporter}",
          "-export-client-list=true"
        ]
      }
      kill_timeout = "15s"
      resources {
        cpu    = var.exporter_cpu
        memory = var.exporter_memory
      }

      service {
        name         = "redis-prometheus-exporter"
        port         = "exporter"
        address_mode = "host"
  
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

variable "namespace" {
  description = "The namespace in which to execute the job."
  type        = string
  default     = "default"
}

variable "redis_cpu" {
  description = "Specifies the CPU required in MHz."
  type        = number
  default     = 100
}

variable "redis_memory" {
  description = "Specifies the memory required in MB."
  type        = number
  default     = 256
}

variable "exporter_cpu" {
  description = "Specifies the CPU required in MHz."
  type        = number
  default     = 100
}

variable "exporter_memory" {
  description = "Specifies the memory required in MB."
  type        = number
  default     = 64
}

variable "node_class" {
  description = "The client node class to run this job on."
  type        = string
  default     = "arm64"
}

variable "redis_port" {
  description = "The static port of Redis"
  type        = number
  default     = 6380
}

variable "redis_image" {
  description = "The image that run a docker instance."
  type        = string
  default     = "redis:5.0.8"
}

variable "exporter_image" {
  description = "The image that run a docker instance."
  type        = string
  default     = "oliver006/redis_exporter:v1.29.0"
}
