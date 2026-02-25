# LavinMQ Operator Deployment on Kubernetes

---

## 1. Architecture Overview

- LavinMQ Operator

- LavinMQ cluster (custom resource)

- etcd backend

- persistent storage

- cert-manager (for TLS & webhook certificates)

---

## 2. Prerequisites

- Kubernetes cluster 

- Helm installed

- Cluster-admin access

- NFS server (if using NFS storage)

Verify cluster:

```bash
kubectl get nodes
```
---

## 3. Install cert-manager
The LavinMQ operator depends on cert-manager for certificate management.
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```
Verify installation:
```bash
kubectl get pods -n cert-manager
```
All pods should be in Running state before proceeding.

---

## 4. Install NFS Provisioner (If Using NFS Storage)
4.1. Create Base Chart with helm create

```bash
helm create nfs-provisioner
cd nfs-provisioner
Result: Creates full scaffold:

```

```bash
nfs-provisioner/
├── Chart.yaml
├── values.yaml  
├── templates/
├── charts/          ← We'll use this!
└── .helmignore

```

4.2. Replace Chart.yaml 
```bash
cat > Chart.yaml << 'EOF'
apiVersion: v2
name: nfs-provisioner
description: NFS storage provisioner with multiple StorageClasses
type: application
version: 1.0.0

dependencies:
  - name: nfs-subdir-external-provisioner
    version: "4.0.18"
    repository: https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
    alias: nfs-lavinmq-etcd                # ← etcd provisioner

  - name: nfs-subdir-external-provisioner
    version: "4.0.18"
    repository: https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
    alias: nfs-lavinmq                     # ← lavinmq provisioner
EOF

```

4.3. Replace values.yaml
```bash
cat > values.yaml << 'EOF'
# NFS provisioner for etcd
nfs-lavinmq-etcd:
  nfs:
    server: nfs.agentcisinteral.com
    path: /agentcis-pvc/helm-test/lavinmq-etcd-data
  storageClass:
    name: nfs-client-etcd
    reclaimPolicy: Retain
    archiveOnDelete: "false"

# NFS provisioner for lavinmq
nfs-lavinmq:
  nfs:
    server: nfs.agentcisinteral.com
    path: /agentcis-pvc/helm-test/lavinmq-data
  storageClass:
    name: nfs-client-lavinmq
    reclaimPolicy: Retain
    archiveOnDelete: "false"
EOF

```

4.4. Clean Up Templates (Umbrella Chart = No Templates)
```bash
rm -rf templates/ crds/ charts/ *.tgz

```

4.5. Update Dependencies (Downloads 2x Subcharts)
```bash
helm dependency update

```

Expected Output:
Install Complete!
Saving  charts
Deleting outdated charts

Result: charts/ 
contains:  nfs-subdir-external-provisioner-4.0.18.tgz


4.6. Validate and Deploy Chart 
```bash
kubectl create namespace nfs-provisioner

# Template render (see generated manifests)
helm template nfs-provisioner ./nfs-provisioner

helm install nfs-provisioner ./nfs-provisioner \
  --namespace nfs-provisioner \
  --dry-run --debug

helm install nfs-provisioner ./nfs-provisioner -n nfs-provisioner
```

4.7. Verify in the server
```bash
# StorageClasses created
kubectl get storageclass | grep nfs-client
# nfs-client-etcd
# nfs-client-lavinmq

# Deployments running
kubectl get deployments -n nfs-provisioner
# nfs-lavinmq-etcd
# nfs-lavinmq
```

Ensure nfs-client appears.

---


## 5. Install LavinMQ Operator using the official release 
```bash
kubectl apply -f https://github.com/cloudamqp/lavinmq-operator/releases/download/0.2.0/install.yaml
```

Verify Operator Installation
```bash
# Verify the Operator Pods
kubectl get pods -n lavinmq-operator-system

#Verify the Custom Resource Definitions (CRDs)
kubectl get crds | grep lavinmq

```
All operator pods must be in Running state.

---


## 6. Install etcd Backend
LavinMQ depends on etcd for metadata storage.
We deploy etcd using the Bitnami Helm chart from Docker Hub:

lavinmq-etcd-values.yaml
```bash
replicaCount: 1

auth:
  rbac:
    create: false
  token:
    enabled: false

image:
  registry: docker.io
  repository: bitnamilegacy/etcd
  tag: 3.6.4-debian-12-r3

service:
  type: ClusterIP

persistence:
  enabled: true
  # UPDATE: Match the StorageClass name created by your NFS-infra
  storageClass: "nfs-client-etcd"   
  accessModes:
    - ReadWriteOnce
  size: 10Gi
  # NOTE: nfsPath is removed because the Provisioner handles the 
  # directory creation automatically based on its own config.

resources:
  limits:
    cpu: 500m
    memory: 1Gi
  requests:
    cpu: 250m
    memory: 512Mi

