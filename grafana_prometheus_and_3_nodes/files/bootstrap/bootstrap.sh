apt update

# apt-get -y install \
#     apt-transport-https \
#     ca-certificates \
#     curl \
#     gnupg-agent \
#     software-properties-common

# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# add-apt-repository \
#    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#    $(lsb_release -cs) \
#    stable"

# apt-get update

# apt-get install docker-ce docker-ce-cli containerd.io

# docker network create monitoring

# docker volume create prometheus_data
# docker volume create grafana_data


cp /tmp/bootstrap/dashboard.json /root
cp /tmp/bootstrap/dashboard.yml /root
cp /tmp/bootstrap/datasource.yml /root

# docker run -d --name prometheus -p 9090:9090 --network monitoring \
#   -v prometheus_data:/prometheus \
#   -v /root/prometheus.yml:/etc/prometheus/prometheus.yml \
#   prom/prometheus


# docker run -d --name node-exporter --network monitoring prom/node-exporter

# docker run -d --name grafana -p 3000:3000 -e "GF_SECURITY_ADMIN_PASSWORD=admin1" \
#   --network monitoring \
#   -v grafana_data:/var/lib/grafana \
#   -v /root/datasource.yml:/etc/grafana/provisioning/datasources/datasource.yml \
#   -v /root/dashboard.json:/dashboard/prom_dashboad.json \
#   -v /root/dashboard.yml:/etc/grafana/provisioning/dashboards/dashboard.yml \
#   grafana/grafana:6.2.5

apt-get install -y -qq software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
apt-get update
apt-get install -y -qq grafana

mkdir /dashboard/
cp /root/dashboard.json /dashboard/prom_dashboad.json
cp /root/dashboard.yml /etc/grafana/provisioning/dashboards/dashboard.yml
cp /root/datasource.yml /etc/grafana/provisioning/datasources/datasource.yml

cat > /etc/grafana/grafana.ini << EOF
[security]

admin_password = secret_password
EOF

systemctl start grafana-server
systemctl enable grafana-server

apt install -y -qq prometheus

wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
tar xvf node_exporter-0.18.1.linux-amd64.tar.gz
nohup /root/node_exporter-0.18.1.linux-amd64/node_exporter &

cp /root/prometheus.yml /etc/prometheus/prometheus.yml
systemctl restart prometheus



