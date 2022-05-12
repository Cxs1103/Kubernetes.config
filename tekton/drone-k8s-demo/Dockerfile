FROM alpine
WORKDIR /home

# 修改alpine源为阿里云
# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && \
#   apk update && \
#   apk upgrade && \
#   apk add ca-certificates && update-ca-certificates && \
#   apk add --update tzdata && \
#   rm -rf /var/cache/apk/*

# 设置时区为上海
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' >/etc/timezone

COPY app /home/
ENV TZ=Asia/Shanghai

EXPOSE 8080

ENTRYPOINT ./demo-app

