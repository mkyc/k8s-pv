ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PREFIX:=mkyc1201

-include ./service-principal.mk
export

CONFIGURATION:=epi-1-2-rook-1-7-D2s-10G

-include ./configurations/$(CONFIGURATION)/makefile.mk
export

init: sub-init
apply1: sub-apply1
apply2: sub-apply2
pl: sub-pl

#rook-storage: rook-storage-class-task
## setup end
#
## tools begin
#get-nodes: kube-get-nodes-task
#epi-nuke: destroy-task
## tools end
#
## tests begin
#rook-test: rook-test-app-task
#rook-performance: rook-performance-test-task
## tests end
#
#
#
#
#
#
#destroy-task:
#	rm -f $(ROOT_DIR)/rook/kubeconf
#	docker run --rm \
#		-e ARM_CLIENT_ID="${ARM_CLIENT_ID}" \
#		-e ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}" \
#		-e ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
#		-e ARM_TENANT_ID="${ARM_TENANT_ID}" \
#		-v $(ROOT_DIR)/epiphany/azure/shared:/shared \
#		-w /shared \
#		-t epiphanyplatform/epicli:1.2.0 -c "terraform destroy -auto-approve -state=/shared/build/$(CLUSTER_NAME)/terraform/terraform.tfstate /shared/build/$(CLUSTER_NAME)/terraform/"
#
#
#rook-toolbox-task:
#	docker run --rm \
#		-e KUBECONFIG=/rook/kubeconf \
#		-v $(ROOT_DIR)/rook:/rook \
#		-w /rook \
#		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-$(CLUSTER_VERSION)/rook-toolbox-$(CLUSTER_VERSION).yaml --insecure-skip-tls-verify
#
#rook-storage-class-task:
#	docker run --rm \
#		-e KUBECONFIG=/rook/kubeconf \
#		-v $(ROOT_DIR)/rook:/rook \
#		-w /rook \
#		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-$(CLUSTER_VERSION)/rook-sc-$(CLUSTER_VERSION).yaml --insecure-skip-tls-verify
#
#rook-test-app-task:
#	docker run --rm \
#		-e KUBECONFIG=/rook/kubeconf \
#		-v $(ROOT_DIR)/rook:/rook \
#		-w /rook \
#		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-$(CLUSTER_VERSION)/rook-test-app-$(CLUSTER_VERSION).yaml --insecure-skip-tls-verify
#
#rook-performance-test-task:
#	cp $(ROOT_DIR)/rook/kubeconf $(ROOT_DIR)/tests/kubeconf
#	docker run --rm \
#		-e KUBECONFIG=/tests/kubeconf \
#		-v $(ROOT_DIR)/tests:/tests \
#		-w /tests \
#		-t bitnami/kubectl:1.17.9 apply -f /tests/performance/kbench.yaml --insecure-skip-tls-verify
