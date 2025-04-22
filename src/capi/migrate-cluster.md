# Migrate a legacy K8s Kubeadm Cluster to a Capi K8s kubadm Cluster 

Currently, this procedure is in an experimental stage and should be thoroughly tested before being used in a production environment.
It is only compatible with an external ETCD and an external LBAAS.

It is designed create cluster.x-k8s.io/secret bundle to migrate a cluster created with kubeadm to a kubeadm-based cluster managed by Cluster API.
At this stage, the script has been developed specifically for the Cluster API Provider OpenStack (CAPO ).

My goal is to improve the process to transition from an external ETCD to a local ETCD on the control-plane nodes, and also to migrate from a local ETCD on legacy control-planes to a local ETCD on CAPI control-planes.

The key to this, based on my analysis, would be to force CAPI to add the first control-plane node using a kubeadm join instead of a kubeadm init.

In the case of an external ETCD, this works because the secrets and ETCD are already initialized. The kubeadm init command does not pose any issues, as the kubelet simply joins an already existing API endpoint.

Feel free to share any suggestions or ideas for improvements or future developments.


# Migration Process Overview

The procedure is based on having a hybrid legacy/CAPI cluster during the migration.

It is carried out in five main steps:

1. **Retrieving the necessary secrets and configurations** from the existing cluster.
2. **Preparing the Cluster API (CAPI) configuration**.
3. **Importing the secrets into CAPI**.
4. **Adding the CAPI control-plane and worker nodes** to the existing cluster.
5. **Removing the nodes from the old cluster**.


## Prerequisites

The CAPI Controller should have acces to the api url of the cluster to manage. (https://api.mylegacy_cluster.kubeadm)


### Extract secret and CA of your cluster.

![](img/capi-secret.png)

First, run the `prepare_secrets.sh` script on a control plane node, passing the name of the cluster you want to migrate as an argument. This name should match the `cluster_name` defined in CAPI.
The script will generate a file named `${CLUSTER_NAME}-secret-bundle.yaml`.

```
./prepare_secrets.sh ${CLUSTER_NAME}
```
and get the file:  ${CLUSTER_NAME}-secret-bundle.yaml

### Prepare env vars for your cluster.

**Manual step: secret cloud.yaml**

Based on the file cloud.yaml , create your encoded secret cloud.yaml in base64.

```
export OPENSTACK_CLOUD_YAML_B64=$(cat cloud.yaml | base64)

# apply the secret in your Cluster-api cluster (run once )
envsubst < secret.yaml | kubectl apply -f -
```

based on env_example file create vars file for your cluster and source it:

```
source env_example
```

## Migrate your cluster


**Migrate cluster command:**
```
# import secret bundle
kubectl apply -f ${CLUSTER_NAME}-secret-bundle.yaml

# Migrate  ${CLUSTER_NAME} cluster
envsubst <  cluster-template-migration.yaml | kubectl apply -f
```

**Get your cluster state:**
```
# import secret bundle
kubectl apply -f ${CLUSTER_NAME}-secret-bundle.yaml -n $NAMESPACE

# Migrate  ${CLUSTER_NAME} cluster
envsubst <  cluster-template-migration.yaml | kubectl apply -n $NAMESPACE -f
```