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
ARM_CLIENT_ID="appId field" ARM_CLIENT_SECRET="password field" ARM_SUBSCRIPTION_ID="id field" ARM_TENANT_ID="tenant field" NAME="name field" DISPLAY_NAME="displayName field" make epi-init
ARM_CLIENT_ID="appId field" ARM_CLIENT_SECRET="password field" ARM_SUBSCRIPTION_ID="id field" ARM_TENANT_ID="tenant field" make epi-apply
ARM_CLIENT_ID="appId field" ARM_CLIENT_SECRET="password field" ARM_SUBSCRIPTION_ID="id field" ARM_TENANT_ID="tenant field" make epi-get-kube
ARM_CLIENT_ID="appId field" ARM_CLIENT_SECRET="password field" ARM_SUBSCRIPTION_ID="id field" ARM_TENANT_ID="tenant field" make epi-nsr #run this only once!
ARM_CLIENT_ID="appId field" ARM_CLIENT_SECRET="password field" ARM_SUBSCRIPTION_ID="id field" ARM_TENANT_ID="tenant field" make epi-disks
```

# Change kubelet flag

In case of Epiphany Cluster, it is necessary to change one flag in kubelet configuration on every worker node in order to enable the attach/detach capability for the kubelet service: 
from: `enable-controller-attach-detach=false` to `enable-controller-attach-detach=true` in the following file: `/var/lib/kubelet/kubeadm-flags.env`
after that You have to restart kubelet service: `sudo systemctl restart kubelet`

# Add Rook

```
make get-nodes
make rook-setup #wait for operator initialization
make rook-cluster
make rook-storage
make rook-test
```

# Backup / Restore

Create toolbox pod with rbd tools installed:

```
make rook-toolbox-task
```

SSH to kubernetes master node or use `make epi-get-kube` to get k8s config file in `./rook/kubeconf`


Create a file in PVC mounted location in app wordpress:

```
kubectl exec -it $(kubectl get pod -l "app=wordpress" -o jsonpath='{.items[0].metadata.name}') -- touch /var/www/html/test1 
```

Get poolname
```
kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph  get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') -- rados lspools
```

Get volume name 
```
kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph  get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') -- rbd ls replicapool
```

Create snapshot 
```
kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph  get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') -- rbd snap create replicapool/csi-vol-365399b7-e79e-11ea-a8cc-66630cbb1481@test1-snapshot
```

Remove previously created file before snapshot
```
kubectl exec -it $(kubectl get pod -l "app=wordpress" -o jsonpath='{.items[0].metadata.name}') -- rm /var/www/html/test1 
```

Scale down application
```
kubectl scale --replicas=0 deployment/wordpress
```

Rollback from snapshot 
```
kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph  get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') -- rbd snap rollback replicapool/csi-vol-365399b7-e79e-11ea-a8cc-66630cbb1481@test1-snapshot
```
Expected result:
```
1ea-a8cc-66630cbb1481@test1-snapshot
Rolling back to snapshot: 100% complete...done.
```

Scale up application
```
kubectl scale --replicas=1 deployment/wordpress
```

Check if the file is present again
```
kubectl exec -it $(kubectl get pod -l "app=wordpress" -o jsonpath='{.items[0].metadata.name}') -- ls /var/www/html/test1 
```


# Upgrade Rook from 1.3 version to 1.4 version

```
make rook-upgrade-privilages
make rook-upgrade-operator #wait for operator and cluster upgrade, may take up to 5 minutes
```

# Resources

Used: 
* [this issue](https://github.com/epiphany-platform/epiphany/issues/1441) [related PR](https://github.com/epiphany-platform/epiphany/pull/1551) results for terraform part. 
