# All hosts
[jumpbox-group]
jumpbox ansible_host=${jump_host_ip}

[www]
${web_hosts_inventory}

[db-group]
db ansible_host=${db_host_ip} ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q root@${jump_host_ip}"'

