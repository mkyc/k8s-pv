CLUSTER_NAME = openebs
ADDITIONAL_DISK_SIZE = 10
MACHINE_SIZE = Standard_D2s_v3


define CLUSTER_CONFIG
kind: epiphany-cluster
title: Epiphany cluster Config
provider: azure
name: ${CLUSTER_NAME}
specification:
  prefix: ${PREFIX}
  name: ${CLUSTER_NAME}
  admin_user:
    name: operations
    key_path: /shared/azure_rsa
  cloud:
    subscription_name: ${SUBSCRIPTION_NAME}
    use_public_ips: true
    use_service_principal: true
    region: West Europe
  components:
    kubernetes_master:
      count: 1
      machine: default
    kubernetes_node:
      count: 3
      machine: default
    logging:
      count: 0
      machine: default
    monitoring:
      count: 0
      machine: default
    kafka:
      count: 0
      machine: default
    postgresql:
      count: 0
      machine: default
    load_balancer:
      count: 0
      machine: default
    rabbitmq:
      count: 0
      machine: default
    ignite:
      count: 0
      machine: default
    opendistro_for_elasticsearch:
      count: 0
      machine: default
    repository:
      count: 1
      machine: default
    single_machine:
      count: 0
      machine: default
version: 1.2.0
---
kind: infrastructure/virtual-machine
title: Virtual Machine Infra
provider: azure
name: default
specification:
  os_type: linux
  size: ${MACHINE_SIZE}
version: 1.2.0

endef
export CLUSTER_CONFIG

define SP_BODY
appId: ${ARM_CLIENT_ID}
displayName: ${DISPLAY_NAME}
name: ${NAME}
password: ${ARM_CLIENT_SECRET}
tenant: ${ARM_TENANT_ID}
subscriptionId: ${ARM_SUBSCRIPTION_ID}
endef
export SP_BODY

define TF_OUTPUT
output "kube_config" {
  value = azurerm_public_ip.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-master-pubip-0
}
endef
export TF_OUTPUT

define K8_NSR
  security_rule {
    name                        = "k8s-api"
    description                 = "Allow access K8s API"
    priority                    = 300
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "6443"
    source_address_prefix       = "0.0.0.0/0"
    destination_address_prefix  = "0.0.0.0/0"
  }
}
endef
export K8_NSR

define DATA_DISKS
resource "azurerm_managed_disk" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk-a" {
  name                 = "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk-a"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = ${ADDITIONAL_DISK_SIZE}
}
resource "azurerm_managed_disk" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk-b" {
  name                 = "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk-b"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = ${ADDITIONAL_DISK_SIZE}
}

resource "azurerm_virtual_machine_data_disk_attachment" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk-attachment-a" {
  managed_disk_id    = azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk-a.id
  virtual_machine_id = azurerm_virtual_machine.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0.id
  lun                = "10"
  caching            = "ReadWrite"
}
resource "azurerm_virtual_machine_data_disk_attachment" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk-attachment-b" {
  managed_disk_id    = azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk-b.id
  virtual_machine_id = azurerm_virtual_machine.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0.id
  lun                = "20"
  caching            = "ReadWrite"
}

resource "azurerm_managed_disk" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk-a" {
  name                 = "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk-a"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = ${ADDITIONAL_DISK_SIZE}
}
resource "azurerm_managed_disk" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk-b" {
  name                 = "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk-b"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = ${ADDITIONAL_DISK_SIZE}
}

resource "azurerm_virtual_machine_data_disk_attachment" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk-attachment-a" {
  managed_disk_id    = azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk-a.id
  virtual_machine_id = azurerm_virtual_machine.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1.id
  lun                = "10"
  caching            = "ReadWrite"
}
resource "azurerm_virtual_machine_data_disk_attachment" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk-attachment-b" {
  managed_disk_id    = azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk-b.id
  virtual_machine_id = azurerm_virtual_machine.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1.id
  lun                = "20"
  caching            = "ReadWrite"
}

resource "azurerm_managed_disk" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk-a" {
  name                 = "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk-a"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = ${ADDITIONAL_DISK_SIZE}
}
resource "azurerm_managed_disk" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk-b" {
  name                 = "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk-b"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = ${ADDITIONAL_DISK_SIZE}
}

