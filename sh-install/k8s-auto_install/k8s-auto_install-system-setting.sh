#!/bin/bash

##################################
##   K8S安装脚本（环境搭建）    ##
##################################

echo -e "\033[34;49;1m 本脚本为K8S初始化安装环境脚本\033[39;49;0m"
#字体颜色设置：
# 绿色：echo -e "\033[32;49;1m 我的家\033[39;49;0m"
# 红色：echo -e "\033[31;49;1m 我的家\033[39;49;0m"
# 蓝色：echo -e "\033[34;49;1m 我的家\033[39;49;0m"

echo -e "\033[34;49;1m 修改yum源为阿里云\033[39;49;0m"
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo_bak
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache

echo -e "\033[34;49;1m 安装chrony时间同步程序\033[39;49;0m"
yum install chrony -y

echo -e "\033[34;49;1m 设置时间同步服务器\033[39;49;0m"
sed -i 's/0.centos.pool.ntp.org/ntp.aliyun.com/g' /etc/chrony.conf
sed -i 's/1.centos.pool.ntp.org/ntp1.aliyun.com/g' /etc/chrony.conf
sed -i 's/2.centos.pool.ntp.org/ntp2.aliyun.com/g' /etc/chrony.conf
sed -i 's/3.centos.pool.ntp.org/ntp3.aliyun.com/g' /etc/chrony.conf

echo -e "\033[34;49;1m 重启chrony \033[39;49;0m"
systemctl restart chronyd

echo -e "\033[34;49;1m 查看时间 \033[39;49;0m"
date

echo -e "\033[34;49;1m 关闭防火墙 \033[39;49;0m"
systemctl stop firewalld
systemctl disable firewalld
systemctl status firewalld

echo -e "\033[34;49;1m 关闭selinux \033[39;49;0m"
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

echo -e "\033[34;49;1m 添加hosts主机解析 \033[39;49;0m"
echo -e "192.168.0.81 k8s-master\n192.168.0.82 k8s-node01\n192.168.0.83 k8s-node02" >> /etc/hosts

echo -e "\033[34;49;1m 修改Linux内核参数 \033[39;49;0m"
cat > /etc/rc.sysinit << EOF
#!/bin/bash
for file in /etc/sysconfig/modules/*.modules ; do
[ -x $file ] && $file
done
EOF

cat > /etc/sysconfig/modules/br_netfilter.modules << EOF
modprobe br_netfilter
EOF

chmod 755 /etc/sysconfig/modules/br_netfilter.modules

cat <<EOF > /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
vm.swappiness=0
EOF

echo -e "\033[34;49;1m 重新加载配置 \033[39;49;0m"
sysctl -p

echo -e "\033[34;49;1m 加载网桥过滤模块 \033[39;49;0m"
modprobe br_netfilter

echo -e "\033[34;49;1m 查看网桥过滤模块是否加载成功 \033[39;49;0m"
lsmod | grep br_netfilter

echo -e "\033[34;49;1m 安装ipvs模块 \033[39;49;0m"
yum install ipset ipvsadm -y

echo -e "\033[34;49;1m 添加ipvs配置 \033[39;49;0m"
cat <<EOF > /etc/sysconfig/modules/ipvs.modules
# ! /bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

echo -e "\033[34;49;1m 添加执行权限 \033[39;49;0m"
chmod +x /etc/sysconfig/modules/ipvs.modules

echo -e "\033[34;49;1m 执行脚本文件 \033[39;49;0m"
/bin/bash /etc/sysconfig/modules/ipvs.modules

echo -e "\033[34;49;1m 查看对应的模块是否加载成功 \033[39;49;0m"
lsmod | grep -e ip_vs -e nf_conntrack_ipv4

echo -e "\033[34;49;1m 重启服务器 \033[39;49;0m"
reboot