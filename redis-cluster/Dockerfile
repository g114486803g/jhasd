FROM alpine:latest

# 修正时区
ENV TIMEZONE Asia/Shanghai

RUN echo http://mirrors.aliyun.com/alpine/v3.11/main/ > /etc/apk/repositories && \
    echo http://mirrors.aliyun.com/alpine/v3.11/community/ >> /etc/apk/repositories && \
    apk update && apk upgrade && \
    apk add tzdata bash-doc bash  redis && \
    ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && \
    echo $TIMEZONE > /etc/timezone

COPY redis.conf /etc/redis.conf

CMD [ "redis-server", "/etc/redis.conf" ]
