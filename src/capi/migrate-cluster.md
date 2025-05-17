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
4. **Create the CAPI control-plane and CAPI worker nodes** on the existing cluster.
5. **Removing the nodes the old cluster nodes**.


## Prerequisites

- have a CAPI cluster CAPI Controller should have acces to the api url of the cluster to manage. (https://api.mylegacy_cluster.kubeadm)


## 1 - Retrieving the necessary secrets and configurations.

![](img/capi-secret.png)

First, run the [prepare_secrets.sh](https://github.com/jfpucheu/devops-notes/blob/main/src/capi/prepare_secrets.sh) script on a control plane node, passing the name of the cluster you want to migrate as an argument. This name should match the `cluster_name` defined in CAPI.
You can find the script [Here](https://github.com/jfpucheu/devops-notes/blob/main/src/capi/prepare_secrets.sh).

The script will generate a file named `${CLUSTER_NAME}-secret-bundle.yaml`.

```
./prepare_secrets.sh ${CLUSTER_NAME}
```

and get the file:  ${CLUSTER_NAME}-secret-bundle.yaml

## 2 - Preparing the Cluster API (CAPI) configuration.

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

Now, based on the 'cluster-template-migration.yaml', generate your cluster configuration, and pay **close attention to the following parameters**:

For the example, I hardcoded the parameters directly in the code, but it's recommended to pass these values **as cluster environment variables instead**.

- External etcd endpoints in KubeadmControlPlane section :

```
    ...
    clusterConfiguration:
      etcd:
        external:
          caFile: /etc/kubernetes/pki/etcd/ca.crt
          certFile: /etc/kubernetes/pki/apiserver-etcd-client.crt
          keyFile: /etc/kubernetes/pki/apiserver-etcd-client.key
          endpoints:
          - https://192.168.10.10:2379
          - https://192.168.10.11:2379
          - https://192.168.10.12:2379
    ...
```


- External Api endpoints in OpenStackCluster section if you use CAPO:

```
    ...
    controlPlaneEndpoint:
    host: api.mydevcluster.com
    port: 443
    ...
```
- Add a secutitygroup rule in OpenStackCluster section if you use CAPO to allow traffic beween old and new clusters:

```
  ...
  managedSecurityGroups:
    allNodesSecurityGroupRules:
    - direction: ingress
      etherType: IPv4
      name: Allow old secutirygroup
      description: "Allow all between old and new control plane and workers"
      remoteGroupID: "old-secutity-group-id"
  ...
```

## 3 - Importing the secrets into CAPI.

Apply your  `${CLUSTER_NAME}-secret-bundle.yaml` into you CAPI Controller Cluster:
```
kubectl apply -f ${CLUSTER_NAME}-secret-bundle.yaml
```

Now capi will detecte that a CA and secrets are already exxisting and will not generate a new one.

## 4 - Create the CAPI control-plane and CAPI worker nodes

![](img/capi-cp-migration.png)

```
# create capi  ${CLUSTER_NAME} cluster
envsubst <  cluster-template-migration.yaml | kubectl apply -f
```

Since the etcd database is shared between the old and new cluster, and the PKI secrets (such as TLS certificates and private keys) are identical, creating this new Kubernetes cluster will actually result in the addition of new control plane and CAPI worker nodes to the existing cluster, rather than forming a separate cluster.

**Get your cluster state:**

You will now see both your old control plane and worker nodes, as well as the new ones, in your cluster using `kubectl get nodes`.

![](img/capi-worker-migration.png)

In your CAPI cluster, running the clusterctl command will show only the new nodes that are managed by CAPI:

```
# Get  ${CLUSTER_NAME} cluster
clusterctl get cluster ${CLUSTER_NAME}

NAME                                                    READY  SEVERITY  REASON  SINCE  MESSAGE
Cluster/dev                                             True                     22h
├─ClusterInfrastructure - OpenStackCluster/dev
├─ControlPlane - KubeadmControlPlane/dev-control-plane  True                     22h
│ └─3 Machines...                                       True                     22h    See dev-control-plane-2xjv4, dev-control-plane-lrt8m, ...
└─Workers
  ├─MachineDeployment/dev-az1                           True                     22h
  │ └─Machine/dev-az1-z6zr4-9dldr                       True                     22h
  ├─MachineDeployment/dev-az2                           True                     22h
  │ └─Machine/dev-az2-nx55k-s265c                       True                     22h
  └─MachineDeployment/dev-az3                           True                     22h
    └─Machine/dev-az3-95fng-hsqfv                       True                     22h


```

## 5 - Remove the old cluster nodes

Make sure to update your load balancer (HAProxy or MetalLB) to include the new control plane nodes and remove the old ones.

![](img/capi-migrated.png)

Delete old nodes using:

```
# Delete old nodes
kubectl delete old-node 
```

Don’t forget to do the same for the old control plane nodes: stop containerd and kubelet to ensure that static pods are no longer running."
"And that’s it! You can now enjoy managing your cluster with CAPI 😊.