resource "azurerm_virtual_machine_data_disk_attachment" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk-attachment-a" {
  managed_disk_id    = azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk-a.id
  virtual_machine_id = azurerm_virtual_machine.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2.id
  lun                = "10"
  caching            = "ReadWrite"
}
resource "azurerm_virtual_machine_data_disk_attachment" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk-attachment-b" {
  managed_disk_id    = azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk-b.id
  virtual_machine_id = azurerm_virtual_machine.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2.id
  lun                = "20"
  caching            = "ReadWrite"
}

resource "azurerm_subnet_network_security_group_association" "nsg-association" {
  subnet_id                 = azurerm_subnet.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-master-subnet-0.id
  network_security_group_id = azurerm_network_security_group.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-master-nsg-0.id
}
endef
export DATA_DISKS

define ADD_ISCSI
---
- name: Enable iSCSI
  hosts: kubernetes_node
  become: true
  become_method: sudo

  tasks:
    - name: Update repositories cache and install open-iscsi package
      ansible.builtin.apt:
        name: open-iscsi
        update_cache: yes
    - name: Enable iscsid
      ansible.builtin.systemd:
        state: started
        enabled: yes
        name: iscsid
    - name: Make sure a iscsid is running
      ansible.builtin.systemd:
        state: started
        daemon_reload: yes
        name: iscsid
    - name: Create a ext4 filesystem on /dev/sdc and check disk blocks
      community.general.filesystem:
        fstype: ext4
        dev: /dev/sdc
    - name: Mount up device
      ansible.posix.mount:
        path: /opt/openebs
        src: /dev/sdc
        fstype: ext4
        state: mounted

endef
export ADD_ISCSI

define ADD_RAW
---
- name: Mount additional disk
  hosts: kubernetes_node
  become: true
  become_method: sudo

  tasks:
    - name: Create a ext4 filesystem on /dev/sdd and check disk blocks
      community.general.filesystem:
        fstype: ext4
        dev: /dev/sdd
    - name: Mount up device
      ansible.posix.mount:
        path: /mnt/raw
        src: /dev/sdd
        fstype: ext4
        state: mounted

endef
export ADD_RAW

sub-init:
	mkdir -p $(ROOT_DIR)/run/shared/build/$(CLUSTER_NAME)/terraform
	echo "$$SP_BODY" > $(ROOT_DIR)/run/shared/build/$(CLUSTER_NAME)/terraform/sp.yml
	ssh-keygen -t rsa -b 4096 -f $(ROOT_DIR)/run/shared/azure_rsa -N '' <<<y 2>&1 >/dev/null
	echo "$$CLUSTER_CONFIG" > $(ROOT_DIR)/run/shared/$(CLUSTER_NAME).yml

sub-apply1:
	docker run --rm \
		-v $(ROOT_DIR)/run/shared:/shared \
		-it epiphanyplatform/epicli:1.2.0 \
		-c "epicli --auto-approve apply --vault-password 123 -f /shared/$(CLUSTER_NAME).yml"
	echo "$$TF_OUTPUT" > $(ROOT_DIR)/run/shared/build/$(CLUSTER_NAME)/terraform/output.tf
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t epiphanyplatform/epicli:1.2.0 -c "terraform refresh -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate /shared/build/$(CLUSTER_NAME)/terraform/"
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t epiphanyplatform/epicli:1.2.0 -c "terraform output -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate -json kube_config > /shared/build/out.json"

