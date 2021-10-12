job "zt-api-bp" {
  region      = var.region
  datacenters = var.datacenters
  type        = "service"

  constraint {
    attribute = "${node.class}"
    value     = "backend"
  }

  update {
    max_parallel = 1
  }

  group "api-bp" {

    scaling {
      min = 1
      max = 4
    }

    network {
      port "http" {}
    }

    task "api-bp" {
      driver         = "docker"
      user           = "node"
      shutdown_delay = "15s"
      kill_timeout   = "30s"

      env {
        name = local.projects["bp"].name
        temp = format("%v", local.projects)
        // tmp2 = local.selected_project
        // APP_PORT = "${NOMAD_PORT_http}"
        // APP_ENV = var.app_env
        // // COOKIE_SALT = var.app_env
        // MYSQL_USERNAME = var.mysql_username
        // // MYSQL_PASSWORD = var.mysql_password
        // MYSQL_DATABASE = var.mysql_database
        // MYSQL_WRITER_PORT = var.mysql_writer_port
        // MYSQL_WRITER_HOST = var.mysql_writer_host
        // MYSQL_READER_PORT = var.mysql_reader_port
        // MYSQL_READER_HOST = var.mysql_reader_host
        // REDIS_HOST = var.redis_host
        // REDIS_PORT = var.redis_port
        // PROJECT_NAME = var.project_name
        // SMS_APP_NAME = var.sms_app_name
        // // SMS_ACCESS_KEY = var.sms_access_key
        // // SMS_SECRET_KEY = var.sms_secret_key
      }

      config {
        image        = "zt-api:v1"
        args         = ["npm", "run", "start"]
        network_mode = "host"
      }

      resources {
        cpu    = var.cpu
        memory = var.memory
      }

      service {
        name = "zt-api-bp"
        port = "http"
        check {
          name     = "zt-api-bp HTTP Check"
          type     = "http"
          path     = "/health"
          interval = "15s"
          timeout  = "3s"
        }
      }
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# LOCAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
locals {
  projects = { for project in var.projects : project["name"] => project }
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
variable "cpu" {
  description = "Specifies the CPU required in MHz."
  type        = number
  default     = 500
}

variable "memory" {
  description = "Specifies the memory required in MB."
  type        = number
  default     = 512
}

variable "node_class" {
  description = "The client node class to run this job on."
  type        = string
  default     = "zt-backend"
}

variable "projects" {
  type = list(object({
    name                = string
    env                 = map(string)
    consul_service_tags = list(string)
  }))
}
