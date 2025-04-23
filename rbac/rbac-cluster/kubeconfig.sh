kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --server=https://192.168.68.30:6443 \
  --kubeconfig=cxs-cluster.kubeconfig
 
# 设置客户端认证
kubectl config set-credentials cxs-cluster \
  --client-key=cxs-cluster-key.pem \
  --client-certificate=cxs-cluster.pem \
  --embed-certs=true \
  --kubeconfig=cxs-cluster.kubeconfig

# 设置默认上下文
kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=cxs-cluster \
  --kubeconfig=cxs-cluster.kubeconfig

# 设置当前使用配置
kubectl config use-context kubernetes --kubeconfig=cxs-cluster.kubeconfig


