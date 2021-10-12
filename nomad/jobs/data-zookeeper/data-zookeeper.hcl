namespace = "data-dev"

group_names = ["zookeeper-1", "zookeeper-2", "zookeeper-3"]

zoo_myid = <<EOF
{{ env "ZOO_MY_ID" }}
EOF

zoo_entrypoint = <<EOF
#!/usr/bin/env bash
set -e

echo "start sleep..."
sleep 30 # reasonable default
echo "stop sleep."

if [[ -z "$ZOO_CONF_DIR" ]]; then
    ENV ZOO_DATA_DIR=/data
fi

if [[ -z "$ZOO_DATA_DIR" ]]; then
    ENV ZOO_DATA_DIR=/data
fi

if [[ -z "$ZOO_DATA_LOG_DIR" ]]; then
    ENV ZOO_DATA_LOG_DIR=/datalog
fi

if [[ -z "$ZOO_LOG_DIR" ]]; then
    ENV ZOO_LOG_DIR=/logs
fi

mkdir -p "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR" "$ZOO_LOG_DIR"
chown -R zookeeper:zookeeper "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR" "$ZOO_LOG_DIR"
su zookeeper -s /bin/bash -c "zkServer.sh start-foreground"
EOF

zoo_cfg_dynamic = <<EOF
{{- $SERVICE_NAME := env "NOMAD_META_zoo_service_name" -}}
{{- range $tag, $services := service $SERVICE_NAME | byTag -}}
  {{- range $services -}}
    {{- $ID := split "-" .ID -}}
    {{- $ALLOC := join "-" (slice $ID 0 (subtract 1 (len $ID ))) -}}
    {{- if .ServiceMeta.ZK_ID -}}
      {{- scratch.MapSet "allocs" $ALLOC $ALLOC -}}
      {{- scratch.MapSet "tags" $tag $tag -}}
      {{- scratch.MapSet $ALLOC "ZK_ID" .ServiceMeta.ZK_ID -}}
      {{- scratch.MapSet $ALLOC (printf "%s_%s" $tag "address") .Address -}}
      {{- scratch.MapSet $ALLOC (printf "%s_%s" $tag "port") .Port -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- range $ai, $a := scratch.MapValues "allocs" -}}
  {{- $alloc := scratch.Get $a -}}
  {{- with $alloc -}}
server.{{ .ZK_ID }} = {{ .peer_address }}:{{ .peer_port }}:{{ .election_port }};{{.client_port}}{{println ""}}
  {{- end -}}
{{- end -}}
EOF

zoo_cfg = <<EOF
clientPort={{ env "NOMAD_PORT_client" }}
tickTime=2000
initLimit=30
syncLimit=2
reconfigEnabled=true
dynamicConfigFile=/conf/zoo.cfg.dynamic
dataDir={{ env "ZOO_DATA_DIR" }}
standaloneEnabled=false
quorumListenOnAllIPs=true
4lw.commands.whitelist=*
metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider
metricsProvider.httpPort={{ env "NOMAD_PORT_exporter" }}
metricsProvider.exportJvmInfo=true
admin.serverPort={{ env "NOMAD_PORT_admin" }}
EOF

