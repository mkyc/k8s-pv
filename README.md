# aks-rook-ceph
test of Rook managed Ceph cluster setup on AKS

# Prepare service principal

Have a look [here](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html).

```
az login 
az account list #get subscription from id field
az account set --subscription="SUBSCRIPTION_ID"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID" #get appID, password and tenant
```

# Run terraform

```
make epi-certs
make epi-init
ARM_CLIENT_ID="appId field" ARM_CLIENT_SECRET="password field" ARM_SUBSCRIPTION_ID="id field" ARM_TENANT_ID="tenant field" make epi-apply
ARM_CLIENT_ID="appId field" ARM_CLIENT_SECRET="password field" ARM_SUBSCRIPTION_ID="id field" ARM_TENANT_ID="tenant field" make epi-get-kube
ARM_CLIENT_ID="appId field" ARM_CLIENT_SECRET="password field" ARM_SUBSCRIPTION_ID="id field" ARM_TENANT_ID="tenant field" make epi-nsr #run this only once!
ARM_CLIENT_ID="appId field" ARM_CLIENT_SECRET="password field" ARM_SUBSCRIPTION_ID="id field" ARM_TENANT_ID="tenant field" make epi-disks
```

TODO: I believe there is some manual kublet step required here. 

# Add Rook

```
make get-nodes
make rook-setup #wait for operator initialization
make rook-cluster
make rook-storage
make rook-test
```

# Resources

Used: 
* [this issue](https://github.com/epiphany-platform/epiphany/issues/1441) [related PR](https://github.com/epiphany-platform/epiphany/pull/1551) results for terraform part. 