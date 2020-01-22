#!/bin/sh

SERVICE="postgres"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is already running"
else
    echo "Start $SERVICE"
    service postgresql start
fi

SERVICE="nginx"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is already running"
else
    echo "Start $SERVICE"
    service nginx restart
fi

SERVICE="php"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is already running"
else
    echo "Start $SERVICE"
    sudo service php7.3-fpm restart
fi

SERVICE="ftpd"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is already running"
else
    echo "Start $SERVICE"
    service pure-ftpd restart
fi

SERVICE="redis"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is running"
else
    echo "Start $SERVICE"
    pkill $SERVICE
    sudo redis-server /etc/redis/redis.conf > /dev/null
fi

SERVICE="qgisserver"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is running"
else
    echo "Start $SERVICE"
    pkill $SERVICE
    qgisserver -c /storage/internal/geopoppy/conf/qgisserver.conf --rootdir /
fi

#SERVICE="wpsserver"
#if pgrep "$SERVICE" >/dev/null
#then
    #echo "$SERVICE is running"
#else
    #echo "Start $SERVICE"
    #pkill $SERVICE
    #wpsserver -b 127.0.0.1 -p 8081 -c /storage/internal/geopoppy/conf/wpssserver.conf
#fi

