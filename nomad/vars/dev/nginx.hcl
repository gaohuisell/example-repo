cpu = 100
memory = 256

domains = {
  prometheus = "wotv-dev-prometheus.seayoo.com"
  grafana = "wotv-dev-grafana.seayoo.com"
  alertmanager = "wotv-dev-alertmanager.seayoo.com"
  manager = "wotv-dev-manager.seayoo.com"
  "api.traefik" = "wotv-dev-traefik.seayoo.com"
}

environments = <<EOF
NOMAD_MYSQL_URL="jdbc:mysql://uop-dev-aurora-mysql.cluster-c9ntc7skbu5q.rds.cn-northwest-1.amazonaws.com.cn:3306/club"
mysql_username="club"
mysql_password="{{ key "mysql/users/club" }}"

kafka_bootstrap_servers="kafka.service.consul:9092"

custom_transfer_source_app_id="1002"
custom_transfer_target_game_id="58a2768a-184b-45d7-8e09-d16efcbe3b10"
custom_transfer_target_game_name="风暴魔域 2"

storm_secret_key="f54ee6d5a39700e0bfd8e33ff7bcfc9e"
promo_secret_key="3f8e67d90e6ae283198e0a51580657be"

sk = "234"
EOF
