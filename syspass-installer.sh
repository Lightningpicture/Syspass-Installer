#!/bin/bash

# Version 1.0.1
# Simon Kley
# This small script automates the Syspass installation

# init vars

MYSQL_PASSWORD="LKJio89Z)huihJHjk"

# Simple check if this is a debian based distribution
if [ -f /etc/debian_version ]; then
  echo -e "Starting Syspass-Installation..."
  echo -e "Please be patient."
else
  echo -e "This is not a debian based distribution!"
  echo -e "Please use this script only on debian based distributions."
  echo -e "Aborting..."
  exit 1
fi


update_system() {
  echo -en "Update system .. "
  apt-get -qq update > /dev/null
  if [ "$?" -ne 0 ]; then
    echo -e "failed."
    exit 1
  else
    echo -e "done."
  fi
}

install_software() {
  echo -en "Install Software"
  apt-get -qq locales apache2 libapache2-mod-php7.0 php-pear php7.0 php7.0-cgi php7.0-cli \
	php7.0-common php7.0-fpm php7.0-gd php7.0-json php7.0-mysql php7.0-readline \
	php7.0-curl php7.0-intl php7.0-ldap php7.0-mcrypt php7.0-xml php7.0-mbstring git > /dev/null
  if [ "$?" -ne 0 ]; then
    echo -e "failed."
    exit 1
  else
    echo -e "done."
  fi
}


apache_restart() {
  echo -en "Apache Restart "
  service apache2 restart > /dev/null
  if [ "$?" -ne 0 ]; then
    echo -e "failed."
    exit 1
  else
    echo -e "done."
  fi
}

install_tools() {
  echo -en "Install Tools .. "
  apt-get -qq install nano sudo htop less > /dev/null
  if [ "$?" -ne 0 ]; then
    echo -e "failed."
    exit 1
  else
    echo -e "done."
  fi
}


install_dependencies() {
  echo -en "Installing dependencies .. "
  apt-get -qq remove apt-listchanges > /dev/null && \
  apt-get -qq update > /dev/null && \
  apt-get -qq install apt-transport-https ca-certificates pwgen curl lsb-release > /dev/null
  if [ "$?" -ne 0 ]; then
    echo -e "failed."
    exit 1
  else
    echo -e "done."
  fi
}



install_mysql_server() {
  echo -en "Installating MySQL-Server from debian-repositories and setting root password .. "
  MYSQL_PASSWORD=`pwgen 12`
  echo mysql-server mysql-server/root_password password $MYSQL_PASSWORD | debconf-set-selections && \
  echo mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD | debconf-set-selections && \
  apt-get -qq install mysql-server > /dev/null
  if [ "$?" -ne 0 ]; then
    echo -e "failed."
    exit 1
  else
    echo -e "done."
  fi
 echo $MYSQL_PASSWORD > /root/MYSQL_PASSWORD.txt
}


install_composer() {
  echo -en "Install Composer "
  cd /var/www/html/syspass
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
	php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
	php composer-setup.php
	php -r "unlink('composer-setup.php');"
	
	php composer.phar install --no-dev
  
  if [ "$?" -ne 0 ]; then
    echo -e "failed."
    exit 1
  else
    echo -e "done."
  fi
}

download_syspass() {
  echo -en "Downloading Syspass "
  mkdir /var/www/html/syspass
  cd /var/www/html/syspass
  git clone https://github.com/nuxsmin/sysPass.git /var/www/html/syspass
  
  chown www-data -R /var/www/html/syspass
  chmod 750 /var/www/html/syspass/app/config /var/www/html/syspass/app/backup/

  if [ "$?" -ne 0 ]; then
    echo -e "failed."
    exit 1
  else
    echo -e "done."
  fi
}


update_system
install_software
install_dependencies
apache_restart
install_mysql_server
install_tools
download_syspass
install_composer


echo -e "Syspass is Ready ..."
echo -e "Please check with your browser."
echo -e ""
echo -e "Your root password for MySQL is "\"$MYSQL_PASSWORD\" "and is saved to /root/MYSQL_PASSWORD.txt"


