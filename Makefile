ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PREFIX:=mkyc
CLUSTER_NAME:=azurerhel07

epi-certs: gen-certs-task

epi-init: epicli-init
epi-apply: epicli-apply
epi-delete: epicli-delete
epi-get-kube: epicli-get-output-task epicli-get-kubeconf-task
epi-nsr: epicli-add-nsr #run once not idempotent
epi-disks: epicli-add-disks

get-nodes: kube-get-nodes-task
rook-setup: rook-common-task rook-operator-task rook-cluster-task


define SP_BODY
appId: ${ARM_CLIENT_ID}
displayName: $(PREFIX)-$(CLUSTER_NAME)-rg
name: http://$(PREFIX)-$(CLUSTER_NAME)-rg
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
resource "azurerm_managed_disk" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk" {
  name                 = "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

resource "azurerm_managed_disk" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk" {
  name                 = "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

resource "azurerm_managed_disk" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk" {
  name                 = "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

resource "azurerm_virtual_machine_data_disk_attachment" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk-attachment" {
  managed_disk_id    = azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk.id
  virtual_machine_id = azurerm_virtual_machine.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0.id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_data_disk_attachment" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk-attachment" {
  managed_disk_id    = azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk.id
  virtual_machine_id = azurerm_virtual_machine.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1.id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_data_disk_attachment" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk-attachment" {
  managed_disk_id    = azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk.id
  virtual_machine_id = azurerm_virtual_machine.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2.id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_subnet_network_security_group_association" "nsg-association" {
  subnet_id                 = azurerm_subnet.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-master-subnet-0.id
  network_security_group_id = azurerm_network_security_group.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-master-nsg-0.id
}
endef
export DATA_DISKS

gen-certs-task:
	ssh-keygen -t rsa -b 4096 -f $(ROOT_DIR)/epiphany/azure/shared/azure_rsa -N '' <<<y 2>&1 >/dev/null

epicli-init:
	mkdir -p $(ROOT_DIR)/epiphany/azure/shared/build/$(CLUSTER_NAME)/terraform
	@echo "$$SP_BODY" > $(ROOT_DIR)/epiphany/azure/shared/build/$(CLUSTER_NAME)/terraform/sp.yml

epicli-apply:
	docker run --rm \
		-v $(ROOT_DIR)/epiphany/azure/shared:/shared \
		-it epiphanyplatform/epicli:0.7.1 \
		-c "epicli --auto-approve apply --vault-password 123 -f /shared/$(CLUSTER_NAME).yml"


epicli-get-output-task:
	@echo "$$TF_OUTPUT" > $(ROOT_DIR)/epiphany/azure/shared/build/$(CLUSTER_NAME)/terraform/output.tf
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/epiphany/azure/shared:/shared \
		-w /shared \
		-t epiphanyplatform/epicli:0.7.1 -c "terraform refresh -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate /shared/build/$(CLUSTER_NAME)/terraform/"
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/epiphany/azure/shared:/shared \
		-w /shared \
		-t epiphanyplatform/epicli:0.7.1 -c "terraform output -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate -json kube_config > /shared/build/out.json"

epicli-add-nsr:
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/epiphany/azure/shared:/shared \
		-w /shared \
		-t epiphanyplatform/epicli:0.7.1 -c "terraform refresh -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate /shared/build/$(CLUSTER_NAME)/terraform/"
	sed -i.bckp '$$ d' $(ROOT_DIR)/epiphany/azure/shared/build/$(CLUSTER_NAME)/terraform/005_$(PREFIX)-$(CLUSTER_NAME)-kubernetes-master-nsg-0.tf
	@echo "$$K8_NSR" >> $(ROOT_DIR)/epiphany/azure/shared/build/$(CLUSTER_NAME)/terraform/005_$(PREFIX)-$(CLUSTER_NAME)-kubernetes-master-nsg-0.tf
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/epiphany/azure/shared:/shared \
		-w /shared \
		-it epiphanyplatform/epicli:0.7.1 -c "terraform apply -auto-approve -target=azurerm_network_security_group.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-master-nsg-0 -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate /shared/build/$(CLUSTER_NAME)/terraform/"

epicli-add-disks:
	@echo "$$DATA_DISKS" > $(ROOT_DIR)/epiphany/azure/shared/build/$(CLUSTER_NAME)/terraform/disks.tf
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/epiphany/azure/shared:/shared \
		-w /shared \
		-it epiphanyplatform/epicli:0.7.1 -c "terraform apply -auto-approve -target=azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk -target=azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk -target=azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk -target=azurerm_virtual_machine_data_disk_attachment.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk-attachment -target=azurerm_virtual_machine_data_disk_attachment.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk-attachment -target=azurerm_virtual_machine_data_disk_attachment.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk-attachment -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate /shared/build/$(CLUSTER_NAME)/terraform/"

epicli-get-kubeconf-task:
	$(eval MASTER_IP=$(shell sh -c "cat $(ROOT_DIR)/epiphany/azure/shared/build/out.json | docker run --rm -i imega/jq -cr .ip_address"))
	ssh -oStrictHostKeyChecking=no -i $(ROOT_DIR)/epiphany/azure/shared/azure_rsa operations@$(MASTER_IP) "sudo cp /etc/kubernetes/admin.conf /home/operations/kconf && sudo chmod 644 /home/operations/kconf"
	scp -oStrictHostKeyChecking=no -i $(ROOT_DIR)/epiphany/azure/shared/azure_rsa operations@$(MASTER_IP):/home/operations/kconf $(ROOT_DIR)/rook/kubeconf
	sed  -i.bckp 's/.*server: https.*/    server: https:\/\/$(MASTER_IP):6443/g' $(ROOT_DIR)/rook/kubeconf


epicli-delete:
	docker run --rm \
		-v $(ROOT_DIR)/epiphany/azure/shared:/shared \
		-it epiphanyplatform/epicli:0.7.1 \
		-c "epicli --auto-approve delete -b /shared/build/$(CLUSTER_NAME)"

init-task:
	docker run --rm \
		-e TF_LOG=TRACE \
		-v $(ROOT_DIR)/terraform:/terraform \
		-w /terraform \
		-t hashicorp/terraform:0.12.28 init -var="prefix=$(PREFIX)"

plan-task:
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/terraform:/terraform \
		-w /terraform \
		-t hashicorp/terraform:0.12.28 plan -var="prefix=$(PREFIX)" /terraform

apply-task:
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/terraform:/terraform \
		-w /terraform \
		-t hashicorp/terraform:0.12.28 apply -auto-approve -var="prefix=$(PREFIX)" /terraform

get-kubeconfig-task:
	docker run --rm \
		-v $(ROOT_DIR)/terraform:/terraform \
		-v $(ROOT_DIR)/rook:/rook \
		-w /terraform \
		-t hashicorp/terraform:0.12.28 output kube_config > $(ROOT_DIR)/rook/kubeconf

destroy-task:
	rm -f $(ROOT_DIR)/rook/kubeconf
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/terraform:/terraform \
		-w /terraform \
		-t hashicorp/terraform:0.12.28 destroy -auto-approve -var="prefix=$(PREFIX)" /terraform

kube-get-nodes-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 get nodes --insecure-skip-tls-verify

rook-common-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-common-1.4.yaml --insecure-skip-tls-verify

rook-operator-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-operator-1.4.yaml --insecure-skip-tls-verify

rook-cluster-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-cluster-1.4.yaml --insecure-skip-tls-verify

rook-toolbox-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-toolbox-1.4.yaml --insecure-skip-tls-verify
