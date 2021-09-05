#!/bin/bash

##################################
##   K8S安装脚本（环境搭建）    ##
##################################
echo -e "\033[34;49;1m 本脚本为K8S安装环境脚本\033[39;49;0m"

echo -e "\033[34;49;1m 安装docker依赖 \033[39;49;0m"
yum install -y yum-utils device-mapper-persistent-data lvm2

echo -e "\033[34;49;1m 添加阿里镜像源 \033[39;49;0m"
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

echo -e "\033[34;49;1m 安装docker-19.03 \033[39;49;0m"
yum install --setopt=obsoletes=0 docker-ce-19.03.15-3.el7 -y

echo -e "\033[34;49;1m 创建docker存放盘符 \033[39;49;0m"
mkdir -p /data/docker

echo -e "\033[34;49;1m 修改docker启动文件 \033[39;49;0m"
sed -i 's/ExecStart=\/usr\/bin\/dockerd/ExecStart=\/usr\/bin\/dockerd --graph=\/data\/docker/g' /usr/lib/systemd/system/docker.service

echo -e "\033[34;49;1m 编辑docker配置文件 \033[39;49;0m"
mkdir /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "registry-mirrors": ["https://fvm9j7yf.mirror.aliyuncs.com"]
}
EOF

echo -e "\033[34;49;1m 重新加载配置 \033[39;49;0m"
systemctl daemon-reload

echo -e "\033[34;49;1m 修改sysctl.conf \033[39;49;0m"
# 这个配置有待测试，其实在修改内核参数的时候就已经配置过了
cat > /etc/sysctl.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl -p

echo -e "\033[34;49;1m 重启docker \033[39;49;0m"
systemctl start docker
systemctl enable docker

echo -e "\033[34;49;1m 查看docker信息 \033[39;49;0m"
docker info

echo -e "\033[34;49;1m 添加阿里云kubernetes源 \033[39;49;0m"
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
#repo_gpgcheck=1
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
#exclude=kube*
EOF

echo -e "\033[34;49;1m 安装k8s \033[39;49;0m"
yum install --setopt=obsoletes=0 kubeadm-1.20.8 kubelet-1.20.8  kubectl-1.20.8  -y

echo -e "\033[34;49;1m 修改kubelet配置 \033[39;49;0m"
cat > /etc/sysconfig/kubelet <<EOF
KUBELET_CGROUP_ARGS="--cgroup-driver=systemd"
KUBE_PROXY_MODE="ipvs"
EOF

echo -e "\033[34;49;1m 设置kubelet开机自启 \033[39;49;0m"
systemctl enable kubelet

echo -e "\033[34;49;1m 部署master节点 \033[39;49;0m"
kubeadm init \
  --apiserver-advertise-address=192.168.0.81 \
  --image-repository registry.aliyuncs.com/google_containers \
  --kubernetes-version v1.20.8 \
  --service-cidr=10.96.0.0/12 \
  --pod-network-cidr=10.244.0.0/16

echo -e "\033[34;49;1m 创建kubernetes用户 \033[39;49;0m"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config