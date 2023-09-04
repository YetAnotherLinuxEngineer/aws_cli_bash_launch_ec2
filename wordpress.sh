#!/bin/bash
logpath="/home/admin/install.log"
sudo apt-get update -y
sudo apt-get install apache2 mariadb-server php php-json php-mysql php-curl php-xml php-mbstring php-xml php-gd curl unzip certbot python3-certbot-apache -y &> $logpath
echo "Downloading the latest version of Wordpress... " &> $logpath
curl --remote-name --silent --show-error https://wordpress.org/latest.tar.gz
echo "${GREEN}Done! ✅${NC}"
printf '\n'
echo "Decompressing the file... " &> $logpath
sudo tar xzvf latest.tar.gz --strip-components=1 --directory=/var/www/html/ &> $logpath
echo "${GREEN}Done! ✅${NC}"
printf '\n'

wp_db="my_db"
wp_user="my_user"
wp_pass="my_pass"
wp_host="localhost"
duckdns_token="dd7c6be0-6b80-448c-a362-f67ada8756dd"
duckdns_domain="deviwordpress"
duckdns_email="freekepange@gmail.com"

echo url="https://www.duckdns.org/update?domains=$duckdns_domain&token=$duckdns_token&ip=" | curl -k -o ~/duckdns/duck.log -K -
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $wp_db ;"
sudo mysql -e "CREATE USER '$wp_user'@'localhost' IDENTIFIED BY '$wp_pass';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $wp_db.* TO '$wp_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"


pushd /var/www/html
echo "Configuring WordPress... " &> $logpath
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/$wp_db/g" ./wp-config.php
sudo sed -i "s/username_here/$wp_user/g" ./wp-config.php
sudo sed -i "s/password_here/$wp_pass/g" ./wp-config.php
sudo sed -i "s/localhost/$wp_host/g" ./wp-config.php

#   Set authentication unique keys and salts in wp-config.php
sudo perl -i -pe '
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' ./wp-config.php
title="My Blog"
admin_user="admin"
admin_pass="admin"
admin_email="a@a.email.com"
curl --data-urlencode "weblog_title=$title" \
     --data-urlencode "user_name=$admin_user" \
     --data-urlencode "admin_password=$admin_pass" \
     --data-urlencode "admin_password2=$admin_pass" \
     --data-urlencode "admin_email=$admin_email" \
     --data-urlencode "Submit=Install+WordPress" \
     http://$duckdns_domain.duckdns.org/wp-admin/install.php?step=2 &> $logpath
echo "${GREEN}Done! ✅${NC}"
printf '\n'

echo "Applying folder and file permissions... " &> $logpath
sudo chown -R www-data:www-data /var/www/html/
sudo find /var/www/html/ -type d -exec chmod 755 {} \;
sudo find /var/www/html/ -type f -exec chmod 644 {} \;
sudo mv /var/www/html/index{,_bkup}.html 
echo "${GREEN}Done! ✅${NC}"
printf '\n'
sudo certbot --apache -m $duckdns_email --non-interactive --agree-tos -d  $duckdns_domain.duckdns.org
#http://`curl ifconfig.me`/wp-admin/install.php?step=2 &> $logpath
