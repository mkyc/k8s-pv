ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PREFIX:=mkyc1126
CLUSTER_NAME:=rook
CLUSTER_VERSION:=1.7
ADDITIONAL_DISK_SIZE = 520

-include ./service-principal.mk
export

# setup begin
epi-certs: gen-certs-task

epi-init: epicli-init
epi-apply: epicli-apply
epi-get-kube: epicli-get-output-task epicli-get-kubeconf-task
epi-nsr: epicli-add-nsr # run once not idempotent
epi-disks: epicli-add-disks
update-kubelet: update-kubelet-task

rook-setup: rook-crds-task rook-common-task rook-operator-task
rook-cluster: rook-cluster-task # wait until it initializes
rook-storage: rook-storage-class-task
# setup end

# update begin (not implemeneted for 1.7)
rook-upgrade-privilages: rook-update-privileges-task
rook-upgrade-operator: rook-update-operator-task
# update end

# tools begin
epi-delete: epicli-delete
get-nodes: kube-get-nodes-task
epi-nuke: destroy-task
# tools end

# tests begin
rook-test: rook-test-app-task
rook-performance: rook-performance-test-task
# tests end

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
resource "azurerm_managed_disk" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk" {
  name                 = "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = ${ADDITIONAL_DISK_SIZE}
}

resource "azurerm_managed_disk" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk" {
  name                 = "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = ${ADDITIONAL_DISK_SIZE}
}

