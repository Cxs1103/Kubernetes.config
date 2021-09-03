#!/bin/bash
# 作者 polo
# 
# 我尽力写的简练通俗,仔细看,否则总会有麻烦,
# 我的环境一共3台主机,master是 2C2G,node是1C1G
# 该笔记你只需要根据你的实际情况修改ip为你自己的
# 另外,需要的k8s 二进制文件,你自己下载放到合适的位置,还有cfssl工具集,注意权限要给够
# k8s 1.21.3
# etcd是centos7自带yum安装  Version: 3.3.11
# centos7 yum update -y
#  centos7 minimal 安装,yum update -y 

# echo $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#    172.19.1.1安装etcd,和k8s master组件,证书生产也在该机器
#    IP  	           主机名字   安装组件 
#    172.19.1.1/24          master     etcd,kube-apiserver,kube-controller-manager,kube-scheduler, cfssl工具
#    172.19.1.11/24   	   node1      kubelet,kube-proxy,cni
#    172.19.1.12/24         node2      kubelet,kube-proxy,cni

# 下面是我的几个ip段分配情况
# node 172.19.1.0/24
# pod  172.20.0.0/16
# svc  172.21.0.0/16

# echo $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# 清理之前之前安装的k8s master组件,你是干净的系统,就不需要清理
sleep 2
systemctl stop kube-apiserver.service 
systemctl stop kube-controller-manager.service
systemctl stop kube-scheduler.service  
rm -fr /opt/k8s
rm -fr /root/.kube
rm -fr /usr/lib/systemd/system/kube*
# 清理etcd数据,并重启etcd
#yum erase etcd -y
systemctl stop etcd 
rm -fr /var/lib/etcd
yum reinstall etcd -y
systemctl enable etcd 
systemctl start etcd 
#
# echo $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# 关闭防火墙和selinux,关闭交换分区
# 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld
# 关闭交换分区
swapoff -a 
sed -i 's/.*swap.*/#&/' /etc/fstab
# "vm.swappiness = 0" >> /etc/sysctl.conf 
#sysctl -p
# 查看selinux结果
sestatus

# 关闭selinux
setenforce  0 
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux 
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config 
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/sysconfig/selinux 
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config

echo $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$



echo 修改主机名
hostnamectl --static set-hostname master
echo  配置hosts文件
# 根据你的ip来修改,注意,名字不要乱搞,必须依照
cat >> /etc/hosts << EOF
172.19.1.1 master 
172.19.1.11 node1 
172.19.1.12 node2 
EOF


# 2.1.5 时间同步
# 2.1.6 系统配置
# 2.1.7 加载ipvs
# 2.1.8 K8s内核优化
#  安装其他工具（可选）
#yum install lsof tcpdump wget vim bash-completion tree telnet wget -y
#source /usr/share/bash-completion/bash_completion
#source <(kubectl completion bash)

# 定义了一些环境变量，便于操作，省去了麻烦，注意根据主机ip和主机名修改
# 下面变量需要根据你的规划自己定义 
echo 定义变量
MASTER_IP="172.19.1.1"
KUBE_APISERVER="https://${MASTER_IP}:6443"
ETCD_IP="127.0.0.1"
ETCD_ENDPOINT="http://127.0.0.1:2379"
BOOTSTRAP_TOKEN="c47ffb939f5ca36231d9e3121a252940"
# Pod 网段，建议 /16 段地址
CLUSTER_CIDR="172.21.0.0/16"
# service网段
SERVICE_CIDR="172.20.0.0/16"
# 服务端口范围 NodePort Range
NODE_PORT_RANGE="30000-32767"
# kubernetes 服务 IP (一般是 SERVICE_CIDR 中第一个IP)
KUBERNETES_SVC_IP="172.20.0.1"
# 集群 DNS 服务 IP (从 SERVICE_CIDR 中预分配)
DNS_SVC_IP="172.20.0.2"
# 集群 DNS 域名（末尾不带点号）
DNS_DOMAIN="cluster.local"

