#!/bin/sh

# Get last geopoppy content
cd /storage/internal/
geopoppy_branch=bustter
wget "https://github.com/3liz/geopoppy_android/archive/$geopoppy_branch.zip"
unzip "$geopoppy_branch.zip"
mv "geopoppy_android-$geopoppy_branch" geopoppy
rm "$geopoppy_branch.zip"

# Nginx
cp /storage/internal/geopoppy/install/default /etc/nginx/sites-enabled/default

# PHP-FPM
cp /storage/internal/geopoppy/install/php.ini /etc/php/7.3/fpm/php.ini
#ln -s /usr/lib/libc-client.a /usr/lib/aarch64-linux-gnu/libc-client.a
#ln -s /usr/lib/libc-client.a /usr/lib/arm-linux-gnueabihf/libc-client.a

# start nginx + phpfpm
service nginx start
sudo service php7.3-fpm start

# lizmap web client
lizmap_version=3.3.6
lizmap_wps_version=master
lizmap_wps_git=https://github.com/3liz/lizmap-wps-web-client-module.git
mkdir /www
cd /www
wget https://github.com/3liz/lizmap-web-client/archive/$lizmap_version.zip
unzip $lizmap_version.zip
rm $lizmap_version.zip
ln -s /www/lizmap-web-client-$lizmap_version/lizmap/www/ /www/lizmap

# lizmap wps module
git clone --branch $lizmap_wps_version --depth=1 $lizmap_wps_git lizmap-wps
mv lizmap-wps/wps /www/lizmap-web-client-$lizmap_version/lizmap/lizmap-modules/wps
rm -rf lizmap-wps

# Config Lizmap Web Client
cd /www/lizmap-web-client-$lizmap_version
cp /storage/internal/geopoppy/install/lizmapConfig.ini.php lizmap/var/config/lizmapConfig.ini.php
cp /storage/internal/geopoppy/install/localconfig.ini.php lizmap/var/config/localconfig.ini.php
cp lizmap/var/config/profiles.ini.php.dist     lizmap/var/config/profiles.ini.php
php lizmap/install/installer.php
sudo sh lizmap/install/set_rights.sh www-data www-data
sh lizmap/install/clean_vartmp.sh
cd ~

#py-qgis-server
cd ~
git_repository=https://github.com/3liz/py-qgis-server.git
git_branch=master
git clone --branch $git_branch --depth=1 $git_repository py-qgis-server
make -C py-qgis-server dist
sudo pip3 install py-qgis-server/build/dist/*.tar.gz
rm -rf py-qgis-server && rm -rf /root/.cache /root/.ccache

# lizmap plugin api
#api_branch=master
#api_repository=https://github.com/dmarteau/lizmap-plugin.git
#git clone --branch $api_branch --depth=1 $api_repository lizmap-plugin
#cd lizmap-plugin
#sudo pip3 install .
#cd ..
#rm -rf lizmap-plugin
#rm -rf /root/.cache /root/.ccache

# Debug python
# Si erreur suivante à la compile
# MemoryError
# Commenter la ligne CFUNCTYPE(c_int)(lambda: None)
#https://stackoverflow.com/questions/5914673/python-ctypes-memoryerror-in-fcgi-process-from-pil-library
sed -i "s/CFUNCTYPE(c_int)(lambda: None)/#CFUNCTYPE(c_int)(lambda: None)/" /usr/lib/python2.7/ctypes/__init__.py
sed -i "s/CFUNCTYPE(c_int)(lambda: None)/#CFUNCTYPE(c_int)(lambda: None)/" /usr/lib/python2.7/ctypes/__init__.py

# py-qgis-wps
cd ~
wps_branch=master
wps_repository=https://github.com/3liz/py-qgis-wps.git
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
sudo echo "0" > /etc/pure-ftpd/conf/TLS
# Configure the properties of directories and files created by users
sudo echo "133 022" > /etc/pure-ftpd/conf/Umask
# The port range for passive mode (opening outwards)
sudo echo "5600 5800" > /etc/pure-ftpd/conf/PassivePortRange
# Creating an SSL certificate for FTP
#sudo rm -f /etc/ssl/private/pure-ftpd.pem /etc/ssl/private/pure-ftpd.pem
#sudo openssl req -x509 -nodes -newkey rsa:1024 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem
#sudo chmod 400 /etc/ssl/private/pure-ftpd.pem
# Restart FTP server
sudo service pure-ftpd restart
# Create user
sudo groupadd ftpgroup
sudo useradd -g ftpgroup -d /dev/null -s /etc ftpuser
echo "geopoppy" > /tmp/pureftpd.passwd
echo "geopoppy" >> /tmp/pureftpd.passwd
echo "" >> /tmp/pureftpd.passwd
sudo chmod 0644 /tmp/pureftpd.passwd
sudo pure-pw useradd geopoppy -u geopoppy -g geopoppy -d /storage/internal/geopoppy/qgis/ -m < /tmp/pureftpd.passwd
sudo rm /tmp/pureftpd.passwd
sudo ln -s /etc/pure-ftpd/conf/PureDB /etc/pure-ftpd/auth/50pure
sudo pure-pw mkdb
sudo service pure-ftpd stop && sudo service pure-ftpd start
sudo service pure-ftpd status

# PostgreSQL
# !!!!!
# NB: PostgreSQL must NOT be run as root, but as geopoppy
# NO sudo
# !!!!!
sudo chmod 0600 /etc/ssl/private/ssl-cert-snakeoil.key
pg_dropcluster --stop 11 main
pg_createcluster --start --locale fr_FR.UTF-8 --lc-collate fr_FR.UTF-8 --lc-ctype fr_FR.UTF-8 -e UTF-8 --port 5432 11 main
cp /storage/internal/geopoppy/install/postgresql.conf /etc/postgresql/11/main/postgresql.conf
sed -i "s/9.6/11/g" /etc/postgresql/11/main/postgresql.conf
echo "host    all             all             0.0.0.0/0              md5" >> /etc/postgresql/11/main/pg_hba.conf

service postgresql restart
# createuser geopoppy --superuser # not needed because cluster has been created by geopoppy
psql -d postgres -c "ALTER USER geopoppy WITH ENCRYPTED PASSWORD 'geopoppy';"
createdb geopoppy
psql -d geopoppy -c "CREATE EXTENSION IF NOT EXISTS postgis;CREATE EXTENSION IF NOT EXISTS hstore;"
# Add service file
cat > /etc/postgresql-common/pg_service.conf <<EOF
[geopoppy]
host=localhost
dbname=geopoppy
user=geopoppy
port=5432
password=geopoppy
EOF

# Add QGIS Server ini file
mkdir -p /home/geopoppy/.local/share/QGIS/QGIS3/profiles/default/QGIS
cp /storage/internal/geopoppy/conf/QGIS3.ini /home/geopoppy/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini
chmod 777 /home/geopoppy/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini

# Copy start script to /etc/profile.d/s_start_geopoppy_services.sh
# Services will be started at the first SSH login only
# Which means when the user type the Userland session password for geopoppy
sudo cp /storage/internal/geopoppy/conf/start.sh /etc/profile.d/z_start_geopoppy_services.sh

# GET IP
mydevice="wlan0"
myip=$(ip add | grep "global $mydevice" | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
echo "GEOPOPPY IP ADDRESS = $myip"









