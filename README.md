# aks-rook-ceph
test of Rook managed Ceph cluster setup on AKS

# Prepare service principal

```
az login #get id field
az ad sp create-for-rbac --subscription="00000000-0000-0000-0000-000000000000" --role="Contributor" --scopes="/subscriptions/2d60775f-932a-4cf6-b9f0-548a8b43b368" #get appID, password and tenant
```

# Run terraform

```
make gen-certs
make init
ARM_CLIENT_ID="appId field" ARM_CLIENT_SECRET="password field" ARM_SUBSCRIPTION_ID="id field" ARM_TENANT_ID="tenant field" make plan
ARM_CLIENT_ID="appId field" ARM_CLIENT_SECRET="password field" ARM_SUBSCRIPTION_ID="id field" ARM_TENANT_ID="tenant field" make apply
make get-kubeconf
```

# Add Rook

```
make get-nodes
make rook-setup
```

# Resources

Used: 
* [this issue](https://github.com/epiphany-platform/epiphany/issues/1441) [related PR](https://github.com/epiphany-platform/epiphany/pull/1551) results for terraform part. 