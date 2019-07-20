global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
- job_name: prometheus
  static_configs:
  - targets:
    - localhost:9090
- job_name: prometheus_server
  static_configs:
  - targets:
    - localhost:9100
- job_name: nodes
  static_configs:
  - targets:
%{ for node_ip in node_ips ~}
    - ${node_ip}:9100
%{ endfor ~}
