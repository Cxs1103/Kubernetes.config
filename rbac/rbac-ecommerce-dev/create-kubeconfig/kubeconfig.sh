kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --server=https://192.168.68.30:6443 \
  --kubeconfig=cxs.kubeconfig
 
# 设置客户端认证
kubectl config set-credentials cxs \
  --client-key=cxs-key.pem \
  --client-certificate=cxs.pem \
  --embed-certs=true \
  --kubeconfig=cxs.kubeconfig

# 设置默认上下文
kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=cxs \
  --kubeconfig=cxs.kubeconfig

# 设置当前使用配置
kubectl config use-context kubernetes --kubeconfig=cxs.kubeconfig