resource "azurerm_managed_disk" "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk" {
  name                 = "$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = ${ADDITIONAL_DISK_SIZE}
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

define FIX_KUBELET
---
- name: Update kubelet
  hosts: kubernetes_node
  become: true
  become_method: sudo

  tasks:
    - name: fix config file
      ansible.builtin.lineinfile:
        path: /var/lib/kubelet/kubeadm-flags.env
        regexp: '^KUBELET_KUBEADM_ARGS='
        line: KUBELET_KUBEADM_ARGS="--cgroup-driver=systemd --enable-controller-attach-detach=true --network-plugin=cni --node-labels=node-type=epiphany --pod-infra-container-image=${PREFIX}-${CLUSTER_NAME}-repository-vm-0:5000/k8s.gcr.io/pause:3.2 --resolv-conf=/run/systemd/resolve/resolv.conf"

    - name: Restart kubelet
      ansible.builtin.systemd:
        state: restarted
        daemon_reload: yes
        name: kubelet

endef
export FIX_KUBELET

gen-certs-task:
	ssh-keygen -t rsa -b 4096 -f $(ROOT_DIR)/epiphany/azure/shared/azure_rsa -N '' <<<y 2>&1 >/dev/null

epicli-init:
	mkdir -p $(ROOT_DIR)/epiphany/azure/shared/build/$(CLUSTER_NAME)/terraform
	@echo "$$SP_BODY" > $(ROOT_DIR)/epiphany/azure/shared/build/$(CLUSTER_NAME)/terraform/sp.yml

epicli-apply:
	docker run --rm \
		-v $(ROOT_DIR)/epiphany/azure/shared:/shared \
		-it epiphanyplatform/epicli:1.2.0 \
		-c "epicli --auto-approve apply --vault-password 123 -f /shared/$(CLUSTER_NAME).yml"

update-kubelet-task:
	@echo "$$FIX_KUBELET" > $(ROOT_DIR)/epiphany/azure/shared/build/$(CLUSTER_NAME)/modify-kubelet.yml
	docker run --rm \
		-v $(ROOT_DIR)/epiphany/azure/shared:/shared \
		-it epiphanyplatform/epicli:1.2.0 \
		-c "ansible-playbook -i /shared/build/$(CLUSTER_NAME)/inventory /shared/build/$(CLUSTER_NAME)/modify-kubelet.yml"

epicli-get-output-task:
	@echo "$$TF_OUTPUT" > $(ROOT_DIR)/epiphany/azure/shared/build/$(CLUSTER_NAME)/terraform/output.tf
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/epiphany/azure/shared:/shared \
		-w /shared \
		-t epiphanyplatform/epicli:1.2.0 -c "terraform refresh -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate /shared/build/$(CLUSTER_NAME)/terraform/"
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/epiphany/azure/shared:/shared \
		-w /shared \
		-t epiphanyplatform/epicli:1.2.0 -c "terraform output -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate -json kube_config > /shared/build/out.json"

epicli-add-nsr:
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/epiphany/azure/shared:/shared \
		-w /shared \
		-t epiphanyplatform/epicli:1.2.0 -c "terraform refresh -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate /shared/build/$(CLUSTER_NAME)/terraform/"
	sed -i.bckp '$$ d' $(ROOT_DIR)/epiphany/azure/shared/build/$(CLUSTER_NAME)/terraform/005_$(PREFIX)-$(CLUSTER_NAME)-kubernetes-master-nsg-0.tf
	@echo "$$K8_NSR" >> $(ROOT_DIR)/epiphany/azure/shared/build/$(CLUSTER_NAME)/terraform/005_$(PREFIX)-$(CLUSTER_NAME)-kubernetes-master-nsg-0.tf
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/epiphany/azure/shared:/shared \
		-w /shared \
		-it epiphanyplatform/epicli:1.2.0 -c "terraform apply -auto-approve -target=azurerm_network_security_group.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-master-nsg-0 -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate /shared/build/$(CLUSTER_NAME)/terraform/"

epicli-add-disks:
	@echo "$$DATA_DISKS" > $(ROOT_DIR)/epiphany/azure/shared/build/$(CLUSTER_NAME)/terraform/disks.tf
	docker run --rm \
		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
		-v $(ROOT_DIR)/epiphany/azure/shared:/shared \
		-w /shared \
		-it epiphanyplatform/epicli:1.2.0 -c "terraform apply -auto-approve -target=azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk -target=azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk -target=azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk -target=azurerm_virtual_machine_data_disk_attachment.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk-attachment -target=azurerm_virtual_machine_data_disk_attachment.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk-attachment -target=azurerm_virtual_machine_data_disk_attachment.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk-attachment -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate /shared/build/$(CLUSTER_NAME)/terraform/"

epicli-get-kubeconf-task:
	$(eval MASTER_IP=$(shell sh -c "cat $(ROOT_DIR)/epiphany/azure/shared/build/out.json | docker run --rm -i imega/jq -cr .ip_address"))
	ssh -oStrictHostKeyChecking=no -i $(ROOT_DIR)/epiphany/azure/shared/azure_rsa operations@$(MASTER_IP) "sudo cp /etc/kubernetes/admin.conf /home/operations/kconf && sudo chmod 644 /home/operations/kconf"
	scp -oStrictHostKeyChecking=no -i $(ROOT_DIR)/epiphany/azure/shared/azure_rsa operations@$(MASTER_IP):/home/operations/kconf $(ROOT_DIR)/rook/kubeconf
	sed  -i.bckp 's/.*server: https.*/    server: https:\/\/$(MASTER_IP):6443/g' $(ROOT_DIR)/rook/kubeconf


epicli-delete:
	docker run --rm \
		-v $(ROOT_DIR)/epiphany/azure/shared:/shared \
		-it epiphanyplatform/epicli:1.2.0 \
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
		-v $(ROOT_DIR)/epiphany/azure/shared:/shared \
		-w /shared \
		-t epiphanyplatform/epicli:1.2.0 -c "terraform destroy -auto-approve -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate /shared/build/$(CLUSTER_NAME)/terraform/"

kube-get-nodes-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 get nodes --insecure-skip-tls-verify

rook-crds-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-$(CLUSTER_VERSION)/rook-crds-$(CLUSTER_VERSION).yaml --insecure-skip-tls-verify

rook-common-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-$(CLUSTER_VERSION)/rook-common-$(CLUSTER_VERSION).yaml --insecure-skip-tls-verify

rook-operator-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-$(CLUSTER_VERSION)/rook-operator-$(CLUSTER_VERSION).yaml --insecure-skip-tls-verify

rook-cluster-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-$(CLUSTER_VERSION)/rook-cluster-$(CLUSTER_VERSION).yaml --insecure-skip-tls-verify

rook-toolbox-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-$(CLUSTER_VERSION)/rook-toolbox-$(CLUSTER_VERSION).yaml --insecure-skip-tls-verify

rook-storage-class-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-$(CLUSTER_VERSION)/rook-sc-$(CLUSTER_VERSION).yaml --insecure-skip-tls-verify

rook-test-app-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-$(CLUSTER_VERSION)/rook-test-app-$(CLUSTER_VERSION).yaml --insecure-skip-tls-verify

rook-performance-test-task:
	cp $(ROOT_DIR)/rook/kubeconf $(ROOT_DIR)/tests/kubeconf
	docker run --rm \
		-e KUBECONFIG=/tests/kubeconf \
		-v $(ROOT_DIR)/tests:/tests \
		-w /tests \
		-t bitnami/kubectl:1.17.9 apply -f /tests/performance/kbench.yaml --insecure-skip-tls-verify

rook-update-privileges-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 delete -f /rook/rook-1.4/rook-upgrade-from-v1.3-delete.yaml --insecure-skip-tls-verify
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-1.4/rook-upgrade-from-v1.3-apply.yaml -f /rook/rook-1.4/rook-upgrade-from-v1.3-crds.yaml --insecure-skip-tls-verify

rook-update-operator-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 -n rook-ceph set image deploy/rook-ceph-operator rook-ceph-operator=rook/ceph:v1.4.1 --insecure-skip-tls-verify
