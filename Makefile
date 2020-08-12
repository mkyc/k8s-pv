ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PREFIX:=mkyc

gen-certs: gen-certs-task
init: init-task
plan: plan-task
apply: apply-task
get-kubeconf: get-kubeconfig-task
destroy: destroy-task


gen-certs-task:
	ssh-keygen -t rsa -b 4096 -f $(ROOT_DIR)/terraform/azure_rsa -N '' <<<y 2>&1 >/dev/null

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
