#!/bin/sh

if [ -z ${1+x} ]
then
    echo "ACTION is unset: default TO START"
    ACTION="start"
else
    echo "ACTION is set"
    ACTION=$1
fi
echo "$ACTION has been chosen"

SERVICE="postgres"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is already running"
    if [ $ACTION = "forcestart" ]
    then
        service postgresql restart
    fi
else
    echo "Start $SERVICE"
    service postgresql start
fi

SERVICE="nginx"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is already running"
    if [ $ACTION = 'forcestart' ]; then service nginx restart;  fi
else
    echo "Start $SERVICE"
    service nginx restart
fi

SERVICE="php"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is already running"
    if [ $ACTION = 'forcestart' ]; then sudo service php7.3-fpm restart;  fi
else
    echo "Start $SERVICE"
    sudo service php7.3-fpm restart
fi

SERVICE="ftpd"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is already running"
    if [ $ACTION = 'forcestart' ]; then sudo service pure-ftpd restart;  fi
else
    echo "Start $SERVICE"
    sudo service pure-ftpd restart
fi

SERVICE="redis"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is running"
    if [ $ACTION = 'forcestart' ]
    then
        pkill $SERVICE
        sudo redis-server /etc/redis/redis.conf > /dev/null
    fi
else
    echo "Start $SERVICE"
    pkill $SERVICE
    sudo redis-server /etc/redis/redis.conf > /dev/null
fi

SERVICE="qgisserver"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is running"
    if [ $ACTION = 'forcestart' ]
    then
        pkill $SERVICE
        qgisserver -c /storage/internal/geopoppy/conf/qgisserver.conf --rootdir /
    fi
else
    echo "Start $SERVICE"
    pkill $SERVICE
    qgisserver -c /storage/internal/geopoppy/conf/qgisserver.conf --rootdir /
fi

#SERVICE="wpsserver"
#if pgrep "$SERVICE" >/dev/null
#then
    #echo "$SERVICE is running"
#    if [ $ACTION = 'forcestart' ]
#    then
#        pkill $SERVICE
        #wpsserver -b 127.0.0.1 -p 8081 -c /storage/internal/geopoppy/conf/wpssserver.conf
#    fi
#else
    #echo "Start $SERVICE"
    #pkill $SERVICE
    #wpsserver -b 127.0.0.1 -p 8081 -c /storage/internal/geopoppy/conf/wpssserver.conf
#fi
