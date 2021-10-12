job "zt-server" {
  region      = var.region
  datacenters = var.datacenters
  type        = "service"

  constraint {
    attribute = "${node.class}"
    value     = "prometheus"
  }

  // Enable rolling updates
  update {
    max_parallel = 1
  }

  group "zt-server" {
    scaling {
      min = 1
      max = 5
    }

    task "zt-server" {
      driver = "docker"

      user = "root"

      shutdown_delay = "10s"
      kill_timeout   = "30s"

      template {
        data        = file("cache.php")
        destination = "local/cache.php"
        change_mode = "noop"
      }

      template {
        data        = file("redis.php")
        destination = "local/redis.php"
        change_mode = "noop"
      }

      template {
        data        = file("database.php")
        destination = "local/database.php"
        change_mode = "noop"
      }

      template {
        data        = file("upload.php")
        destination = "local/upload.php"
        change_mode = "noop"
      }

      template {
        data        = file("env.php")
        destination = "local/env.php"
        change_mode = "noop"
      }

      template {
        data        = file("dsp.php")
        destination = "local/dsp.php"
        change_mode = "noop"
      }

      template {
        data        = file("zz-docker.conf")
        destination = "local/zz-docker.conf"
        change_mode = "noop"
      }

      config {
        image        = "docker.shiyou.kingsoft.com/web/zt-server:v11"
        network_mode = "host"
        volumes = [
          "local/cache.php:/var/www/html/config/cache.php",
          "local/database.php:/var/www/html/config/database.php",
          "local/redis.php:/var/www/html/config/redis.php",
          "local/upload.php:/var/www/html/config/upload.php",
          "local/env.php:/var/www/html/config/env.php",
          "local/dsp.php:/var/www/html/vendor/xsjosg-zt/core/dsp.php",
          "local/zz-docker.conf:/usr/local/etc/php-fpm.d/zz-docker.conf",
        ]
      }

      resources {
        cpu    = 100
        memory = 128
        network {
          port "php" {}
        }
      }

      service {
        name         = "zt-server"
        port         = "php"
        address_mode = "host"
        check {
          name     = "ZT Server tcp Check"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    task "zt-nginx" {
      driver = "docker"

      config {
        image = "nginx:1.19.6"
        args = [
          "nginx",
          "-c", "/local/nginx.conf",
          "-g", "daemon off;",
        ]
        network_mode = "host"
      }

      env {
        # https://hub.docker.com/_/nginx
        NGINX_ENTRYPOINT_QUIET_LOGS = "1"
      }

      # https://learn.hashicorp.com/tutorials/nomad/reverse-proxy-ui
      template {
        data          = file("nginx/conf")
        destination   = "local/nginx.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      resources {
        cpu    = 100
        memory = 64
        network {
          port "http" {}
        }
      }
      service {
        name         = "zt-nginx"
        port         = "http"
        address_mode = "host"
        tags = [
          "prometheus-php-fpm",
        ]
        check {
          name     = "ZT Server HTTP Check"
          type     = "http"
          path     = "/core/cpanel/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    task "zt-php-fpm-exporter" {
      driver = "docker"
      user   = "root"

      config {
        image = "hipages/php-fpm_exporter:1.2.1"
        args = [
          "--phpfpm.scrape-uri",
          "tcp://${NOMAD_ADDR_zt_server_php}/status",
          "--web.listen-address",
          ":${NOMAD_PORT_exporter}"
        ]
        network_mode = "host"
      }

      resources {
        cpu    = 100
        memory = 64
        network {
          port "exporter" {}
        }
      }

      service {
        name         = "zt-php-fpm-exporter"
        port         = "exporter"
        address_mode = "host"
        tags = [
          "prometheus-php-fpm",
          "prometheus-metrics",
        ]
        check {
          name     = "PHP-fpm Prometheus Exporter TCP Check"
          type     = "tcp"
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
