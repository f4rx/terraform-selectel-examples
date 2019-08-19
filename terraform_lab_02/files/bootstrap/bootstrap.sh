apt update

cp /tmp/bootstrap/dashboard.json /root
cp /tmp/bootstrap/dashboard.yml /root
cp /tmp/bootstrap/datasource.yml /root

apt-get install -y -qq software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
apt-get update
apt-get install -y -qq grafana

mkdir /dashboard/
cp /root/dashboard.json /dashboard/prom_dashboad.json
cp /root/dashboard.yml /etc/grafana/provisioning/dashboards/dashboard.yml
cp /root/datasource.yml /etc/grafana/provisioning/datasources/datasource.yml
cp /root/grafana.ini /etc/grafana/grafana.ini

systemctl start grafana-server
systemctl enable grafana-server

apt install -y -qq prometheus

wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
tar xvf node_exporter-0.18.1.linux-amd64.tar.gz
nohup /root/node_exporter-0.18.1.linux-amd64/node_exporter &

cp /root/prometheus.yml /etc/prometheus/prometheus.yml
systemctl restart prometheus



