# capi-quick-start

The goal of this page is to provide quick commands to get started with Cluster API in under 5 minutes.
For more detailed information, please refer to the official Cluster API documentation at: https://cluster-api.sigs.k8s.io/

## Prerequisites:

### Install Kind

Install Kind following this [Link](../kind/kind-quick-start.md) or: 

```
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

### Install Kubectl


```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

```

## Install Cluster-Api

Create a Kind cluster with the kind config kind-cluster.yaml in this repo.
```
kind create cluster
```

### Install Clusterctl

Clusterctl is the client to deploy cluster with capi.

```
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.9.5/clusterctl-linux-amd64 -o clusterctl
sudo install -o root -g root -m 0755 clusterctl /usr/local/bin/clusterctl
clusterctl version
```

### Install CAPI and CAPO ( ClusterAPi for Opentack)

First export this variable to enable cluster-ressource-set feature:

```
export EXP_CLUSTER_RESOURCE_SET=true
```

Now we will install clusterAPI (capi)  and clusterApi Openstack Controller (capo) using clusterctl in our kind.

```
kubectl apply -f https://github.com/k-orc/openstack-resource-controller/releases/latest/download/install.yaml
clusterctl init --infrastructure openstack
```

Now your kind should look like:

```
ubuntu@jeff:~$ kubectl get pods -A | grep -v kube-system
NAMESPACE                           NAME                                                             READY   STATUS    RESTARTS        AGE
capi-kubeadm-bootstrap-system       capi-kubeadm-bootstrap-controller-manager-66bb86b8b8-d6jtb       1/1     Running   3 (20h ago)     5d17h
capi-kubeadm-control-plane-system   capi-kubeadm-control-plane-controller-manager-7bd59d5f69-bb69p   1/1     Running   2 (2d12h ago)   5d17h
capi-system                         capi-controller-manager-578674dd86-xhk7r                         1/1     Running   3 (20h ago)     5d17h
capo-system                         capo-controller-manager-79f47999df-w5p8k                         1/1     Running   3 (20h ago)     4d20h
cert-manager                        cert-manager-94d5c9976-pjw67                                     1/1     Running   2 (2d12h ago)   5d17h
cert-manager                        cert-manager-cainjector-6c49b5cdcc-bshqd                         1/1     Running   1 (2d12h ago)   5d17h
cert-manager                        cert-manager-webhook-595556d86b-zxm82                            1/1     Running   1 (2d12h ago)   5d17h
local-path-storage                  local-path-provisioner-7dc846544d-4tzbs                          1/1     Running   1 (2d12h ago)   5d18h
orc-system                          orc-controller-manager-df6c48588-mjdz5                           1/1     Running   3 (20h ago)     5d17h
```
