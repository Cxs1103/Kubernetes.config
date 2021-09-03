#!/bin/bash

##################################
##   K8S安装脚本（环境搭建）    ##
##################################
echo -e "\033[34;49;1m 本脚本为K8S初始化安装环境脚本\033[39;49;0m"
set -x
#字体颜色设置：
# 绿色：  echo -e "\033[32;49;1m 我的家\033[39;49;0m"
# 红色：echo -e "\033[31;49;1m 我的家\033[39;49;0m"
# 蓝色：echo -e "\033[34;49;1m 我的家\033[39;49;0m"

##【挂载硬盘】------>
echo -e "\033[34;49;1m 挂载磁盘中...\033[39;49;0m"
mkdir   /mnt/dvd
cat >> /etc/fstab <<EOF
/dev/cdrom     /mnt/dvd   iso9660 defaults  0  0 
EOF
mount -a
if [ $? == 0 ];then
   echo -e "\033[32;49;1m 磁盘挂载成功！\033[39;49;0m"
else
   echo -e "\033[33;49;1m 磁盘挂载失败！请检查磁盘是否存在！\033[39;49;0m"
fi

##【搭建yum软件仓库】
echo -e "\033[34;49;1m 正在配置本地yum源\033[39;49;0m"
rm -rf  /etc/yum.repos.d/*
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
cat >  /etc/yum.repos.d/App.repo <<EOF
[CentOS-1804]
name=CentOS-1804
baseurl=file:///mnt/dvd
enable=1
gpgcheck=0
EOF
yum clean all
yum makecache
yum repolist 
if [ $? == 0 ];then
   echo -e "\033[32;49;1m yum源搭建成功！\033[39;49;0m"

##【测试网络是否可通外网】
ping -c 4 www.baidu.com
if [ $? == 0 ];then
   echo -e "\033[32;49;1m 网络正常\033[39;49;0m"
else
   echo -e "\033[31;49;1m 网络异常！请检查！\033[39;49;0m"
fi

##【安装常用工具】
yum  install  -y  vim net-tools bash-completion gcc make  wget  lrzsz tree make gcc

##【配置主机映射】
echo -e "\033[34;49;1m 我的家\033[39;49;0m"
cat >>  /etc/hosts  <<EOF
192.168.2.81	master01
192.168.2.82	master02
192.168.2.83	master03
192.168.2.91	node01
192.168.2.92	node02
192.168.2.93	node03
EOF

##【关闭SElinux、swap、firewalld】
SeLinux=`grep  'SELINUX='   /etc/selinux/config   |  grep -v "^#"  |  awk  -F=  '{print $2}'`
SELinux=`getenforce`

if [ $SeLinux  !=  disabled ];then
   sed -i 's/SELINUX=enforcing/SELINUX=disable/g'  /etc/selinux/config
   setenforce 0 
   echo "SELinux已修改为：$SELinux"
fi

sed -i "s@/dev/mapper/centos-swap@#/dev/mapper/centos-swap@g"   /etc/fstab
swapoff  -a
systemctl disable --now firewalld
yum remove  -y firewalld*

##【配置时间同步】
#时间服务器为192.168.2.99
sed  -i  "/server/s/server/#server/g"    /etc/chrony.conf
echo  "server 192.168.2.99  iburs"  >>  /etc/chrony.conf
systemctl restart chronyd.service
systemctl enable  chronyd.service
chronyc  sources  -v

##【安装cfssl证书工具】
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.0/cfssl_1.6.0_linux_amd64 -O /usr/local/bin/cfssl 
if [ $? == 0 ];then
    echo -e "\033[32;49;1m cfssl安装成功\033[39;49;0m"
else
    echo -e "\033[31;49;1m cfssl安装失败\033[39;49;0m"
fi

wget https://github.com/cloudflare/cfssl/releases/download/v1.6.0/cfssljson_1.6.0_linux_amd64 -O /usr/local/bin/cfssljson 
if [ $? == 0 ];then
    echo -e "\033[32;49;1m cfssl安装成功\033[39;49;0m"
else
    echo -e "\033[31;49;1m cfssl安装失败\033[39;49;0m"
fi
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.0/cfssl-certinfo_1.6.0_linux_amd64 -O /usr/local/bin/cfssl-certinfo
if [ $? == 0 ];then
    echo -e "\033[32;49;1m cfssl安装成功\033[39;49;0m"
else
    echo -e "\033[31;49;1m cfssl安装失败\033[39;49;0m"
fi
chmod +x  /usr/local/bin/*
echo -e "\033[32;49;1m cfssl安装完成\033[39;49;0m"

##【Linux内核升级】
#检查内核版本：
tenel=`uname  -r` 
echo -e "\033[34;49;1m 当前内核版本为：$tenel\033[39;49;0m"

#检查操作系统：
Vero=`cat /etc/redhat-release   |  awk  '{print $1,$4}'`
echo -e "\033[34;49;1m 当前操作系统为：$Vero\033[39;49;0m"
echo -e "\033[34;49;1m 正在升级内核\033[39;49;0m"


##【部署时间同步】
yum install -y chrony
systemctl start chronyd
systemctl enable chronyd
chronyc sources

##【修改内核参数】
echo -e "\033[34;49;1m 正在修改内核参数/etc/sysctl.d/k8s.conf...\033[39;49;0m"
cat > /etc/sysctl.d/k8s.conf << EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
if [ $? == 0 ];then
   echo -e "\033[32;49;1m 修改完成\033[39;49;0m"
fi

##[加载Ipvs模块]
echo -e "\033[34;49;1m 正在加载IPVS模块\033[39;49;0m"
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
lsmod | grep ip_vs
lsmod | grep nf_conntrack_ipv4
yum install -y ipvsadm ipset  

##【部署docker】
echo -e "\033[34;49;1m 正在部署docker...\033[39;49;0m"
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sudo sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
sudo yum makecache fast
sudo yum -y install docker-ce-19.03.8
sudo yum install -y docker-client

if [ $? == 0];then
  echo -e "\033[32;49;1mdocker安装成功\033[39;49;0m"
  cat > /etc/docker/daemon.json <<EOF
{
    "exec-opts":["native.cgroupdriver=systemd"],
    "registry-mirrors":["https://registry.docker.cn.com"],
    "insecure-registries":["192.168.2.99:443"]
}
EOF
else
  echo -e "\033[31;49;1mdocker安装失败\033[39;49;0m"  
fi

echo -e "\033[34;49;1m正在启动docker\033[39;49;0m"  
sudo systemctl enable --now docker
sudo systemctl status docker
docker version
if [ $? == 0];then
  echo -e "\033[32;49;1mdocker搭建完成\033[39;49;0m"
else
 echo -e "\033[31;49;1mdocker服务异常！请检查\033[39;49;0m"
fi
