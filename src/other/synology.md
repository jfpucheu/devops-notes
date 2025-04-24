# Synology

### Enable L2TP/IPsec Logs as debug:

```
vim /var/packages/VPNCenter/etc/l2tp/ipsec.conf
```

add or uncomment this parameters:
```
config setup
...
    plutodebug=all
    plutostderrlog=/var/log/pluto.log
```

Allow UDP 500, 1701 et 4500 on the NAS, don't NAT/transfert 1701 on router.
