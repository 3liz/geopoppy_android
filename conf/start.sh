#!/bin/sh

service postgresql start &&
service nginx restart &&
sudo service php7.3-fpm restart &&
sudo service pure-ftpd restart &&
#sudo redis-server /etc/redis/redis.conf &&
qgisserver -c /storage/internal/geopoppy/conf/qgisserver.conf --rootdir /
#wpsserver -b 127.0.0.1 -p 8081 -c /storage/internal/geopoppy/conf/wpssserver.conf