autoCompactionMode: revision
autoCompactionRetention: "1000"

metrics:
  enabled: true


preUpgradeJob:
  enabled: false
```

```bash

kubectl create namespace lavinmq-infra

helm install lavinmq-etcd oci://registry-1.docker.io/bitnamicharts/etcd -f lavinmq-etcd-values.yaml --namespace lavinmq-infra

```

Verify:
```bash
kubectl get pods -n lavinmq-infra
```
Ensure etcd pods are healthy before proceeding.

---


## 7. Deploy LavinMQ Instance
Installing the operator does NOT automatically create a LavinMQ cluster.

We must create a Custom Resource (CR).

 7.1 Create Base Chart
```bash
helm create lavinmq-instance
cd lavinmq-instance

```


7.2 Replace Chart.yaml
```bash
cat > Chart.yaml << 'EOF'
apiVersion: v2
name: lavinmq-instance
description: Complete Helm chart for LavinMQ with instance support
type: application
version: 1.0.0
appVersion: "0.2.0"
EOF
```

7.3 Replace values.yaml
```bash
cat > values.yaml << 'EOF'
namespace:
  name: lavinmq-infra

# -----------------------------------------------
# LavinMQ instance config
# -----------------------------------------------
lavinmq:
  name: lavinmq
  replicas: 2
  image: cloudamqp/lavinmq:2.6.8
  accessMode: ReadWriteOnce
  amqpPort: 5672
  mgmtPort: 15672
  etcdEndpoint: "http://lavinmq-etcd.lavinmq-infra.svc.cluster.local:2379"

# -----------------------------------------------
# Storage config (used by my-lavinmq.yaml)
# -----------------------------------------------
pv:
  size: 5Gi
  storageClass: nfs-client-lavinmq         # ← must match storageClass.name above

# -----------------------------------------------
# NodePort service config
# -----------------------------------------------
service:
  enabled: true
  name: lavinmq-nodeport
  type: NodePort
  protocol: TCP
  nameUi: http-ui
  portOne: 15672
  targetPortOne: 15672
  nodePortOne: 31672
  nameAmqp: amqp
  portTwo: 5672
  targetPortTwo: 5672
  nodePortTwo: 30672
EOF
```



## 7.4 Create lavinmq-service.yaml

```bash
rm -rf templates/*
rm -rf charts/ crds/

cat > templates/lavinmq-service.yaml << 'EOF'
{{- if .Values.service.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.service.name }}
  namespace: {{ .Values.namespace.name }}
spec:
  type: {{ .Values.service.type }}
  selector:
    app.kubernetes.io/name: lavinmq-operator
  ports:
    - name: {{ .Values.service.nameUi }} 
      protocol: {{ .Values.service.protocol }}
      port: {{ .Values.service.portOne }}
      targetPort: {{ .Values.service.targetPortOne }}
      nodePort: {{ .Values.service.nodePortOne }}
    - name: {{ .Values.service.nameAmqp }}
      protocol: {{ .Values.service.protocol }}
      port: {{ .Values.service.portTwo }}
      targetPort: {{ .Values.service.targetPortTwo }}
      nodePort: {{ .Values.service.nodePortTwo }}
{{- end }}
EOF


```



## 7.5 Create my-lavinmq.yaml
```bash
cat > templates/my-lavinmq.yaml << 'EOF'
apiVersion: cloudamqp.com/v1alpha1
kind: LavinMQ
metadata:
  name: {{ .Values.lavinmq.name }}
  namespace: {{ .Values.namespace.name }}
spec:
  replicas: {{ .Values.lavinmq.replicas }}
  image: {{ .Values.lavinmq.image }}
  etcdEndpoints:
    - {{ .Values.lavinmq.etcdEndpoint }}
  dataVolumeClaim:
    accessModes:
      - {{ .Values.lavinmq.accessMode }}
    resources:
      requests:
        storage: {{ .Values.pv.size }}
    storageClassName: {{ .Values.pv.storageClass }}
  config:
    amqp:
      port: {{ .Values.lavinmq.amqpPort }}
    mgmt:
      port: {{ .Values.lavinmq.mgmtPort }}
EOF

```


7.6 Validate and Deploy Chart
```bash
helm template lavinmq-instance ./lavinmq-instance -n lavinmq-infra

helm install lavinmq-instance ./lavinmq-instance -n lavinmq-infra --debug --dry-run

helm install lavinmq-instance ./lavinmq-instance -n lavinmq-infra

```



7.7 Validate Deployment
```bash
kubectl get pods -n lavinmq-infra
kubectl get pvc -n lavinmq-infra
kubectl get svc -n lavinmq-infra

kubectl get pv

```


---



## References
https://lavinmq.com/blog/kubernetes-operator

https://lavinmq.com/documentation/configuration-files

https://github.com/cloudamqp/lavinmq-operator


https://github.com/cloudamqp/lavinmq-operator/releases/tag/0.2.0



