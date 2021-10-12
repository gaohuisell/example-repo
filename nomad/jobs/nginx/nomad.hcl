job "nginx" {
  region = var.region
  datacenters = var.datacenters
  type = "system"

  group "nginx" {

    network {
      port "http" {
        static = 8080
      }
    }

    task "nginx" {

      meta {
        abc = join("-",[for k in var.custer_info:format("abc.%s-%s",k["name"],k["ip"])])
      }

      driver = "docker"

      config {
        image = var.image
        network_mode = "host"
        args = [
          "nginx",
          "-c",
          "/local/nginx.conf",
          "-g",
          "daemon off;"
        ]
      }

      template {
        data = file("nginx.conf")
        destination = "local/nginx.conf"
        change_mode = "signal"
        change_signal = "SIGHUP"
      }

      template {
        data = <<EOF
%{ if true ~} hello %{~ endif }
hello ${true}
%{ for k,v in var.domains }${v}
%{ endfor }
}

%{ for k,v in var.domains }
  upstream ${k} {  {{ range service "${k}" }}
    server {{ .Address }}:{{ .Port }};  {{ end }}
  }
  server {
    listen        {{ env "NOMAD_PORT_http" }};
    server_name   ${v};
    location / {
      proxy_pass  http://${k};
    }
  }
%{ endfor }
EOF
        destination = "local/test.conf"
        change_mode = "signal"
        change_signal = "SIGHUP"
      }

      template {
        data = <<EOF
{{- $upstream := service "${var.consul_service_discovery_name}" -}}
{{- range $upstream }}
{{ .Address }}:{{ .Port }}
{{- end }}

EOF
        destination = "local/unicast_hosts.txt"
        change_mode = "noop"
      }

      resources {
        cpu = var.cpu
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
  default = "global"
}

variable "datacenters" {
  type = list(string)
  default = ["dc1"]
}

variable "image" {
  type = string
  default = "nginx:1.18.0-alpine"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "cpu" {
  type = number
  default = 100
}

variable "memory" {
  type = number
  default = 128
}

variable "domains" {
  type = map(string)
  default = {
    prometheus = "wotv-dev-prometheus.seayoo.com"
    grafana = "wotv-dev-grafana.seayoo.com"
  }
}

variable "consul_service_discovery_name" {
  type = string
  default = "elasticsearch"
}

variable "custer_info" {
  type = list(object(
    {
      name = string
      ip = string
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