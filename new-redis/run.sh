#!/bin/bash

if [[ ${GET_HOSTS_FROM:-dns} == "env" ]]; then
  redis-server --slaveof ${REDIS_MASTER_SERVICE_HOST} 6379
  #sed -i 's/bind 127.0.0.1/bind redis-master/g'  /etc/redis.conf
else
  redis-server --slaveof redis-master 6379
  #sed -i 's/bind 127.0.0.1/bind ${REDIS_MASTER_SERVICE_HOST}/g' /etc/redis.conf
fi
