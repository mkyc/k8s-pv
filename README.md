# Overview
Test of Rook managed Ceph cluster setup on AKS

# Change prefix

in ./Makefile change `PREFIX:=mkyc` to `PREFIX:=your-prefix` and in file ./epiphany/azure/shared/azurerhel07.yml change `  prefix: 'mkyc'` to `  prefix: 'your-prefix'`. 

# Prepare service principal

Have a look [here](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html).

```
az login 
az account list #get subscription from id field
az account set --subscription="SUBSCRIPTION_ID"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID" #get appID, password, tenant, name and displayName
```

# Run terraform

```
make epi-certs
NAME="name field" DISPLAY_NAME="displayName field" make epi-init
ARM_CLIENT_ID="appId field" ARM_CLIENT_SECRET="password field" ARM_SUBSCRIPTION_ID="id field" ARM_TENANT_ID="tenant field" make epi-apply
ARM_CLIENT_ID="appId field" ARM_CLIENT_SECRET="password field" ARM_SUBSCRIPTION_ID="id field" ARM_TENANT_ID="tenant field" make epi-get-kube
ARM_CLIENT_ID="appId field" ARM_CLIENT_SECRET="password field" ARM_SUBSCRIPTION_ID="id field" ARM_TENANT_ID="tenant field" make epi-nsr #run this only once!
ARM_CLIENT_ID="appId field" ARM_CLIENT_SECRET="password field" ARM_SUBSCRIPTION_ID="id field" ARM_TENANT_ID="tenant field" make epi-disks
```

# Change kubelet flag

In case of Epiphany Cluster, it is necessary to change one flag in kubelet configuration on every worker node in order to enable the attach/detach capability for the kubelet service: 
from: `enable-controller-attach-detach=false` to `enable-controller-attach-detach=true` 
after that You have to restart kubelet service: `sudo systemctl restart kubelet`

# Add Rook

```
make get-nodes
make rook-setup #wait for operator initialization
make rook-cluster
make rook-storage
make rook-test
```
# Upgrade Rook from 1.3 version to 1.4 version

```
make rook-upgrade-privilages
make rook-upgrade-operator #wait for operator and cluster upgrade, may take up to 5 minutes
```

# Resources

Used: 
* [this issue](https://github.com/epiphany-platform/epiphany/issues/1441) [related PR](https://github.com/epiphany-platform/epiphany/pull/1551) results for terraform part. 