# Debug Kubernetes

## Test DNS 

Test Cluster Dns using busybox pod:

``` {.console}
kubectl exec -it busybox -n <NAMESPACE> -- nslookup kubernetes.default
```
