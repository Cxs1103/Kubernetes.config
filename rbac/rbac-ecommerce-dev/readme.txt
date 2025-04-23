1.生成证书
sh cert.sh

2.生成kubeconfig
sh kubeconfig.sh

3.设置rbac，创建role，创建rolebinding
kubectl apply -f rbac.yaml

4.创建命名空间
kubectl create ns ecommerce-dev

5.创建deployment
kubectl apply -f deployment-demo.yaml

6.查看pod
# kubectl --kubeconfig cxs.kubeconfig -n ecommerce-dev get pod
NAME                        READY   STATUS    RESTARTS       AGE
web-demo-5bd8f97df7-4spz4   1/1     Running   1 (140m ago)   22h
web-demo-5bd8f97df7-hltkk   1/1     Running   1 (140m ago)   22h
web-demo-5bd8f97df7-tcwjz   1/1     Running   1 (140m ago)   22h
web-demo-5bd8f97df7-w55pm   1/1     Running   1 (140m ago)   22h
web-demo-5bd8f97df7-zz5kp   1/1     Running   1 (140m ago)   22h

7.删除role，删除rolebinding
kubectl delete -f rbac-cluster.yaml
clusterrole.rbac.authorization.k8s.io "ecommerce-dev-clusterrole" deleted
clusterrolebinding.rbac.authorization.k8s.io "ecommerce-dev-clusterrole-cxs" deleted

8.查看pod
root@master:~/k8s/rbac# kubectl --kubeconfig cxs.kubeconfig  get pod
Error from server (Forbidden): pods is forbidden: User "cxs" cannot list resource "pods" in API group "" in the namespace "default"

9.创建clusterrole，创建clusterrolebinding
root@master:~/k8s/rbac# kubectl apply -f rbac-cluster.yaml
clusterrole.rbac.authorization.k8s.io/ecommerce-dev-clusterrole created
clusterrolebinding.rbac.authorization.k8s.io/ecommerce-dev-clusterrole-cxs created

10.查看集群pod
root@master:~/k8s/rbac# kubectl --kubeconfig cxs.kubeconfig  get pod -A
NAMESPACE       NAME                                      READY   STATUS    RESTARTS        AGE
default         nfs-client-provisioner-69948dcb98-hldkz   1/1     Running   5 (178m ago)    6d23h
default         pod-test                                  1/1     Running   4 (178m ago)    6d22h
default         test-volumes                              1/1     Running   4 (178m ago)    6d23h
ecommerce-dev   web-demo-5bd8f97df7-4spz4                 1/1     Running   1 (178m ago)    23h
ecommerce-dev   web-demo-5bd8f97df7-hltkk                 1/1     Running   1 (178m ago)    23h
ecommerce-dev   web-demo-5bd8f97df7-tcwjz                 1/1     Running   1 (178m ago)    23h
ecommerce-dev   web-demo-5bd8f97df7-w55pm                 1/1     Running   1 (178m ago)    23h
ecommerce-dev   web-demo-5bd8f97df7-zz5kp                 1/1     Running   1 (178m ago)    23h
kube-system     cilium-9rwc7                              1/1     Running   5 (178m ago)    6d23h
kube-system     cilium-ctbgj                              1/1     Running   5 (178m ago)    6d23h
kube-system     cilium-fnjx5                              1/1     Running   5 (178m ago)    6d23h
kube-system     cilium-operator-6946ccbcc5-6r242          1/1     Running   5 (178m ago)    6d23h
kube-system     coredns-76f75df574-jq7xl                  1/1     Running   5 (178m ago)    6d23h
kube-system     coredns-76f75df574-m7t4g                  1/1     Running   5 (178m ago)    6d23h
kube-system     etcd-master                               1/1     Running   30 (178m ago)   6d23h
kube-system     kube-apiserver-master                     1/1     Running   18 (178m ago)   6d23h
kube-system     kube-controller-manager-master            1/1     Running   32 (178m ago)   6d23h
kube-system     kube-proxy-fnzkk                          1/1     Running   5 (178m ago)    6d23h
kube-system     kube-proxy-g4nmc                          1/1     Running   5 (178m ago)    6d23h
kube-system     kube-proxy-kt25z                          1/1     Running   5 (178m ago)    6d23h
kube-system     kube-scheduler-master                     1/1     Running   31 (178m ago)   6d23h
kube-system     kube-sealos-lvscare-node1                 1/1     Running   30 (178m ago)   6d23h
kube-system     kube-sealos-lvscare-node2                 1/1     Running   30 (178m ago)   6d23h