# 验证变量,你当然可以不需要上面这些变量,只不过你得一个一个的慢慢去改吧
echo $MASTER_IP
echo $KUBE_APISERVER
echo $ETCD_IP
echo $ETCD_ENDPOINT
echo $BOOTSTRAP_TOKEN
echo $CLUSTER_CIDR
echo $SERVICE_CIDR
echo $NODE_PORT_RANGE
echo $KUBERNETES_SVC_IP
echo $DNS_SVC_IP
echo $DNS_DOMAIN
sleep 2

# 创建kubernetes master工作目录 ###
mkdir -p /opt/k8s/{bin,data,ssl,cfg,log,net}
mkdir -p /root/.kube

# 安装cfssl工具
# wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
# wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
# wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
# 
# chmod +x cfssl*
# mv cfssl_linux-amd64 /usr/local/bin/cfssl
# mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
# mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo

# 下载解压 kubernetes 
# cd /data/k8s-work
# 根据下面的地址,选择自己喜欢的版本,只需要下载 Server Binaries解压就行
# https://github.com/kubernetes/kubernetes/tree/master/CHANGELOG
# tar -xvf kubernetes-server-linux-amd64.tar.gz
# cd kubernetes/server/bin/
# cp kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/


# 配置ca请求文件
# 切换到工作目录
cd /opt/k8s/ssl
cat > ca-csr.json <<"EOF"
{
  "CN": "kubernetes",
  "key": {
      "algo": "rsa",
      "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Hubei",
      "L": "shiyan",
      "O": "k8s",
      "OU": "system"
    }
  ],
  "ca": {
          "expiry": "87600h"
  }
}
EOF

# 创建ca证书
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

sleep 2

# 配置ca证书策略
cd /opt/k8s/ssl
cat > ca-config.json <<"EOF"
{
  "signing": {
      "default": {
          "expiry": "87600h"
        },
      "profiles": {
          "kubernetes": {
              "usages": [
                  "signing",
                  "key encipherment",
                  "server auth",
                  "client auth"
              ],
              "expiry": "87600h"
          }
      }
  }
}
EOF


#  2.2.4.3 部署api-server
# 创建apiserver-csr

cd /opt/k8s/ssl
# 特别注意,如果你的 下一行的 EOF 用双引号. "EOF" 则变量不会输出
cat > kube-apiserver-csr.json << EOF
{
"CN": "kubernetes",
  "hosts": [
    "127.0.0.1",
    "${MASTER_IP}",
    "${KUBERNETES_SVC_IP}",
    "${DNS_SVC_IP}",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Hubei",
      "L": "shiyan",
      "O": "k8s",
      "OU": "system"
    }
  ]
}
EOF
# 生成证书
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-apiserver-csr.json | cfssljson -bare kube-apiserver

sleep 2

# 生产token文件
cat > /opt/k8s/cfg/token.csv << EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF

# kube-apiserver启动参数文件
# 特别注意,如果你的 下一行的 EOF 用双引号. "EOF" 则变量不会输出
cat > /opt/k8s/cfg/kube-apiserver.conf << EOF
KUBE_APISERVER_OPTS="--enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
--anonymous-auth=false \\
--bind-address=${MASTER_IP} \\
--secure-port=6443 \\
--insecure-port=0 \\
--authorization-mode=Node,RBAC \\
--runtime-config=api/all=true \\
--enable-bootstrap-token-auth \\
--service-cluster-ip-range=${SERVICE_CIDR} \\
--service-node-port-range=${NODE_PORT_RANGE} \\
--token-auth-file=/opt/k8s/cfg/token.csv \\
--tls-cert-file=/opt/k8s/ssl/kube-apiserver.pem  \\
--tls-private-key-file=/opt/k8s/ssl/kube-apiserver-key.pem \\
--client-ca-file=/opt/k8s/ssl/ca.pem \\
--kubelet-client-certificate=/opt/k8s/ssl/kube-apiserver.pem \\
--kubelet-client-key=/opt/k8s/ssl/kube-apiserver-key.pem \\
--service-account-key-file=/opt/k8s/ssl/ca-key.pem \\
--service-account-signing-key-file=/opt/k8s/ssl/ca-key.pem  \\
--service-account-issuer=api \\
--etcd-servers=${ETCD_ENDPOINT} \\
--allow-privileged=true \\
--event-ttl=1h \\
--alsologtostderr=true \\
--logtostderr=false \\
--log-dir=/opt/k8s/log \\
--v=4"
EOF



