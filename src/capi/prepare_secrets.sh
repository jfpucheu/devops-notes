#!/bin/bash

# This script is currently in an experimental stage and should be thoroughly tested before being used in a production environment.
# It is designed create cluster.x-k8s.io/secret bundle to migrate a cluster created with kubeadm to a kubeadm-based cluster managed by Cluster API.
# At this stage, the script has been developed specifically for the Cluster API Provider OpenStack (CAPO).
# Feel free to share any suggestions or ideas for improvements or future developments.

# Prerequisites: install yq
# Linux
# sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
# sudo chmod +x /usr/local/bin/yq

# macOS
# brew install yq


# Check if an argument was passed
if [ -z "$1" ]; then
  echo "Error: no cluster name provided."
  echo "Usage: $0 <cluster-name>"
  exit 1
fi

# Assign the cluster name to a variable
CLUSTER_NAME="$1"

echo "Cluster name: $CLUSTER_NAME"

# Create a new secret named my-secret with specified keys instead of names on disk

kubectl create secret tls ${CLUSTER_NAME}-ca  --cert=/etc/kubernetes/pki/ca.crt  --key=/etc/kubernetes/pki/ca.key --dry-run=client -o yaml >  ${CLUSTER_NAME}-secret-bundle.yaml
echo "---" >>  ${CLUSTER_NAME}-secret-bundle.yaml

#kubectl create secret tls ${CLUSTER_NAME}-etcd  --cert=/etc/kubernetes/pki/etcd/ca.crt  --key=/etc/kubernetes/pki/etcd/ca.key --dry-run=client -o yaml >>  ${CLUSTER_NAME}-secret-bundle.yaml
kubectl create secret tls ${CLUSTER_NAME}-etcd --cert=/etc/kubernetes/pki/etcd/ca.crt  --key=/etc/kubernetes/pki/etcd/ca.key --dry-run=client -o yaml >>  ${CLUSTER_NAME}-secret-bundle.yaml
echo "---" >>  ${CLUSTER_NAME}-secret-bundle.yaml

if [ ! -f "/etc/kubernetes/pki/apiserver-etcd-client.crt" ]; then
# Create etcd cert files if apiserver-etcd-client is not present in the clusters.
    openssl genrsa -out apiserver-etcd-client.key 2048
    openssl req -new -key apiserver-etcd-client.key -out apiserver-etcd-client.csr -subj "/CN=kube-apiserver-etcd-client"
    openssl x509 -req -in apiserver-etcd-client.csr -CA /etc/kubernetes/pki/etcd/ca.crt -CAkey /etc/kubernetes/pki/etcd/ca.key -CAcreateserial -extensions v3_ext -out apiserver-etcd-client.crt -days 365 -sha256
fi

kubectl create secret tls ${CLUSTER_NAME}-apiserver-etcd-client --cert apiserver-etcd-client.crt --key apiserver-etcd-client.key --dry-run=client -o yaml >>  ${CLUSTER_NAME}-secret-bundle.yaml
# I have to check because kubeadm seams to not want to manage the renew of this certificats ${CLUSTER_NAME}-apiserver-etcd-client
echo "---" >>  ${CLUSTER_NAME}-secret-bundle.yaml

kubectl create secret tls ${CLUSTER_NAME}-proxy   --cert=/etc/kubernetes/pki/front-proxy-ca.crt  --key=/etc/kubernetes/pki/front-proxy-ca.key --dry-run=client -o yaml >>  ${CLUSTER_NAME}-secret-bundle.yaml
echo "---" >>  ${CLUSTER_NAME}-secret-bundle.yaml

kubectl create secret generic  ${CLUSTER_NAME}-sa   --from-file=tls.crt=/etc/kubernetes/pki/sa.pub --from-file=tls.key=/etc/kubernetes/pki/sa.key  --dry-run=client -o yaml >>  ${CLUSTER_NAME}-secret-bundle.yaml
echo 'type: cluster.x-k8s.io/secret' >> ${CLUSTER_NAME}-secret-bundle.yaml

echo "---" >>  ${CLUSTER_NAME}-secret-bundle.yaml

# il y a une modification a prevoir dans le secret kubeconfig, 
# il faut que :

# cluter.name: ${CLUSTER_NAME} 
# context.cluster: ${CLUSTER_NAME} 
# context.user:  ${CLUSTER_NAME}-admin
# context.name: ${CLUSTER_NAME}-admin@${CLUSTER_NAME}
# users.name: ${CLUSTER_NAME}-admin
#
# Full example:
#
#apiVersion: v1
#clusters:
#- cluster:
#    certificate-authority-data: =
#    server: https://127.0.0.1:6443
#  name: ${CLUSTER_NAME}
#contexts:
#- context:
#    cluster: ${CLUSTER_NAME}
#    user: ${CLUSTER_NAME}-admin
#  name: ${CLUSTER_NAME}-admin@${CLUSTER_NAME}
#current-context: ${CLUSTER_NAME}-admin@${CLUSTER_NAME}
#kind: Config
#preferences: {}
#users:
#- name: ${CLUSTER_NAME}-admin
#  user:
#    client-certificate-data: =
#    client-key-data: 

cp /root/config /tmp/config

yq eval ".clusters[0].name = \"$CLUSTER_NAME\"" -i /tmp/config
yq eval ".contexts[0].context.cluster = \"$CLUSTER_NAME\"" -i /tmp/config
yq eval ".contexts[0].context.user = \"$CLUSTER_NAME-admin\"" -i /tmp/config
yq eval ".contexts[0].name = \"$CLUSTER_NAME-admin@$CLUSTER_NAME\"" -i /tmp/config
yq eval ".current-context = \"$CLUSTER_NAME-admin@$CLUSTER_NAME\"" -i /tmp/config
yq eval ".users[0].name = \"$CLUSTER_NAME-admin\"" -i /tmp/config


kubectl create secret generic  ${CLUSTER_NAME}-kubeconfig   --from-file=value=/tmp/config --dry-run=client -o yaml >>  ${CLUSTER_NAME}-secret-bundle.yaml
echo 'type: cluster.x-k8s.io/secret' >> ${CLUSTER_NAME}-secret-bundle.yaml

sed -i 's/type: kubernetes.io\/tls/type: cluster.x-k8s.io\/secret/g' ${CLUSTER_NAME}-secret-bundle.yaml


# Labels to add after a specific line (for example, after 'metadata:')"
labels="  labels:\n    cluster.x-k8s.io/cluster-name: ${CLUSTER_NAME}"
sed -i '/metadata:/a\'"$labels" "${CLUSTER_NAME}-secret-bundle.yaml"

## to rework:
key=$(cat /etc/kubernetes/pki/secrets.yaml | grep "secret:" | awk -F ":" '{ $3 = "" ; print $2 }')
echo -e "\nDon't Forget to export Encryption key:"
echo "export KUBERNETES_ENCRYPTION_SECRET=$key"

## A retravailler le but etant d' afficher les valeurs des IPs ETCDs.
etcd=$(cat /etc/kubernetes/manifests/kube-apiserver.yaml  | grep "etcd-servers")
echo -e  "\nEtcd endpoints to export: $etcd"