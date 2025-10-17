# 🧠 Essential Kubernetes Commands

## 🏗️ Kubernetes Cluster Commands
```bash
kubectl cluster-info              # Display cluster information
kubectl get nodes -o wide         # List all nodes in the cluster and show details
kubectl get crd                   # Display all CRD in cluster
kubectl api-versions              # Display Api version on the cluster
```

## 🧩 Kubernetes Pod Commands
```bash
kubectl get pods                        # List all pods
kubectl get pods -o wide                # Show detailed information about pods
kubectl get pods -l <label>=<value>     # List pods with a specific label
kubectl get pod <name>                  # Show one specific pod
kubectl describe pod <name>             # Show pod details
kubectl logs <pod>                      # View pod logs
kubectl exec -it <pod> -- /bin/sh     # Execute a command inside a pod
kubectl delete pod <name>               # Delete a pod
kubectl explain pod <resource>          # Display an overview of the Pod resource
```

## 🚀 Kubernetes Deployment Commands
```bash
kubectl create deployment <name> --image=<image>                # Create a deployment
kubectl get deployments                                         # List all deployments
kubectl describe deployment <name>                              # Show deployment details
kubectl scale deployment <name> --replicas=<number>             # Scale a deployment
kubectl rollout restart deployment/<name>                       # Restart a deployment
kubectl rollout status deployment/<name>                        # View deployment status
kubectl create deployment <name> --image=<image> -o yaml        # Create deployment and print YAML
kubectl create deployment <name> --image=<image> --dry-run=client -o yaml  # Generate YAML without applying
kubectl create deployment <name> --image=<image> -o yaml > name.yaml        # Store YAML into a file
```

## 🌐 Kubernetes Service Commands
```bash
kubectl get services                                            # List all services
kubectl describe service <name>                                 # Show service details
kubectl expose pod <name> --port=<port> --target-port=<target>  # Expose a pod as a service
kubectl delete service <name>                                   # Delete a service
kubectl port-forward <pod> <local-port>:<remote-port>           # Forward a local port to a pod
```

## 🔐 Kubernetes ConfigMap  Commands
```bash
kubectl create configmap <name> --from-literal=<key>=<value>   # Create a ConfigMap
kubectl create configmap my-config --from-file=path/to/bar     # Create a new config map named my-config based on folder bar
kubectl get configmaps                                          # List all ConfigMaps
kubectl describe configmap <name>                               # Show ConfigMap details
```

## 🔐 Kubernetes Secret Commands
```bash
kubectl create secret generic <name> --from-literal=<key>=<value>   # Create a Secret
kubectl get secrets                                                 # List all Secrets
kubectl get secret <name> -o yaml                                   # display a Secrets
```

## 🗂️ Kubernetes Namespace Commands
```bash
kubectl get namespaces                      # List all namespaces
kubectl create namespace <name>             # Create a namespace
kubectl delete namespace <name>             # Delete a namespace
kubectl config set-context --current --namespace=<name>   # Switch to a namespace
```

## 🧱 Kubernetes Resource Commands
```bash
kubectl get <type>                      # List resources of a specific type
kubectl apply -f <file>                 # Apply resource config file
kubectl edit <type> <name>              # Edit resource in terminal
kubectl delete -f <file>                # Delete resources from file
kubectl get <type>                      # List resources again (confirmation)
kubectl describe <type> <name>          # Show detailed info about a resource
```

## 📊 Kubernetes Statistics & Event Commands
```bash
kubectl get nodes                       # Display node resource usage
kubectl top nodes                       # Show node metrics (CPU/Memory)
kubectl top pods                        # Show pod metrics
kubectl get events                      # Display recent cluster events
```

## 🔑 Kubernetes Permissions
```bash
kubectl get Roles -n <namespace> 
kubectl get ClusterRole
kubectl get RoleBinding -n <namespace> # Display node usage
kubectl get ClusterRoleBinding  # Display node usage
kubectl get clusterroles system:discovery -o yaml
kubectl create role pod-reader --verb=get --verb=list --verb=watch --resource=pods #Create a Role named "pod-reader" that allows users to perform get, watch and list on pods:
# Check to see if service account "foo" of namespace "dev" can list pods in the namespace "prod"
# You must be allowed to use impersonation for the global option "--as"
kubectl auth can-i list pods --as=system:serviceaccount:dev:foo -n prod
```

