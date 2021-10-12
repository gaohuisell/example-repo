# https://www.hashicorp.com/resources/nomad-dynamic-job-files-and-simplified-deployment-with-hcl2-and-levant-1
# https://learn.hashicorp.com/tutorials/nomad/dry-jobs-levant
job "data-zookeeper" {
  region      = var.region
  datacenters = var.datacenters
  namespace   = var.namespace
  type        = "service"

  constraint {
    attribute = "${node.class}"
    value     = var.node_class
  }

  update {
    max_parallel = 1
  }

  dynamic "group" {
    for_each = var.group_names
    labels   = ["${group.value}"]
    content {

      volume "data-zookeeper" {
        type   = "host"
        source = "data"
      }

      count = 1

      network {
        port "client" {}

        port "peer" {}

        port "election" {}

        port "admin" {}

        port "exporter" {}
      }

      service {
        name         = var.consul_service_name
        tags         = concat([
          group.value,
        ], var.client_service_tags)
        port         = "client"
        meta { ZK_ID = split("-", group.value)[1] }
        address_mode = "host"
      }

      service {
        name         = var.consul_service_name
        tags         = var.peer_service_tags
        port         = "peer"
        meta { ZK_ID = split("-", group.value)[1] }
        address_mode = "host"
      }

      service {
        name         = var.consul_service_name
        tags         = var.election_service_tags
        port         = "election"
        meta { ZK_ID = split("-", group.value)[1] }
        address_mode = "host"
      }

      service {
        name         = var.consul_service_name
        tags         = var.admin_service_tags
        port         = "admin"
        meta { ZK_ID = split("-", group.value)[1] }
        address_mode = "host"
      }

      service {
        name = var.exporter_service_name
        tags = var.exporter_service_tags
        port = "exporter"
        check {
          name     = "Data Zookeeper Prometheus Exporter TCP Check"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      task "zookeeper" {
        driver = "docker"

        kill_signal    = "SIGTERM"
        shutdown_delay = var.shutdown_delay
        kill_timeout   = var.kill_timeout

        volume_mount {
          volume      = "data-zookeeper"
          destination = "/data"
        }

        meta = {
          # ZOO_SERVICE_NAME use in zoo_cfg_dynamic.
          zoo_service_name = "${var.consul_service_name}"
        }

        template {
          destination = "local/zoo.cfg.dynamic"
          data        = var.zoo_cfg_dynamic
          change_mode = "noop"
        }

        template {
          destination = "local/zoo.cfg"
          data        = var.zoo_cfg
        }

        template {
          destination = "local/myid"
          data        = var.zoo_myid
        }

        template {
          destination = "local/entrypoint.sh"
          perms       = "755"
          data        = var.zoo_entrypoint
        }

        config {
          image        = var.image
          network_mode = "host"
          entrypoint   = ["/local/entrypoint.sh"]
          ports        = ["client", "peer", "election", "admin"]
          volumes      = [
            "local/zoo.cfg.dynamic:/conf/zoo.cfg.dynamic",
            "local/zoo.cfg:/conf/zoo.cfg",
            "local/myid:${ZOO_DATA_DIR}/myid",
            "local/entrypoint.sh:/local/entrypoint.sh",

          ]
        }

        env {
          JVMFLAGS     = "-Xms${var.jvm_xms} -Xmx${var.jvm_xmx}"
          ZOO_MY_ID    = "${split("-", group.value)[1]}"
          ZOO_DATA_DIR = "/data/${group.value}"
        }

        resources {
          cpu    = var.cpu
          memory = var.memory
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

# example  ["zookeeper-1" , "zookeeper-2", "zookeeper-3"]
variable "group_names" {
  description = "Group name for dynamic. value is group name, format is zookeeper-1, 1 is zookeeper server id. Value size must be odd number."
  type        = list(string)
}

variable "image" {
  description = "The image that run a docker instance."
  type        = string
  default     = "docker.shiyou.kingsoft.com/mirror/zookeeper:3.7.0"
}

variable "zoo_cfg" {
  description = "Complete configuration file with zoo.cfg, which can be written by Consul template."
  type        = string
}

variable "zoo_cfg_dynamic" {
  description = "Complete configuration file with zoo.cfg.dynamic, which can be written by Consul template."
  type        = string
}

variable "zoo_myid" {
  description = "Complete configuration file with myid, which can be written by Consul template."
  type        = string
}

variable "zoo_entrypoint" {
  description = "Complete configuration file with entrypoint.sh, which can be written by Consul template."
  type        = string
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

variable "cpu" {
  description = "Specifies the CPU required in MHz."
  type        = number
  default     = 300
}

variable "memory" {
  description = "Specifies the memory required in MB."
  type        = number
  default     = 700
}

variable "node_class" {
  description = "The client node class to run this job on."
  type        = string
  default     = "data"
}

variable "shutdown_delay" {
  description = "Specifies the duration to wait when killing a task between removing it from Consul and sending it a shutdown signal. "
  type        = string
  default     = "15s"
}

variable "kill_timeout" {
  description = "Specifies the duration to wait for an application to gracefully quit before force-killing. Nomad first sends a kill_signal."
  type        = string
  default     = "180s"
}

variable "consul_service_name" {
  description = "The zookeeper service name of Consul."
  type        = string
  default     = "data-zookeeper"
}

variable "client_service_tags" {
  type    = list(string)
  default = ["client"]
}

variable "peer_service_tags" {
  type    = list(string)
  default = ["peer"]
}

variable "election_service_tags" {
  type    = list(string)
  default = ["election"]
}

variable "admin_service_tags" {
  type    = list(string)
  default = ["admin"]
}

variable "exporter_service_name" {
  type    = string
  default = "data-zookeeper-exporter"
}

variable "exporter_service_tags" {
  type    = list(string)
  default = ["prometheus-metrics"]
}

variable "jvm_xms" {
  description = "Specifies the initial size of the heap."
  type        = string
  default     = "512m"
}

variable "jvm_xmx" {
  description = "Specifies the maximum size of the heap."
  type        = string
  default     = "512m"
}
