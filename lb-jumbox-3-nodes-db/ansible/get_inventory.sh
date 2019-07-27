#!/bin/bash

terraform output -state=../terraform.tfstate   ansible_inventory > inventory.ini
