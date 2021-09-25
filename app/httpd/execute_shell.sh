#!/bin/bash
backupcode="/data/backcode/$JOB_NAME/$BUILD_NUMBER"
mkdir -p $backupcode     #jenkins创建上述目录
chmod 644 "$JENKINS_HOME"/workspace/"$JOB_NAME"/*
rsync -acP   "$JENKINS_HOME"/workspace/"$JOB_NAME"/*  $backupcode #$JENKINS_HOME和$JOB_NAME同步最新消息
#ssh -p22206 root@192.168.0.81 sed -i 's/v1/v2/g' /root/k8s/app/httpd.yaml
echo From harbor.mieken.cn/k8s/web:v1 > "$JENKINS_HOME"/workspace/Dockerfile
echo COPY ./"$JOB_NAME"/* /usr/local/apache2/htdocs/ >> "$JENKINS_HOME"/workspace/Dockerfile
docker rmi harbor.mieken.cn/k8s/web:v1
docker build -t harbor.mieken.cn/k8s/web:v1 /"$JENKINS_HOME"/workspace/.
docker push harbor.mieken.cn/k8s/web:v1
ssh -p22206 root@192.168.0.81 kubectl delete -f /root/k8s/app/httpd.yaml
n=1
while (( $n <= 10 ))
do
    echo $n
    (( n++ ))
    sleep 1
done
ssh -p22206 root@192.168.0.81 kubectl apply -f /root/k8s/app/httpd.yaml