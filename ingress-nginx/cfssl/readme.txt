mv cfssl cfssl-certinfo cfssljson /usr/bin/

# 创建证书目录
mkdir -p cfssl
cd cfssl
bash certs.sh
ls -la
kubectl create secret tls ngdemo-mieken-cn --cert=ngdemo.mieken.cn.pem --key=ngdemo.mieken.cn.pem
kubectl create secret tls ngdemo-mieken-cn --cert=ngdemo.mieken.cn.pem --key=ngdemo.mieken.cn-key.pem
kubectl get secrets
