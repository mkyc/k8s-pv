# Overview

This repo tests Rook managed Ceph cluster setup on Azure in various configurations. 

If you want to run it yourselves please refer to section [Makefile parameters](#makefile-parameters). 
If you just want to see results summarized from runs performed in scope of this research please refer to [Performance tests results](./performance-tests-results.md) file. 

# Makefile parameters

All parameters required to run tests are managed in [Makefile](./Makefile). There are following parameters: 
 - `PREFIX` used to add some prefix to resources created in Azure (i.e., to let know others in subscription that this is yours use your initials here).
 - `SUBSCRIPTION_NAME` used to provide name (not identifier!) of your subscription.
 - `CONFIGURATION` field used to point script to chosen scenario from [configurations](./configurations) directory. 
 
# REVIEW Prepare service principal

Have a look [here](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html).

```
az login 
az account list #get subscription from id field
az account set --subscription="SUBSCRIPTION_ID"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID" #get appID, password, tenant, name and displayName
```

# REVIEW Backup / Restore

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