# kube-apiserver服务启动文件
cat > /usr/lib/systemd/system/kube-apiserver.service << "EOF"
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=etcd.service
Wants=etcd.service

[Service]
EnvironmentFile=-/opt/k8s/cfg/kube-apiserver.conf
ExecStart=/usr/local/bin/kube-apiserver $KUBE_APISERVER_OPTS
Restart=on-failure
RestartSec=5
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl start kube-apiserver.service
sleep 10
systemctl enable kube-apiserver.service

# 测试 kube-apiserver是否启动正常,
# 至少 6443端口必须是打开监听
ss -tnlp |grep 6443
echo 6443 起来监听,说明你的kube-apiserver启动了
echo 如果有问题,那就看日志   tailf /opt/k8s/log/kube-apiserver.ERROR 
#### 通过curl命令访问K8s API ,下面的都不行,以后再研究
# 使用token
# token="c47ffb939f5ca36231d9e3121a252940"
# curl --cacert /opt/k8s/ssl/ca.pem -H "Authorization: Bearer $token"  https://172.19.1.1:6443/apis
#  
# #使用证书
# curl https://172.19.1.1:6443/apis \
# --cacert /opt/k8s/ssl/ca.pem \
# --cert /opt/k8s/ssl/kube-apiserver.pem \
# --key /opt/k8s/ssl/kube-apiserver-key.pem 
# #### 通过curl命令访问K8s API 
# curl https://172.19.1.1:6443/api --cacert /opt/k8s/ssl/ca.pem --key /opt/k8s/ssl/kube-apiserver-key.pem --cert /opt/k8s/ssl/kube-apiserver.pem
# 



#echo $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#  生产kubectl 使用的 config文件
cd /opt/k8s/ssl
cat > admin-csr.json << "EOF"
{
  "CN": "admin",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Hubei",
      "L": "shiyan",
      "O": "system:masters",             
      "OU": "system"
    }
  ]
}
EOF

#  后续 kube-apiserver 使用 RBAC 对客户端(如 kubelet、kube-proxy、Pod)请求进行授权；
#  kube-apiserver 预定义了一些 RBAC 使用的 RoleBindings，如 cluster-admin 将 Group system:masters 
#  与 Role cluster-admin 绑定，该 Role 授予了调用kube-apiserver 的所有 API的权限；
#  O指定该证书的 Group 为 system:masters，kubelet 使用该证书访问 kube-apiserver 时 ，由于证书被 CA 签名，
#  所以认证通过，同时由于证书用户组为经过预授权的 system:masters，所以被授予访问所有 API 的权限；
#  注：
#  这个admin 证书，是将来生成管理员用的kube config 配置文件用的，现在我们一般建议使用RBAC 来对kubernetes
#   进行角色权限控制， kubernetes 将证书中的CN 字段 作为User， O 字段作为 Group；
#  "O": "system:masters", 必须是system:masters，否则后面kubectl create clusterrolebinding报错。
#  链接：https://www.jianshu.com/p/b02c428950df

# 生成证书
 cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin

sleep 2

# cp admin*.pem /opt/k8s/ssl/

