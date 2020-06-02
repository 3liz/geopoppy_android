#!/bin/sh



if [ -z ${1+x} ]
then
    echo "ACTION is unset: default to restart"
    ACTION="restart"
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
    if [ $ACTION = "restart" ]
    then
        service postgresql restart
    fi
else
    echo "Start $SERVICE"
    service postgresql start
fi

# REDIS
# MUST be started by superuser
# Must always be RESTARTED (bug ?)
SERVICE="redis"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is running"
    if [ $ACTION = 'restart' ] || [ $ACTION = 'start' ] # always restart
    then
        pkill $SERVICE
        sudo redis-server /etc/redis/redis.conf > /dev/null
    fi
else
    echo "Start $SERVICE"
    pkill $SERVICE
    sudo redis-server /etc/redis/redis.conf > /dev/null
fi
pgrep "$SERVICE"

# NGINX
# Must NOT be started by superuser, but by geopoppy
# NO sudo
SERVICE="nginx"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is already running"
    if [ $ACTION = 'restart' ]; then service nginx restart;  fi
else
    echo "Start $SERVICE"
    service nginx restart
fi

# PHP
# MUST be started by superuser
sleep 2
SERVICE="php"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is already running"
    if [ $ACTION = 'restart' ]; then sudo service php7.3-fpm restart;  fi
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
    if [ $ACTION = 'restart' ]; then sudo service pure-ftpd restart;  fi
else
    echo "Start $SERVICE"
    sudo service pure-ftpd restart
fi

# QGISSERVER
SERVICE="qgisserver"
echo "" > /tmp/qgis-server.log
# env
QOP=/home/geopoppy/.local/share/QGIS/QGIS3/profiles/default/
export QGIS_OPTIONS_PATH=$QOP
LIZ=/storage/internal/geopoppy/qgis/LizSync.ini
export LIZSYNC_CONFIG_FILE=$LIZ
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is running"
    if [ $ACTION = 'restart' ]
    then
        echo "Restart $SERVICE"
        pkill qgisserver
        nohup qgisserver -c /storage/internal/geopoppy/conf/qgisserver.conf --rootdir / 1>/tmp/qgis-server.log 2>&1 &
    fi
else
    echo "Start $SERVICE"
    pkill qgisserver
    nohup qgisserver -c /storage/internal/geopoppy/conf/qgisserver.conf --rootdir / 1>/tmp/qgis-server.log 2>&1 &
fi
echo "Test qgisserver"
sleep 1
pgrep $service


mydevice="wlan0"
myip=$(ip add | grep "global $mydevice" | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
echo "GEOPOPPY IP ADDRESS = $myip"
