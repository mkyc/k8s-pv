ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PREFIX:=mkyc1206
SUBSCRIPTION_NAME = PGGA-Epiphany-Dev

#CONFIGURATION:=epi-1-2-rook-1-7-D2s-10G
#CONFIGURATION:=epi-1-2-rook-1-7-D2s-520G
CONFIGURATION:=epi-1-2-rook-1-7-D8s-520G

-include ./service-principal.mk
export

-include ./configurations/$(CONFIGURATION)/makefile.mk
export

# run following steps in order
init: sub-init
apply1: sub-apply1
apply2: sub-apply2
persistence: sub-persistence
# wait some time to cluster to stabilize before running tests (at least 10 minutes, but longer is better)
performance: sub-performance
# collect results with `kubectl logs -l kbench=fio -f`

# run following to remove previously created cluster
nuke: sub-nuke
