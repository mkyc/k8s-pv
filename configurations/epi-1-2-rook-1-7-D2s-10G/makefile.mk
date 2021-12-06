CLUSTER_NAME = rook
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
		-it epiphanyplatform/epicli:1.2.0 -c "terraform apply -auto-approve -target=azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk -target=azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk -target=azurerm_managed_disk.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk -target=azurerm_virtual_machine_data_disk_attachment.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-0-data-disk-attachment -target=azurerm_virtual_machine_data_disk_attachment.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-1-data-disk-attachment -target=azurerm_virtual_machine_data_disk_attachment.$(PREFIX)-$(CLUSTER_NAME)-kubernetes-node-vm-2-data-disk-attachment -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate /shared/build/$(CLUSTER_NAME)/terraform/"
	echo "$$FIX_KUBELET" > $(ROOT_DIR)/run/shared/build/$(CLUSTER_NAME)/modify-kubelet.yml
	docker run --rm \
		-v $(ROOT_DIR)/run/shared:/shared \
		-it epiphanyplatform/epicli:1.2.0 \
		-c "ansible-playbook -i /shared/build/$(CLUSTER_NAME)/inventory /shared/build/$(CLUSTER_NAME)/modify-kubelet.yml"

sub-persistence:
	cp $(ROOT_DIR)/configurations/epi-1-2-rook-1-7-D2s-10G/rook-*.yaml $(ROOT_DIR)/run/shared/
	docker run --rm \
		-e KUBECONFIG=/shared/kubeconf \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t bitnami/kubectl:1.17.9 apply -f /shared/rook-crds.yaml --insecure-skip-tls-verify
	sleep 5
	docker run --rm \
		-e KUBECONFIG=/shared/kubeconf \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t bitnami/kubectl:1.17.9 apply -f /shared/rook-common.yaml --insecure-skip-tls-verify
	sleep 5
	docker run --rm \
		-e KUBECONFIG=/shared/kubeconf \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t bitnami/kubectl:1.17.9 apply -f /shared/rook-operator.yaml --insecure-skip-tls-verify
	sleep 5
	docker run --rm \
		-e KUBECONFIG=/shared/kubeconf \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t bitnami/kubectl:1.17.9 apply -f /shared/rook-cluster.yaml --insecure-skip-tls-verify
	sleep 5
	docker run --rm \
		-e KUBECONFIG=/shared/kubeconf \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t bitnami/kubectl:1.17.9 apply -f /shared/rook-sc.yaml --insecure-skip-tls-verify
	sleep 5
	docker run --rm \
		-e KUBECONFIG=/shared/kubeconf \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t bitnami/kubectl:1.17.9 apply -f /shared/rook-test-app.yaml --insecure-skip-tls-verify

sub-performance:
	cp $(ROOT_DIR)/configurations/epi-1-2-rook-1-7-D2s-10G/kbench.yaml $(ROOT_DIR)/run/shared/
	-docker run --rm \
		-e KUBECONFIG=/shared/kubeconf \
		-v $(ROOT_DIR)/run/shared:/shared \
		-w /shared \
		-t bitnami/kubectl:1.17.9 delete job kbench --insecure-skip-tls-verify
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
