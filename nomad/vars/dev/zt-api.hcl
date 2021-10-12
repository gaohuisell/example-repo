node_class = "zt-backend"
cpu        = 500
memory     = 1024

projects = [
  {
    name = "bp"
    env = {
      app_env           = "dev"
      mysql_username    = "zt_api"
      mysql_database    = "beatparty"
      mysql_writer_port = 3306
      mysql_writer_host = "sgsdk-dev-aurora-mysql.cluster-cyt4o4cwgyqu.ap-east-1.rds.amazonaws.com"
      mysql_reader_port = 3306
      mysql_reader_host = "sgsdk-dev-aurora-mysql.cluster-cyt4o4cwgyqu.ap-east-1.rds.amazonaws.com"
      redis_host        = "sgsdk-dev-redis.jobppl.ng.0001.ape1.cache.amazonaws.com"
      redis_port        = 6379
      project_name      = "bp"
      sms_app_name      = "魔域手游2"
      // cookie_salt = "{{ key "zt-api/bp/cookie-salt" }}"
      // mysql_password = "{{ key "mysql/users/zt_api_bp" }}"
      // sms_access_key = "{{ key "zt-api/bp/sms/moyu2/ak" }}"
      // sms_secret_key = "{{ key "zt-api/bp/sms/moyu2/sk" }}"
    }
    consul_service_tags = [
      "prometheus-metrics",
      "traefik.enable=true",
      "traefik.http.routers.zt-api-bp.rule=Host(`api.zt-test.seayoo.io`) && PathPrefix(`/bp/`)",
      "traefik.http.services.zt-api-bp.loadbalancer.passhostheader=true",
      "traefik.http.routers.zt-api-bp.middlewares=zt-api-bp-replace",
      "traefik.http.middlewares.zt-api-bp-replace.replacepathregex.regex=^/bp/health",
      "traefik.http.middlewares.zt-api-bp-replace.replacepathregex.replacement=/health",
    ]
  },
  {
    name = "ba"
    env = {
      app_env           = "dev"
      mysql_username    = "zt_api"
      mysql_database    = "beatparty"
      mysql_writer_port = 3306
      mysql_writer_host = "sgsdk-dev-aurora-mysql.cluster-cyt4o4cwgyqu.ap-east-1.rds.amazonaws.com"
      mysql_reader_port = 3306
      mysql_reader_host = "sgsdk-dev-aurora-mysql.cluster-cyt4o4cwgyqu.ap-east-1.rds.amazonaws.com"
      redis_host        = "sgsdk-dev-redis.jobppl.ng.0001.ape1.cache.amazonaws.com"
      redis_port        = 6379
      project_name      = "bp"
      sms_app_name      = "魔域手游2"
      // cookie_salt = "{{ key "zt-api/bp/cookie-salt" }}"
      // mysql_password = "{{ key "mysql/users/zt_api_bp" }}"
      // sms_access_key = "{{ key "zt-api/bp/sms/moyu2/ak" }}"
      // sms_secret_key = "{{ key "zt-api/bp/sms/moyu2/sk" }}"
    }
    consul_service_tags = [
      "prometheus-metrics",
      "traefik.enable=true",
      "traefik.http.routers.zt-api-bp.rule=Host(`api.zt-test.seayoo.io`) && PathPrefix(`/bp/`)",
      "traefik.http.services.zt-api-bp.loadbalancer.passhostheader=true",
      "traefik.http.routers.zt-api-bp.middlewares=zt-api-bp-replace",
      "traefik.http.middlewares.zt-api-bp-replace.replacepathregex.regex=^/bp/health",
      "traefik.http.middlewares.zt-api-bp-replace.replacepathregex.replacement=/health",
    ]
  }
]
