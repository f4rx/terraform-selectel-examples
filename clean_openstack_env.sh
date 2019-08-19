for i in `openstack loadbalancer pool list -f value -c id`; do for j in ` openstack loadbalancer member list -f value -c id ${i}`; do openstack loadbalancer member delete ${i} ${j}; done ; done

for i in `openstack loadbalancer pool list -f value -c id`; do openstack loadbalancer pool delete ${i}; done

for i in `openstack loadbalancer listener list -f value -c id`; do openstack loadbalancer listener delete ${i}; done

for i in `openstack loadbalancer list -f value -c id`; do openstack loadbalancer  delete ${i}; done


openstack floating ip list -f value -c ID | xargs openstack floating ip delete

for i in `openstack router list -f value -c ID`; do neutron router-port-list -f value -c id ${i} | xargs openstack router remove port ${i}  ; done

openstack router list -f value -c ID | xargs openstack router delete

openstack port list -f value -c ID | xargs openstack port delete

openstack subnet list -f value -c ID | xargs openstack subnet delete

openstack network list --internal -f value -c ID | xargs openstack network delete

openstack server list -f value -c ID | xargs openstack server delete

openstack volume list -f value -c ID | xargs openstack volume delete

openstack image list --private -f value -c ID | xargs openstack image delete

openstack keypair list -f value -c Name | xargs openstack keypair delete