# kubeconfig配置
# kube.config 为 kubectl 的配置文件，包含访问 apiserver 的所有信息，如 apiserver 地址、CA 证书和自身使用的证书
# --server=https://172.19.1.1:6443 \
cd /opt/k8s/ssl
kubectl config set-cluster kubernetes \
--certificate-authority=ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER} \
--kubeconfig=kube.config
kubectl config set-credentials admin  \
--client-certificate=admin.pem \
--client-key=admin-key.pem \
--embed-certs=true \
--kubeconfig=kube.config
kubectl config set-context kubernetes \
--cluster=kubernetes \
--user=admin \
--kubeconfig=kube.config
kubectl config use-context kubernetes --kubeconfig=kube.config
mv kube.config /opt/k8s/cfg
cp /opt/k8s/cfg/kube.config ~/.kube/config

echo 这一步没做, kubectl get cs成功
# kubectl create clusterrolebinding kube-apiserver:kubelet-apis --clusterrole=system:kubelet-api-admin --user kubernetes --kubeconfig=/root/.kube/config
# kubectl create clusterrolebinding kube-apiserver:kubelet-apis --clusterrole=system:kubelet-api-admin --user kubernetes 

# echo $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# 查看集群状态
#kubectl cluster-info
kubectl get componentstatuses
#kubectl get all --all-namespaces
sleep 1






echo $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
echo 部署kube-controller-manager

sleep 2

# 创建csr请求文件
cd /opt/k8s/ssl
# 开头一行的EOF 如果带着双引号如 "EOF" ,则不会用值替换变量
cat > kube-controller-manager-csr.json << EOF
{
    "CN": "system:kube-controller-manager",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "hosts": [
      "127.0.0.1",
      "${MASTER_IP}"
    ],
    "names": [
      {
        "C": "CN",
        "ST": "Hubei",
        "L": "shiyan",
        "O": "system:kube-controller-manager",
        "OU": "system"
      }
    ]
}
EOF


# hosts 列表包含所有 kube-controller-manager 节点 IP；
# CN 为 system:kube-controller-manager、O 为 system:kube-controller-manager，kubernetes 
# 内置的 ClusterRoleBindings system:kube-controller-manager 赋予 kube-controller-manager 工作所需的权限

# 生成证书
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

ls -l kube-controller-*.pem
sleep 2

# 创建kube-controller-manager的kube-controller-manager.kubeconfig
cd /opt/k8s/ssl/
kubectl config set-cluster kubernetes \
--certificate-authority=ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER} \
--kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
--client-certificate=kube-controller-manager.pem \
--client-key=kube-controller-manager-key.pem \
--embed-certs=true \
--kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-context system:kube-controller-manager \
--cluster=kubernetes \
--user=system:kube-controller-manager \
--kubeconfig=kube-controller-manager.kubeconfig

kubectl config use-context system:kube-controller-manager \
--kubeconfig=kube-controller-manager.kubeconfig

sleep 1

mv /opt/k8s/ssl/kube-controller-manager.kubeconfig /opt/k8s/cfg/
sleep 1
# 创建配置文件kube-controller-manager.conf
cd /opt/k8s/cfg
cat > kube-controller-manager.conf << EOF
KUBE_CONTROLLER_MANAGER_OPTS="--port=10252 \\
  --secure-port=10257 \\
  --bind-address=${MASTER_IP} \\
  --kubeconfig=/opt/k8s/cfg/kube-controller-manager.kubeconfig \\
  --service-cluster-ip-range=$SERVICE_CIDR \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/opt/k8s/ssl/ca.pem \\
  --cluster-signing-key-file=/opt/k8s/ssl/ca-key.pem \\
  --allocate-node-cidrs=true \\
  --cluster-cidr=${CLUSTER_CIDR} \\
  --experimental-cluster-signing-duration=87600h \\
  --root-ca-file=/opt/k8s/ssl/ca.pem \\
  --service-account-private-key-file=/opt/k8s/ssl/ca-key.pem \\
  --feature-gates=RotateKubeletServerCertificate=true \\
  --controllers=*,bootstrapsigner,tokencleaner \\
  --horizontal-pod-autoscaler-use-rest-clients=true \\
  --horizontal-pod-autoscaler-sync-period=10s \\
  --tls-cert-file=/opt/k8s/ssl/kube-controller-manager.pem \\
  --tls-private-key-file=/opt/k8s/ssl/kube-controller-manager-key.pem \\
  --use-service-account-credentials=true \\
  --alsologtostderr=true \\
  --logtostderr=false \\
  --log-dir=/opt/k8s/log \\
  --v=4"
