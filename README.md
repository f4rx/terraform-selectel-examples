## Проекты
### Описание
**single-sever** - запуск одного инстанса, создает сопутствующие ресурсы: flavor, внешняя сеть, внутренняя сеть, роутер, порты, floating ip, диск и собственно сам сервер, устанавливает ассоциацию floating ip и сервера.  
**jump-box_and_3-servers** - создается приватная сеть  192/24, запуск одного сервера - бастинг-хост (шел-бокс, джамп бокс) с Floatin IP (внешний адрес)  и трех нод, доступ к ним осуществляется через бастинг хост. В дальнейшем можно поставить на него nginx и проксипасить запросы на бекенды.  
**grafana_prometheus_and_3_nodes** - Расширенный пример предыдущего шага с добавлением провизионеров для бутстрапа хостов - на шеллбокс ставится графана с прометеус серверов, (http://server_ip:3000,  логин/пароль admin/secret_password) с уже готовым дашбордом, и экспортеры с нод пишут данные в пром сервер. Рассширение серверов не привод к обновлению конфига прометеуса, т.к. привижионер запускается только один раз.  
**lb-3-servers-jumpbox** - Лоад балансер c внешним IP, бастион хост с в внешним IP и 3 ноды без внешнего адреса, при запросак к LB через RR отдается информация о каждом хосте. [Подробнее](lb-3-servers-jumpbox/README.md)


## Начало работы
В панели my.selectel.ru создать проект https://my.selectel.ru/vpc/projects, на странице https://my.selectel.ru/vpc/users создать пользователя и добавить его в проект.

На проект выделить в ru-3 (Санкт-Петербург 2) квоты
Плавающие IP - 2
vCPU - 7
RAM - 7
Быстрый диск - 40
можно с запасом, это необходимый дамп.

Скопировать secret.tfvars.example в secret.tfvars и подставив значения, во всех примерах используется регин ru-3 (зона ru-3a), пока не параметризировал.
```
user_name = "Пользователь, созданный с доступом к проекту"
user_password = "PASSWORD"
donain_name = "логин в my.selectel.ru, он же номер договора, цифры"
public_key = "SSH PUBLIC KEY"
```

## Полезные команды

Инициализировать проект
```bash
cd single-server
terraform init
```

Запуск стенда.
```bash
terraform apply  -var-file="../secret.tfvars"
```

Разобрать стенд
```bash
terraform destroy -var-file="../secret.tfvars"
```

Удалить только вольюм и сервер (пример 2)
```bash
terraform destroy -var-file="../secret.tfvars" -target=openstack_compute_instance_v2.jump_box -target=openstack_blockstorage_volume_v3.volume_1
```

Дебаг
```bash
TF_LOG=debug terraform ....
OS_DEBUG=1 TF_LOG=DEBUG terraform ....
```

Не вводить yes:
```bash
 terraform apply --auto-approve=true
```

## Вывод (output)
**jump-box_and_3-servers** Пример

```bash
terraform apply -var-file="../secret.tfvars"
...
Apply complete! Resources: 23 added, 0 changed, 0 destroyed.

Outputs:

nodes_data = [
  "node-1 a0ebafe8-bbe6-47cc-966c-babd6dc4f055 192.168.0.11",
  "node-2 7f3c0128-56ac-49bb-9f78-e74385c839ba 192.168.0.4",
  "node-3 f6fd5bd2-6c8d-4ce5-8588-e06fa759df0d 192.168.0.5",
]
server_floatingip_address = 46.161.52.233
```