sub-apply2:
	$(eval MASTER_IP=$(shell sh -c "cat $(ROOT_DIR)/run/shared/build/out.json | docker run --rm -i imega/jq -cr .ip_address"))
	ssh -oStrictHostKeyChecking=no -i $(ROOT_DIR)/run/shared/azure_rsa operations@$(MASTER_IP) "sudo cp /etc/kubernetes/admin.conf /home/operations/kconf && sudo chmod 644 /home/operations/kconf"
	scp -oStrictHostKeyChecking=no -i $(ROOT_DIR)/run/shared/azure_rsa operations@$(MASTER_IP):/home/operations/kconf $(ROOT_DIR)/run/shared/kubeconf
	sed  -i.bckp 's/.*server: https.*/    server: https:\/\/$(MASTER_IP):6443/g' $(ROOT_DIR)/run/shared/kubeconf
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t epiphanyplatform/epicli:1.2.0 -c "terraform refresh -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate /shared/build/$(CLUSTER_NAME)/terraform/"
	sed -i.bckp '$$ d' $(ROOT_DIR)/run/shared/build/$(CLUSTER_NAME)/terraform/005_$(PREFIX)-$(CLUSTER_NAME)-kubernetes-master-nsg-0.tf
	echo "$$K8_NSR" >> $(ROOT_DIR)/run/shared/build/$(CLUSTER_NAME)/terraform/005_$(PREFIX)-$(CLUSTER_NAME)-kubernetes-master-nsg-0.tf
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-it epiphanyplatform/epicli:1.2.0 -c "terraform apply -auto-approve -target=azurerm_network_security_group.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-master-nsg-0 -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate /shared/build/$(CLUSTER_NAME)/terraform/"
	echo "$$DATA_DISKS" > $(ROOT_DIR)/run/shared/build/$(CLUSTER_NAME)/terraform/disks.tf
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-it epiphanyplatform/epicli:1.2.0 -c "terraform apply -auto-approve -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate /shared/build/$(CLUSTER_NAME)/terraform/"
	echo "$$ADD_ISCSI" > $(ROOT_DIR)/run/shared/build/$(CLUSTER_NAME)/add-iscsi.yml
	docker run --rm \
		-v $(ROOT_DIR)/run/shared:/shared \
		-it epiphanyplatform/epicli:1.2.0 \
		-c "ansible-playbook -i /shared/build/$(CLUSTER_NAME)/inventory /shared/build/$(CLUSTER_NAME)/add-iscsi.yml"
	echo "$$ADD_RAW" > $(ROOT_DIR)/run/shared/build/$(CLUSTER_NAME)/add-raw.yml
	docker run --rm \
		-v $(ROOT_DIR)/run/shared:/shared \
		-it epiphanyplatform/epicli:1.2.0 \
		-c "ansible-playbook -i /shared/build/$(CLUSTER_NAME)/inventory /shared/build/$(CLUSTER_NAME)/add-raw.yml"

sub-persistence:
	cp $(ROOT_DIR)/configurations/$(CONFIGURATION)/openebs-*.yaml $(ROOT_DIR)/run/shared/
	docker run --rm \
		-e KUBECONFIG=/shared/kubeconf \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t bitnami/kubectl:1.17.9 apply -f /shared/openebs-operator.yaml --insecure-skip-tls-verify
	sleep 5
	docker run --rm \
		-e KUBECONFIG=/shared/kubeconf \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t bitnami/kubectl:1.17.9 apply -f /shared/openebs-jiva-operator.yaml --insecure-skip-tls-verify
	sleep 5
	docker run --rm \
		-e KUBECONFIG=/shared/kubeconf \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t bitnami/kubectl:1.17.9 apply -f /shared/openebs-jvp.yaml --insecure-skip-tls-verify
	sleep 5
	docker run --rm \
		-e KUBECONFIG=/shared/kubeconf \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t bitnami/kubectl:1.17.9 apply -f /shared/openebs-sc.yaml --insecure-skip-tls-verify
	sleep 5
	docker run --rm \
		-e KUBECONFIG=/shared/kubeconf \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t bitnami/kubectl:1.17.9 apply -f /shared/openebs-test-app.yaml --insecure-skip-tls-verify

sub-performance:
	cp $(ROOT_DIR)/configurations/$(CONFIGURATION)/kbench.yaml $(ROOT_DIR)/run/shared/
	-docker run --rm \
		-e KUBECONFIG=/shared/kubeconf \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t bitnami/kubectl:1.17.9 delete job kbench --insecure-skip-tls-verify
	-docker run --rm \
		-e KUBECONFIG=/shared/kubeconf \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t bitnami/kubectl:1.17.9 delete pvc kbench-pvc --insecure-skip-tls-verify
	docker run --rm \
		-e KUBECONFIG=/shared/kubeconf \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t bitnami/kubectl:1.17.9 apply -f /shared/kbench.yaml --insecure-skip-tls-verify

sub-nuke:
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t epiphanyplatform/epicli:1.2.0 -c "terraform destroy -auto-approve -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate /shared/build/$(CLUSTER_NAME)/terraform/"
	rm -rf $(ROOT_DIR)/run
