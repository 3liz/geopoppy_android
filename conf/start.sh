#!/bin/sh

# env
QOP=/home/geopoppy/.local/share/QGIS/QGIS3/profiles/default/
export QGIS_OPTIONS_PATH=$QOP
LIZ=/storage/internal/geopoppy/qgis/LizSync.ini
export LIZSYNC_CONFIG_FILE=$LIZ

if [ -z ${1+x} ]
then
    echo "ACTION is unset: default TO START"
    ACTION="start"
else
    echo "ACTION is set"
    ACTION=$1
fi
echo "$ACTION has been chosen"


# POSTGRES
# Must NOT be started by superuser, but by geopoppy
# NO sudo
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


# NGINX
# Must NOT be started by superuser, but by geopoppy
# NO sudo
SERVICE="nginx"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is already running"
    if [ $ACTION = 'forcestart' ]; then service nginx restart;  fi
else
    echo "Start $SERVICE"
    service nginx restart
fi

# REDIS
# MUST be started by superuser
# Must always be RESTARTED (bug ?)
SERVICE="redis"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is running"
    if [ $ACTION = 'forcestart' ] || [ $ACTION = 'start' ] # always restart
    then
        pkill $SERVICE
        sudo redis-server /etc/redis/redis.conf > /dev/null
    fi
else
    echo "Start $SERVICE"
    pkill $SERVICE
    sudo redis-server /etc/redis/redis.conf > /dev/null
fi

# PHP
# MUST be started by superuser
SERVICE="php"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is already running"
    if [ $ACTION = 'forcestart' ]; then sudo service php7.3-fpm restart;  fi
else
    echo "Start $SERVICE"
    sudo service php7.3-fpm restart
    # Flush redis db
    redis-cli FLUSHALL

fi

# FTP
# MUST be started by superuser
SERVICE="ftpd"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is already running"
    if [ $ACTION = 'forcestart' ]; then sudo service pure-ftpd restart;  fi
else
    echo "Start $SERVICE"
    sudo service pure-ftpd restart
fi

# QGIS SERVER
SERVICE="qgisserver"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is running"
    if [ $ACTION = 'forcestart' ]
    then
        pkill $SERVICE
        rm /tmp/qgisserver.log
        export QGIS_OPTIONS_PATH=$QOP && nohup qgisserver -c /storage/internal/geopoppy/conf/qgisserver.conf --rootdir / > /tmp/qgisserver.log &
    fi
else
    echo "Start $SERVICE"
    pkill $SERVICE
    rm /tmp/qgisserver.log
    export QGIS_OPTIONS_PATH=$QOP && nohup qgisserver -c /storage/internal/geopoppy/conf/qgisserver.conf --rootdir / > /tmp/qgisserver.log &
fi


SERVICE="wpsserver"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is running"
    if [ $ACTION = 'forcestart' ]
    then
        pkill $SERVICE
        rm /tmp/wpsserver.log
        export QGIS_OPTIONS_PATH=$QOP && export LIZSYNC_CONFIG_FILE=$LIZ && nohup wpsserver -b 127.0.0.1 -p 8081 -c /storage/internal/geopoppy/conf/wpsserver.conf > /tmp/wpsserver.log &
    fi
else
    echo "Start $SERVICE"
    pkill $SERVICE
    rm /tmp/wpsserver.log
    export QGIS_OPTIONS_PATH=$QOP && export LIZSYNC_CONFIG_FILE=$LIZ && nohup wpsserver -b 127.0.0.1 -p 8081 -c /storage/internal/geopoppy/conf/wpsserver.conf > /tmp/wpsserver.log &
fi


mydevice="wlan0"
myip=$(ip add | grep "global $mydevice" | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
echo "GEOPOPPY IP ADDRESS = $myip"
