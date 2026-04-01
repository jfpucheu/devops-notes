# Split your events (or other keys) into separate etcd clusters

Dans les gros clusters Kubernetes, les **events** peuvent rapidement devenir un problème. Bien qu'ils soient utiles pour le debugging et l'observabilité, ils génèrent un volume très important d'écritures dans etcd, ce qui peut **fortement dégrader les performances** du cluster etcd principal et donc impacter toute l'API Kubernetes.

---

## Problème

Dans Kubernetes, les events sont stockés dans etcd sous le préfixe `/registry/events`.
Dans les environnements à forte activité (beaucoup de pods, de déploiements, de controllers…), ce préfixe devient très sollicité :

- Écriture massive et continue
- Forte rotation des données (TTL court par défaut : 1h)
- Pression sur le stockage et le CPU etcd
- Compaction et defrag etcd plus fréquents

---

## Solution : externaliser certaines clés vers un etcd dédié

Kubernetes permet de **rediriger certaines clés vers un cluster etcd distinct** via le flag du kube-apiserver :

```
--etcd-servers-overrides
```

### Format

```
--etcd-servers-overrides=<prefix>#<server1>,<server2>,<server3>
```

> Les serveurs d'un même groupe sont séparés par des **virgules** (`,`).
> Plusieurs overrides sont séparés par des **virgules** (`,`) également.

### Exemple de configuration kube-apiserver

```yaml
# etcd principal
- --etcd-servers=https://10.0.0.11:2379,https://10.0.0.12:2379,https://10.0.0.13:2379
- --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
- --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
- --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key

# Externalisation des events vers un cluster etcd dédié
- --etcd-servers-overrides=/events#https://10.0.1.20:2379,https://10.0.1.21:2379,https://10.0.1.22:2379
```

---

## Avantages

- Réduction de la charge sur l'etcd principal
- Meilleures performances globales de l'API server
- Isolation des données très volatiles
- Scalabilité indépendante des deux clusters
- Cycles de compaction/defrag indépendants

---

## Limites et contraintes

### Authentification partagée

Le kube-apiserver utilise les **mêmes certificats TLS client** (`etcd-certfile` / `etcd-keyfile`) pour tous les clusters etcd, y compris les overrides. Il n'est pas possible de spécifier des certificats différents par cluster.

En pratique : les deux clusters etcd doivent être signés par la **même CA** et accepter le même certificat client du kube-apiserver.

### Disponibilité

Si l'etcd dédié aux events devient indisponible :

- Le kube-apiserver continue de tenter d'écrire/lire les events
- Les timeouts et retries impactent les performances globales
- L'etcd principal reste opérationnel, mais l'API server est dégradé

---

## Bonnes pratiques

- Déployer l'etcd events en haute disponibilité (minimum 3 nœuds)
- Monitorer séparément les deux clusters etcd
- Ajuster la rétention des events : `--event-ttl=1h` (valeur par défaut)
- Limiter les overrides aux clés très volatiles (events, leases…)
- Ne pas externaliser des clés critiques comme `/registry/pods` ou `/registry/secrets`

---

## Autres clés candidates

Au-delà des events, d'autres préfixes peuvent être externalisés selon les cas d'usage :

| Préfixe | Description |
|---|---|
| `/events` | Events Kubernetes (cas le plus courant) |
| `/leases` | Leader election et node heartbeats |
| `/pods` | Déconseillé — clé critique |

---

## Conclusion

Externaliser `/registry/events` dans un cluster etcd séparé est une optimisation efficace pour les gros clusters Kubernetes où les events deviennent un vrai bottleneck.

Cela doit être mis en place avec précaution : l'etcd dédié doit être hautement disponible, et les deux clusters doivent partager la même PKI.

> À utiliser principalement dans les environnements à très forte volumétrie, en production.
