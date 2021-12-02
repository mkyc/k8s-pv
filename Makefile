ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PREFIX:=mkyc1201
SUBSCRIPTION_NAME = PGGA-Epiphany-Dev

-include ./service-principal.mk
export

CONFIGURATION:=epi-1-2-rook-1-7-D2s-10G

-include ./configurations/$(CONFIGURATION)/makefile.mk
export

# run following steps in order
init: sub-init
apply1: sub-apply1
apply2: sub-apply2
persistence: sub-persistence
# wait some time to cluster to stabilize before running tests
performance: sub-performance
# run following to remove previously created cluster
nuke: sub-nuke

#rook-toolbox-task:
#	docker run --rm \
#		-e KUBECONFIG=/rook/kubeconf \
#		-v $(ROOT_DIR)/rook:/rook \
#		-w /rook \
#		-t bitnami/kubectl:1.17.9 apply -f /rook/rook-$(CLUSTER_VERSION)/rook-toolbox-$(CLUSTER_VERSION).yaml --insecure-skip-tls-verify
