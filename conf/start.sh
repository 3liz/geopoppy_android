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
        service postgresql stop
        pkill postgres
        service postgresql start
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
    if [ $ACTION = 'restart' ]
    then
        sudo service redis-server stop
        if pgrep "$SERVICE" >/dev/null
        then
            pgrep $SERVICE | xargs kill -9
        fi
        sudo service redis-server start
    fi
else
    echo "Start $SERVICE"
    sudo service redis-server start
fi
pgrep "$SERVICE"

# NGINX
# Must NOT be started by superuser, but by geopoppy
# NO sudo
SERVICE="nginx"
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is already running"
    if [ $ACTION = 'restart' ];
    then
        service nginx stop
        if pgrep "$SERVICE" >/dev/null
        then
            pgrep $SERVICE | xargs kill -9
        fi
        service nginx start
    fi
else
    echo "Start $SERVICE"
    service nginx start
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
SERVICE="qgis"
export LIZSYNC_CONFIG_FILE=/storage/internal/geopoppy/qgis/LizSync.ini
export QGIS_OPTIONS_PATH=/home/geopoppy/.local/share/QGIS/QGIS3/profiles/default/
export QGIS_DEBUG=1
export QGIS_SERVER_LOG_FILE=/tmp/qgis-server.log
export QGIS_SERVER_LOG_LEVEL=1
export QGIS_SERVER_LOG_STDERR=1
export QGIS_SERVER_PARALLEL_RENDERING=1
export QGIS_SERVER_IGNORE_BAD_LAYERS=TRUE
export QGIS_PREFIX_PATH=/usr
export QGIS_SERVER_OVERRIDE_SYSTEM_LOCALE=fr
if pgrep "$SERVICE" >/dev/null
then
    echo "$SERVICE is running"
    if [ $ACTION = 'restart' ]
    then
        echo "Restart $SERVICE"
        pkill multiwatch
        pkill spawn-fcgi
        pkill qgis
        echo "" > /tmp/nohup-spawn.log
        echo "" > /tmp/qgis-server.log
        if pgrep "$SERVICE" >/dev/null
        then
            pgrep $SERVICE | xargs kill -9
            pkill multiwatch
            pkill spawn-fcgi
            pkill qgis
        fi
        #nohup spawn-fcgi -s /var/run/qgisserver.socket -U www-data -G www-data -n /usr/lib/cgi-bin/qgis_mapserv.fcgi > /tmp/nohup-spawn.log 2>&1 &
        nohup spawn-fcgi -n -s /var/run/qgisserver.socket -u www-data -U www-data -G www-data -- /usr/bin/multiwatch -f 3 -- /usr/lib/cgi-bin/qgis_mapserv.fcgi > /tmp/nohup-spawn.log 2>&1 &
    fi
else
    echo "Start $SERVICE"
    #nohup spawn-fcgi -s /var/run/qgisserver.socket -U www-data -G www-data -n /usr/lib/cgi-bin/qgis_mapserv.fcgi > /tmp/nohup-spawn.log 2>&1 &
    nohup spawn-fcgi -n -s /var/run/qgisserver.socket -u www-data -U www-data -G www-data -- /usr/bin/multiwatch -f 3 -- /usr/lib/cgi-bin/qgis_mapserv.fcgi > /tmp/nohup-spawn.log 2>&1 &
fi
echo "Test qgisserver"
sleep 1
pgrep $SERVICE

# Get IP
mydevice="wlan0"
myip=$(ip add | grep "global $mydevice" | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
echo "GEOPOPPY IP ADDRESS WLAN = $myip"

mydevice="rndis0"
myip=$(ip add | grep "global $mydevice" | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
echo "GEOPOPPY IP ADDRESS USB = $myip"
