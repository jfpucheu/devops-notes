## Create your first Cluster CAPI

**Manual step: ClusterIP**

For the moment we don't have LBAAS on Openstack for Api-Servers
Workaround: Create a port manualy on prod network on openstack console it will be your CLUSTER_API_IP

### Prepare env vars for your cluster.

**Manual step: secret cloud.yaml**

Based on the file cloud.yaml , create your encoded secret cloud.yaml in base64.

```
export OPENSTACK_CLOUD_YAML_B64=$(cat cloud.yaml | base64)

# apply the secret in your kind (run once )
envsubst < secret.yaml | kubectl apply -f -
```

based on env_cos_mutu file create vars file for your cluster and source it:

```
source env_mutu_svc
```

Create Calico CRS deployment for your futur clusters:

```
# create crs
envsubst <  crs/crs-calico.yaml | kubectl apply -f - 
```

### Now create your first cluster:

**Create cluster command:**
```
# create env_mutu cluster
envsubst <  cluster-template-without-lb.yaml | kubectl apply -f -
```

When master are available, connect on SSH on one and go on /var/log/cloud-init-output.log.
Copy/Past the configuration to configure the kubeconfig file and be able to use kubectl on this master.

````
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
````

or 

````
export KUBECONFIG=/etc/kubernetes/admin.conf
````

** Check your cluster status using clusterctl **:

clusterctl describe cluster dev

````
NAME                                                    READY  SEVERITY  REASON  SINCE  MESSAGE
Cluster/dev                                             True                     18h
├─ClusterInfrastructure - OpenStackCluster/dev
├─ControlPlane - KubeadmControlPlane/dev-control-plane  True                     18h
│ └─3 Machines...                                       True                     18h    See dev-control-plane-5djm7, dev-control-plane-tgs4l, ...
└─Workers
  └─MachineDeployment/dev-md-0                          True                     18h
    └─6 Machines...                                     True                     18h    See dev-md-0-9bh9b-89mq9, dev-md-0-9bh9b-95k5n, ...
````


**Delete cluster command:**
```
# create env_mutu cluster
envsubst <  cluster-template-kubevip.yaml | kubectl delete -f -
```


## Clean Capi in your Kind:

```
kubectl delete cluster mycluster -n namespace
```

```
clusterctl delete  --core cluster-api -b kubeadm -c kubeadm -i openstack
```

## Upgrade Components:**
```
clusterctl upgrade plan
```

```
clusterctl upgrade apply --contract v1beta1

```

## Notes :
### creation d'un autre cluster dans kind

clusterctl generate cluster capi-quickstart --flavor development \
  --kubernetes-version v1.32.0 \
  --control-plane-machine-count=1 \
  --worker-machine-count=1 \
  --infrastructure docker \
  > capi-quickstart.yaml