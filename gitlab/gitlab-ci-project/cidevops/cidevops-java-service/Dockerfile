FROM registry.cn-hangzhou.aliyuncs.com/cxs1103/openjdk:8-alpine
MAINTAINER devops

ADD target/*.jar /app.jar

# 执行命令
ENTRYPOINT ["java","-jar","/app.jar"]