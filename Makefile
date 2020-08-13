ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PREFIX:=mkyc
CLUSTER_NAME:=azurerhel07

epi-certs: gen-certs-task

epi-init: epicli-init
epi-apply: epicli-apply
epi-delete: epicli-delete
epi-get-kube: epicli-get-output-task epicli-get-kubeconf-task

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

epicli-get-kubeconf-task:
	$(eval MASTER_IP=$(shell sh -c "cat $(ROOT_DIR)/epiphany/azure/shared/build/out.json | docker run --rm -i imega/jq -cr .ip_address"))
	ssh -oStrictHostKeyChecking=no -i $(ROOT_DIR)/epiphany/azure/shared/azure_rsa operations@$(MASTER_IP) "sudo cp /etc/kubernetes/admin.conf /home/operations/kconf && sudo chmod 644 /home/operations/kconf"
	scp -oStrictHostKeyChecking=no -i $(ROOT_DIR)/epiphany/azure/shared/azure_rsa operations@$(MASTER_IP):/home/operations/kconf $(ROOT_DIR)/rook/kubeconf


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
		-t bitnami/kubectl:1.17.9 get nodes

rook-common-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-common-1.4.yaml

rook-operator-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-operator-1.4.yaml

rook-cluster-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-cluster-1.4.yaml

rook-toolbox-task:
	docker run --rm \
		-e KUBECONFIG=/rook/kubeconf \
		-v $(ROOT_DIR)/rook:/rook \
		-w /rook \
		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-toolbox-1.4.yaml
