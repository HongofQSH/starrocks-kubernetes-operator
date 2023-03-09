从该网站下载代码：https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner

创建角色绑定
必须修改其中所有的namespace，把default改为starrocks
cd external-storage/nfs-client/deploy
kubectl apply -f rbac.yaml

创建provisioner
将deployment.yaml中所有的namespace，从default改为starrocks
 kubectl apply -f deployment.yaml

创建sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-storage
provisioner: k8s-sigs.io/nfs-subdir-external-provisioner 
parameters:
  archiveOnDelete: "false"

 kubectl apply -f sc.yaml

创建pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc
  namespace: starrocks  
  annotations:
    volume.beta.kubernetes.io/storage-class: "nfs-storage"
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi

 kubectl apply -f pvc.yaml


验证：
kubectl get sc 
NAME                 PROVISIONER                                   RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
nfs-storage          k8s-sigs.io/nfs-subdir-external-provisioner   Delete          Immediate              false                  10s
standard (default)   rancher.io/local-path                         Delete          WaitForFirstConsumer   false                  64d

kubectl get pvc -n starrocks
NAME   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc    Bound    pvc-b1e01fdf-e129-44a8-9acb-0b57a3df2bcc   10Gi       RWX            nfs-storage    16s






***********************************************************************************************************************************************
废弃
Lesson: https://blog.51cto.com/u_10272167/3596637
download address: https://github.com/kubernetes-retired/external-storage
External-storage plugin download address:  https://github.com/kubernetes-retired/external-storage/archive/refs/heads/master.zip

创建角色绑定
必须修改其中所有的namespace，把default改为starrocks
cd external-storage/nfs-client/deploy
kubectl apply -f rbac.yaml

[root@k8s-master-1 deploy]# cat deployment.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-client-provisioner
  labels:
    app: nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: default
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: nfs-client-provisioner
  template:
    metadata:
      labels:
        app: nfs-client-provisioner
    spec:
      serviceAccountName: nfs-client-provisioner
      containers:
        - name: nfs-client-provisioner
          # 如果地址下载比较慢可以先把镜像下载下来然后，修改这里的地址
          image: quay.io/external_storage/nfs-client-provisioner:latest
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              # 与class 中的provisioner要一致
              value: fuseim.pri/ifs
            - name: NFS_SERVER
              value: 172.16.1.83    # <=====NFS服务器的地址
            - name: NFS_PATH
              value: /data/nfs      # <=====NFS服务器的路径
      volumes:
        - name: nfs-client-root
          nfs:
            server: 172.16.1.83     # <=====NFS服务器的地址
            path: /data/nfs         # <=====NFS服务器的路径
            
 kubectl apply -f deployment.yaml
-----------------------------------

创建完PVC之后，发现PVC处于pending状态。
用kubectl logs nfs-client-provisioner-6d9578b959-5cn78 -n starrocks查看nfs-client-provisioner的日志发现如下错误：
provision "starrocks/pvc" class "nfs-storage": unexpected error getting claim reference: selfLink was empty, can't make reference
进入kind-control-plane容器，复制/etc/kubernetes/manifests/kube-apiserver.yaml的内容，
spec:
  containers:
  - command:
    - kube-apiserver
加入下列行
- --feature-gates=RemoveSelfLink=false
***********************************************************************************************************************************************




