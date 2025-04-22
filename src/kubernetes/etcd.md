# etcd

## Database space exceeded

`failed to update node lease, error: etcdserver: mvcc: database space exceeded`

The Etcd cluster has gone into a limited operation maintenance mode,
meaning that it will only accept key reads and deletes.

**Possible Solution**

History compaction needs to occur :

```bash
$ export ETCDCTL_API=3
$ etcdctl alarm list
$ etcdctl endpoint status --write-out="json" | egrep -o '"revision":[0-9]*' | egrep -o '[0-9]*'
143862581
$ etcdctl compact 143862581
$ etcdctl defrag
$ etcdctl alarm disarm
```

This operation should be done on each etcd cluster node.

## Api Crashed and etcd slowness

Most of time this issue is due to a busy etcd database due to too many objects (like events) or network slowness.
In this case you can see on grafana a lot of etcd leader changes.
Too many Events/jobs can be caused by a cronjob running in loop pods which are looping in error also.

**Possible Solution**

Give Disk priority to etcd:

An etcd cluster is very sensitive to disk latencies. Since etcd must persist proposals to its log, disk activity from other processes may cause long fsync latencies. The upshot is etcd may miss heartbeats, causing request timeouts and temporary leader loss. An etcd server can sometimes stably run alongside these processes when given a high disk priority.

On Linux, etcd’s disk priority can be configured with ionice:

```bash
# best effort, highest priority
sudo ionice -c2 -n0 -p `pgrep etcd
```

Count the number of events in etcd database.

```bash
ETCDCTL_API=3 etcdctl get /registry --prefix --keys-only | grep /registry/events | cut -d'/' -f4 | uniq -c| sort -nr
```

Identify the namespace wich is causing to many events and try to purge them with kubectl

```bash
kubectl delete events --all -n <NAMESPACE>
```

If the api crashed it could be complicated to clean events with kubectl. In this case you can clean events directly in etcd database.

``` bash
ETCDCTL_API=3 etcdctl del /registry/events/<NAMESPACE> --prefix
```

Compact ETCD database on each master nodes to free space.

```bash
$ export ETCDCTL_API=3
$ etcdctl endpoint status --write-out="json" | egrep -o '"revision":[0-9]*' | egrep -o '[0-9]*'
143862581
$ etcdctl compact 143862581
$ etcdctl defrag
```

Give time to etcd to resync all nodes.

Finally, check job and cronjob wich are creating to many events and stop them (for cronjob) and delete jobs.