EOF

# 创建 kube-controller-manager system服务启动文件
cat > /usr/lib/systemd/system/kube-controller-manager.service << "EOF"
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes
[Service]
EnvironmentFile=-/opt/k8s/cfg/kube-controller-manager.conf
ExecStart=/usr/local/bin/kube-controller-manager $KUBE_CONTROLLER_MANAGER_OPTS
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-load
systemctl start kube-controller-manager.service 
sleep 2
systemctl enable kube-controller-manager.service 

echo 10252和 10257 是kube-controller-manager的监听端口
ss -tnl |grep 10252
ss -tnl |grep 10257

sleep 2

# 同样的在拍错时,充分利用log
# tailf /opt/k8s/log/kube-controller-manager.ERROR
# tailf /opt/k8s/log/kube-controller-manager.WARNING
# tailf /opt/k8s/log/kube-controller-manager.INFO

echo $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

echo 部署kube-scheduler
sleep 2

cd /opt/k8s/ssl
cat > kube-scheduler-csr.json << EOF
{
    "CN": "system:kube-scheduler",
    "hosts": [],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "ST": "Hubei",
        "L": "shiyan",
        "O": "system:kube-scheduler",
        "OU": "system"
      }
    ]
}
EOF

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-scheduler-csr.json | cfssljson -bare kube-scheduler

ls -l kube-scheduler*.pem

# 创建kube-scheduler的kubeconfig
cd /opt/k8s/ssl
kubectl config set-cluster kubernetes \
--certificate-authority=ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER} \
--kubeconfig=kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
--client-certificate=kube-scheduler.pem \
--client-key=kube-scheduler-key.pem \
--embed-certs=true \
--kubeconfig=kube-scheduler.kubeconfig

kubectl config set-context system:kube-scheduler \
--cluster=kubernetes \
--user=system:kube-scheduler \
--kubeconfig=kube-scheduler.kubeconfig

kubectl config use-context system:kube-scheduler \
--kubeconfig=kube-scheduler.kubeconfig
mv /opt/k8s/ssl/kube-scheduler.kubeconfig /opt/k8s/cfg

# 创建kube-scheduler 配置文件
# kube-scheduler 地址最好是127.0.0.1或者0.0.0.0,如果是接口地址,kubectl get cs会拒绝
cat > /opt/k8s/cfg/kube-scheduler.conf << "EOF"
KUBE_SCHEDULER_OPTS="--address=127.0.0.1 \
--kubeconfig=/opt/k8s/cfg/kube-scheduler.kubeconfig \
--alsologtostderr=true \
--logtostderr=false \
--log-dir=/opt/k8s/log \
--v=4"
EOF

# 创建kube-scheduler systemd服务启动文件
cat > /usr/lib/systemd/system/kube-scheduler.service << "EOF"
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/opt/k8s/cfg/kube-scheduler.conf
ExecStart=/usr/local/bin/kube-scheduler $KUBE_SCHEDULER_OPTS
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start kube-scheduler 
sleep 5
systemctl enable kube-scheduler.service

ss -tnl |grep 10251
ss -tnl |grep 10259
# kube-scheduler 监听端口是 10251 和10259
echo $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
systemctl start kube-controller-manager.service 

#kubectl cluster-info
kubectl get componentstatuses
#kubectl get all --all-namespaces

echo 至此,k8s master节点部署完毕了


