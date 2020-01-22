#!/bin/sh

# Nginx
cp /storage/internal/geopoppy/install/default /etc/nginx/sites-enabled/default

# PHP-FPM
cp /storage/internal/geopoppy/install/php.ini /etc/php/7.3/fpm/php.ini
#ln -s /usr/lib/libc-client.a /usr/lib/aarch64-linux-gnu/libc-client.a
#ln -s /usr/lib/libc-client.a /usr/lib/arm-linux-gnueabihf/libc-client.a

# start nginx +phpfpm
sudo service nginx start
sudo service php7.3-fpm start

# lizmap
lizmap_version=3.3.3
lizmap_wps_version=master
lizmap_wps_git=https://github.com/3liz/lizmap-wps-web-client-module.git
mkdir /www
cd /www
wget https://github.com/3liz/lizmap-web-client/archive/$lizmap_version.zip
unzip $lizmap_version.zip
rm $lizmap_version.zip
ln -s /www/lizmap-web-client-$lizmap_version/lizmap/www/ /www/lizmap

git clone --branch $lizmap_wps_version --depth=1 $lizmap_wps_git lizmap-wps
mv lizmap-wps/wps /www/lizmap-web-client-$lizmap_version/lizmap/lizmap-modules/wps
rm -rf lizmap-wps

cd /www/lizmap-web-client-$lizmap_version
cp /storage/internal/geopoppy/install/lizmapConfig.ini.php lizmap/var/config/lizmapConfig.ini.php
cp /storage/internal/geopoppy/install/localconfig.ini.php lizmap/var/config/localconfig.ini.php
cp lizmap/var/config/profiles.ini.php.dist     lizmap/var/config/profiles.ini.php
php lizmap/install/installer.php
sudo sh lizmap/install/set_rights.sh www-data www-data
sh lizmap/install/clean_vartmp.sh
cd ~

#py-qgis-server
git_repository=https://github.com/3liz/py-qgis-server.git
git_branch=master
git clone --branch $git_branch --depth=1 $git_repository py-qgis-server
make -C py-qgis-server dist
sudo pip3 install py-qgis-server/build/dist/*.tar.gz
rm -rf py-qgis-server && rm -rf /root/.cache /root/.ccache

#wps
wps_branch=master
wps_repository=https://github.com/3liz/py-qgis-wps.git
api_branch=master
api_repository=https://github.com/dmarteau/lizmap-plugin.git
git clone --branch $api_branch --depth=1 $api_repository lizmap-plugin
cd lizmap-plugin
sudo pip3 install .
cd ..
rm -rf lizmap-plugin
rm -rf /root/.cache /root/.ccache
git clone --branch $wps_branch --depth=1 $wps_repository py-qgis-wps
sudo make -C py-qgis-wps dist
sudo pip3 install py-qgis-wps/docker/dist/*.tar.gz
rm -rf py-qgis-wps
rm -rf /root/.cache /root/.ccache

# pure-ftpd
# Creating an empty shell for users
sudo ln /bin/false /bin/ftponly
# Configuring FTP server
sudo echo "/bin/ftponly" >> /etc/shells
# Each user is locked in his home
sudo echo "yes" > /etc/pure-ftpd/conf/ChrootEveryone
# TLS
sudo echo "1" > /etc/pure-ftpd/conf/TLS
# Configure the properties of directories and files created by users
sudo echo "133 022" > /etc/pure-ftpd/conf/Umask
# The port range for passive mode (opening outwards)
sudo echo "5400 5600" > /etc/pure-ftpd/conf/PassivePortRange
# Creating an SSL certificate for FTP
sudo rm -f /etc/ssl/private/pure-ftpd.pem /etc/ssl/private/pure-ftpd.pem
sudo openssl req -x509 -nodes -newkey rsa:1024 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem
sudo chmod 400 /etc/ssl/private/pure-ftpd.pem
# Restart FTP server
sudo service pure-ftpd restart
# Create user
sudo groupadd ftpgroup
sudo useradd -g ftpgroup -d /dev/null -s /etc ftpuser
echo "geopoppy" > /tmp/pureftpd.passwd
echo "geopoppy" >> /tmp/pureftpd.passwd
sudo chmod 0644 /tmp/pureftpd.passwd
sudo pure-pw useradd geopoppy -u ftpuser -g ftpgroup -d /storage/internal/geopoppy/qgis/ -m < /tmp/pureftpd.passwd
sudo rm /tmp/pureftpd.passwd
sudo ln -s /etc/pure-ftpd/conf/PureDB /etc/pure-ftpd/auth/50pure
sudo pure-pw mkdb
sudo service pure-ftpd restart

#postgresql
sudo cp /storage/internal/geopoppy/install/postgresql.conf /etc/postgresql/11/main/
sudo cp /storage/internal/geopoppy/install/pg_hba.conf /etc/postgresql/11/main/
sudo service postgresql restart
sudo chmod 0600 /etc/ssl/private/ssl-cert-snakeoil.key
sudo pg_dropcluster --stop 11 main
sudo pg_createcluster --start --locale fr_FR.UTF-8 --lc-collate fr_FR.UTF-8 --lc-ctype fr_FR.UTF-8 -e UTF-8 --port 5432 11 main
service postgresql start
sudo -u postgres createuser geopoppy --superuser
sudo -u postgres psql -d postgres -c "ALTER USER geopoppy WITH ENCRYPTED PASSWORD 'geopoppy';"
sudo -u postgres psql -d postgres -c "ALTER USER postgres WITH ENCRYPTED PASSWORD 'postgres';"
sudo -u postgres createdb geopoppy
sudo -u postgres psql -d geopoppy -c "CREATE EXTENSION postgis;CREATE EXTENSION hstore;"













