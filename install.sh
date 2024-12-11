#!/bin/bash

#################################################### CONFIGURATION ###
BUILD=202112181
PASS=$(openssl rand -base64 32|sha256sum|base64|head -c 32| tr '[:upper:]' '[:lower:]')
DBPASS=$(openssl rand -base64 24|sha256sum|base64|head -c 32| tr '[:upper:]' '[:lower:]')
SERVERID=$(openssl rand -base64 12|sha256sum|base64|head -c 32| tr '[:upper:]' '[:lower:]')
REPO=PurePanel/PurePanel

####################################################   CLI TOOLS   ###
reset=$(tput sgr0)
bold=$(tput bold)
underline=$(tput smul)
black=$(tput setaf 0)
white=$(tput setaf 7)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
purple=$(tput setaf 5)
bgblack=$(tput setab 0)
bgwhite=$(tput setab 7)
bgred=$(tput setab 1)
bggreen=$(tput setab 2)
bgyellow=$(tput setab 4)
bgblue=$(tput setab 4)
bgpurple=$(tput setab 5)



#################################################### PURE SETUP ######


# LOGO
clear
echo "${green}${bold}"
echo "
        ____  _   _ ____  _____
       |  _ \| | | |  _ \| ____|
       | |_) | | | | |_) |  _|
       |  __/| |_| |  _ <| |___
       |_|    \___/|_| \_\_____|"
echo ""
echo "Installation has been started... Hold on!"
echo "${reset}"
sleep 3s



# OS CHECK
clear
clear
echo "${bggreen}${black}${bold}"
echo "OS check..."
echo "${reset}"
sleep 1s

ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
VERSION=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')
if [ "$ID" = "ubuntu" ]; then
    case $VERSION in
        24.04)
            break
            ;;
        *)
            echo "${bgred}${white}${bold}"
            echo "PURE requires Linux Ubuntu 20.04 LTS"
            echo "${reset}"
            exit 1;
            break
            ;;
    esac
else
    echo "${bgred}${white}${bold}"
    echo "PURE requires Linux Ubuntu 20.04 LTS"
    echo "${reset}"
    exit 1
fi



# ROOT CHECK
clear
clear
echo "${bggreen}${black}${bold}"
echo "Permission check..."
echo "${reset}"
sleep 1s

if [ "$(id -u)" = "0" ]; then
    clear
else
    clear
    echo "${bgred}${white}${bold}"
    echo "You have to run PURE as root. (In AWS use 'sudo -s')"
    echo "${reset}"
    exit 1
fi



# BASIC SETUP
clear
clear
echo "${bggreen}${black}${bold}"
echo "Base setup..."
echo "${reset}"
sleep 1s

sudo apt-get update
sudo apt-get -y install software-properties-common curl wget nano vim rpl sed zip unzip openssl expect dirmngr apt-transport-https lsb-release ca-certificates dnsutils dos2unix zsh htop ffmpeg


# GET IP
clear
clear
echo "${bggreen}${black}${bold}"
echo "Getting IP..."
echo "${reset}"
sleep 1s

IP=$(curl -s https://checkip.amazonaws.com)


# MOTD WELCOME MESSAGE
clear
echo "${bggreen}${black}${bold}"
echo "Motd settings..."
echo "${reset}"
sleep 1s

WELCOME=/etc/motd
sudo touch $WELCOME
sudo cat > "$WELCOME" <<EOF


        ____  _   _ ____  _____
       |  _ \| | | |  _ \| ____|
       | |_) | | | | |_) |  _|
       |  __/| |_| |  _ <| |___
       |_|    \___/|_| \_\_____|
       
EOF



# SWAP
clear
echo "${bggreen}${black}${bold}"
echo "Memory SWAP..."
echo "${reset}"
sleep 1s

sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
sudo /sbin/mkswap /var/swap.1
sudo /sbin/swapon /var/swap.1



# ALIAS
clear
echo "${bggreen}${black}${bold}"
echo "Custom CLI configuration..."
echo "${reset}"
sleep 1s

shopt -s expand_aliases
alias ll='ls -alF'



# PURE DIRS
clear
echo "${bggreen}${black}${bold}"
echo "PURE directories..."
echo "${reset}"
sleep 1s

sudo mkdir /etc/pure/
sudo chmod o-r /etc/pure
sudo mkdir /var/pure/
sudo chmod o-r /var/pure



# USER
clear
echo "${bggreen}${black}${bold}"
echo "PURE root user..."
echo "${reset}"
sleep 1s

sudo pam-auth-update --package
sudo mount -o remount,rw /
sudo chmod 640 /etc/shadow
sudo useradd -m -s /bin/bash pure
echo "pure:$PASS"|sudo chpasswd
sudo usermod -aG sudo pure


# NGINX
clear
echo "${bggreen}${black}${bold}"
echo "nginx setup..."
echo "${reset}"
sleep 1s

sudo apt-get -y install nginx-core
sudo systemctl start nginx.service
sudo rpl -i -w "http {" "http { limit_req_zone \$binary_remote_addr zone=one:10m rate=1r/s; fastcgi_read_timeout 300;" /etc/nginx/nginx.conf
sudo rpl -i -w "http {" "http { limit_req_zone \$binary_remote_addr zone=one:10m rate=1r/s; fastcgi_read_timeout 300;" /etc/nginx/nginx.conf
sudo systemctl enable nginx.service





# FIREWALL
clear
echo "${bggreen}${black}${bold}"
echo "fail2ban setup..."
echo "${reset}"
sleep 1s

sudo apt-get -y install fail2ban
JAIL=/etc/fail2ban/jail.local
sudo unlink JAIL
sudo touch $JAIL
sudo cat > "$JAIL" <<EOF
[DEFAULT]
bantime = 3600
banaction = iptables-multiport
[sshd]
enabled = true
logpath  = /var/log/auth.log
EOF
sudo systemctl restart fail2ban
sudo ufw --force enable
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow "Nginx Full"




# PHP
clear
echo "${bggreen}${black}${bold}"
echo "PHP setup..."
echo "${reset}"
sleep 1s


sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update

sudo apt-get -y install php7.4-fpm
sudo apt-get -y install php7.4-common
sudo apt-get -y install php7.4-curl
sudo apt-get -y install php7.4-openssl
sudo apt-get -y install php7.4-bcmath
sudo apt-get -y install php7.4-mbstring
sudo apt-get -y install php7.4-tokenizer
sudo apt-get -y install php7.4-mysql
sudo apt-get -y install php7.4-sqlite3
sudo apt-get -y install php7.4-pgsql
sudo apt-get -y install php7.4-redis
sudo apt-get -y install php7.4-memcached
sudo apt-get -y install php7.4-json
sudo apt-get -y install php7.4-zip
sudo apt-get -y install php7.4-xml
sudo apt-get -y install php7.4-soap
sudo apt-get -y install php7.4-gd
sudo apt-get -y install php7.4-imagick
sudo apt-get -y install php7.4-fileinfo
sudo apt-get -y install php7.4-imap
sudo apt-get -y install php7.4-cli
PHPINI=/etc/php/7.4/fpm/conf.d/pure.ini
sudo touch $PHPINI
sudo cat > "$PHPINI" <<EOF
memory_limit = 256M
upload_max_filesize = 256M
post_max_size = 256M
max_execution_time = 180
max_input_time = 180
EOF
sudo service php7.4-fpm restart

sudo apt-get -y install php8.0-fpm
sudo apt-get -y install php8.0-common
sudo apt-get -y install php8.0-curl
sudo apt-get -y install php8.0-openssl
sudo apt-get -y install php8.0-bcmath
sudo apt-get -y install php8.0-mbstring
sudo apt-get -y install php8.0-tokenizer
sudo apt-get -y install php8.0-mysql
sudo apt-get -y install php8.0-sqlite3
sudo apt-get -y install php8.0-pgsql
sudo apt-get -y install php8.0-redis
sudo apt-get -y install php8.0-memcached
sudo apt-get -y install php8.0-json
sudo apt-get -y install php8.0-zip
sudo apt-get -y install php8.0-xml
sudo apt-get -y install php8.0-soap
sudo apt-get -y install php8.0-gd
sudo apt-get -y install php8.0-imagick
sudo apt-get -y install php8.0-fileinfo
sudo apt-get -y install php8.0-imap
sudo apt-get -y install php8.0-cli
PHPINI=/etc/php/8.0/fpm/conf.d/pure.ini
sudo touch $PHPINI
sudo cat > "$PHPINI" <<EOF
memory_limit = 256M
upload_max_filesize = 256M
post_max_size = 256M
max_execution_time = 180
max_input_time = 180
EOF
sudo service php8.0-fpm restart

sudo apt-get -y install php8.1-fpm
sudo apt-get -y install php8.1-common
sudo apt-get -y install php8.1-curl
sudo apt-get -y install php8.1-openssl
sudo apt-get -y install php8.1-bcmath
sudo apt-get -y install php8.1-mbstring
sudo apt-get -y install php8.1-tokenizer
sudo apt-get -y install php8.1-mysql
sudo apt-get -y install php8.1-sqlite3
sudo apt-get -y install php8.1-pgsql
sudo apt-get -y install php8.1-redis
sudo apt-get -y install php8.1-memcached
sudo apt-get -y install php8.1-json
sudo apt-get -y install php8.1-zip
sudo apt-get -y install php8.1-xml
sudo apt-get -y install php8.1-soap
sudo apt-get -y install php8.1-gd
sudo apt-get -y install php8.1-imagick
sudo apt-get -y install php8.1-fileinfo
sudo apt-get -y install php8.1-imap
sudo apt-get -y install php8.1-cli
PHPINI=/etc/php/8.1/fpm/conf.d/pure.ini
sudo touch $PHPINI
sudo cat > "$PHPINI" <<EOF
memory_limit = 256M
upload_max_filesize = 256M
post_max_size = 256M
max_execution_time = 180
max_input_time = 180
EOF
sudo service php8.1-fpm restart

sudo apt-get -y install php8.2-fpm php8.2-common php8.2-curl php8.2-bcmath php8.2-mbstring php8.2-tokenizer php8.2-mysql php8.2-sqlite3 php8.2-pgsql php8.2-redis php8.2-memcached php8.2-zip php8.2-xml php8.2-soap php8.2-gd php8.2-imagick php8.2-fileinfo php8.2-imap php8.2-cli
PHPINI=/etc/php/8.2/fpm/conf.d/pure.ini
sudo touch $PHPINI
sudo cat > "$PHPINI" <<EOF
memory_limit = 256M
upload_max_filesize = 256M
post_max_size = 256M
max_execution_time = 180
max_input_time = 180
EOF
sudo service php8.2-fpm restart

# PHP EXTRA
sudo apt-get -y install php-dev php-pear


# PHP CLI
clear
echo "${bggreen}${black}${bold}"
echo "PHP CLI configuration..."
echo "${reset}"
sleep 1s

sudo update-alternatives --set php /usr/bin/php8.2



# COMPOSER
clear
echo "${bggreen}${black}${bold}"
echo "Composer setup..."
echo "${reset}"
sleep 1s

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --no-interaction
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer
composer config --global repo.packagist composer https://packagist.org --no-interaction




# GIT
clear
echo "${bggreen}${black}${bold}"
echo "GIT setup..."
echo "${reset}"
sleep 1s

sudo apt-get -y install git
sudo ssh-keygen -t rsa -C "git@github.com" -f /etc/pure/github -q -P ""



# SUPERVISOR
clear
echo "${bggreen}${black}${bold}"
echo "Supervisor setup..."
echo "${reset}"
sleep 1s

sudo apt-get -y install supervisor
service supervisor restart



# DEFAULT VHOST
clear
echo "${bggreen}${black}${bold}"
echo "Default vhost..."
echo "${reset}"
sleep 1s

NGINX=/etc/nginx/sites-available/default
if test -f "$NGINX"; then
    sudo unlink NGINX
fi
sudo touch $NGINX
sudo cat > "$NGINX" <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/public;
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";
    client_body_timeout 10s;
    client_header_timeout 10s;
    client_max_body_size 256M;
    index index.html index.php;
    charset utf-8;
    server_tokens off;
    location / {
        try_files   \$uri     \$uri/  /index.php?\$query_string;
    }
    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }
    error_page 404 /index.php;
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF
sudo mkdir /etc/nginx/pure/
sudo systemctl restart nginx.service





# MYSQL
clear
echo "${bggreen}${black}${bold}"
echo "MySQL setup..."
echo "${reset}"
sleep 1s


sudo apt-get install -y mysql-server
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Press y|Y for Yes, any other key for No:\"
send \"n\r\"
expect \"New password:\"
send \"$DBPASS\r\"
expect \"Re-enter new password:\"
send \"$DBPASS\r\"
expect \"Remove anonymous users? (Press y|Y for Yes, any other key for No)\"
send \"y\r\"
expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No)\"
send \"n\r\"
expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No)\"
send \"y\r\"
expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) \"
send \"y\r\"
expect eof
")
echo "$SECURE_MYSQL"
/usr/bin/mysql -u root -p$DBPASS <<EOF
use mysql;
CREATE USER 'pure'@'%' IDENTIFIED WITH mysql_native_password BY '$DBPASS';
GRANT ALL PRIVILEGES ON *.* TO 'pure'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF



# REDIS
clear
echo "${bggreen}${black}${bold}"
echo "Redis setup..."
echo "${reset}"
sleep 1s

sudo apt install -y redis-server
sudo rpl -i -w "supervised no" "supervised systemd" /etc/redis/redis.conf
sudo systemctl restart redis.service



# LET'S ENCRYPT
clear
echo "${bggreen}${black}${bold}"
echo "Let's Encrypt setup..."
echo "${reset}"
sleep 1s

sudo apt-get install -y certbot
sudo apt-get install -y python3-certbot-nginx



# NODE
clear
echo "${bggreen}${black}${bold}"
echo "Node/npm setup..."
echo "${reset}"
sleep 1s

curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
curl -sL https://deb.nodesource.com/setup16.x | sudo -E bash -
NODE=/etc/apt/sources.list.d/nodesource.list
sudo unlink NODE
sudo touch $NODE
sudo cat > "$NODE" <<EOF
deb https://deb.nodesource.com/node_16.x focal main
deb-src https://deb.nodesource.com/node_16.x focal main
EOF
sudo apt-get update
sudo apt -y install nodejs
sudo apt -y install npm




#PANEL INSTALLATION
clear
echo "${bggreen}${black}${bold}"
echo "Panel installation..."
echo "${reset}"
sleep 1s


/usr/bin/mysql -u root -p$DBPASS <<EOF
CREATE DATABASE IF NOT EXISTS pure;
EOF
clear
sudo rm -rf /var/www
mkdir /var/www
cd /var/www && git clone https://github.com/$REPO.git .
cd /var/www && sudo cp .env-example .env

sudo rpl -i -w "DB_PASSWORD=pure" "DB_PASSWORD=$DBPASS" /var/www/.env
sudo rpl -i -w "APP_URL=http://localhost" "APP_URL=http://$IP" /var/www/.env



sudo chmod -R o+w /var/www/storage
sudo chmod -R 777 /var/www/storage
sudo chmod -R o+w /var/www/bootstrap/cache
sudo chmod -R 777 /var/www/bootstrap/cache
cd /var/www && composer update --no-interaction
cd /var/www && php artisan install --ready
cd /var/www && php artisan servers:update_server_credentials "" $IP  $PASS $DBPASS

PUBKEYGH=/var/www/public/ghkey_$SERVERID.php
sudo touch $PUBKEYGH
sudo cat > $PUBKEYGH <<EOF
<?php
echo exec("cat /etc/pure/github.pub");
EOF
sudo chmod -R o+w /var/www/storage
sudo chmod -R 775 /var/www/storage
sudo chmod -R o+w /var/www/bootstrap/cache
sudo chmod -R 775 /var/www/bootstrap/cache
sudo chown -R www-data:pure /var/www

clear
echo "${bggreen}${black}${bold}"
echo "Installing PhpMyAdmin 5.2.1 ..."
echo "${reset}"
sleep 1s

# Install PhpMyAdmin
cd /var/www/public && wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip
cd /var/www/public && unzip phpMyAdmin-5.2.1-all-languages.zip
rm -rf /var/www/public/phpMyAdmin-5.2.1-all-languages.zip
mv /var/www/public/phpMyAdmin-5.2.1-all-languages/ /var/www/public/pma


# LAST STEPS
clear
echo "${bggreen}${black}${bold}"
echo "Last steps..."
echo "${reset}"
sleep 1s

sudo chown www-data:pure -R /var/www
sudo chmod -R 750 /var/www
sudo echo 'DefaultStartLimitIntervalSec=1s' >> /usr/lib/systemd/system/user@.service
sudo echo 'DefaultStartLimitBurst=50' >> /usr/lib/systemd/system/user@.service
sudo echo 'StartLimitBurst=0' >> /usr/lib/systemd/system/user@.service
sudo systemctl daemon-reload

TASK=/etc/cron.d/pure.crontab
touch $TASK
cat > "$TASK" <<EOF
10 4 * * 7 certbot renew --nginx --non-interactive --post-hook "systemctl restart nginx.service"
20 4 * * 7 apt-get -y update
40 4 * * 7 DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical sudo apt-get -q -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" dist-upgrade
20 5 * * 7 apt-get clean && apt-get autoclean
50 5 * * * echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a
* * * * * cd /var/www && php artisan schedule:run >> /dev/null 2>&1
5 2 * * * cd /var/www/utility/pure-update && sh run.sh >> /dev/null 2>&1
EOF
crontab $TASK
sudo systemctl restart nginx.service
sudo rpl -i -w "#PasswordAuthentication" "PasswordAuthentication" /etc/ssh/sshd_config
sudo rpl -i -w "# PasswordAuthentication" "PasswordAuthentication" /etc/ssh/sshd_config
sudo rpl -i -w "PasswordAuthentication no" "PasswordAuthentication yes" /etc/ssh/sshd_config
sudo rpl -i -w "PermitRootLogin yes" "PermitRootLogin no" /etc/ssh/sshd_config
sudo service sshd restart
TASK=/etc/supervisor/conf.d/pure.conf
touch $TASK
cat > "$TASK" <<EOF
[program:pure-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/artisan queue:work --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=pure
numprocs=1
redirect_stderr=true
stdout_logfile=/var/www/worker.log
EOF
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start all
sudo service supervisor restart

# COMPLETE
clear
echo "${bggreen}${black}${bold}"
echo "Pure installation has been completed..."
echo "${reset}"
sleep 1s




# SETUP COMPLETE MESSAGE
clear
echo "***********************************************************"
echo "                    SETUP COMPLETE"
echo "***********************************************************"
echo ""
echo " SSH root user: pure"
echo " SSH root pass: $PASS"
echo " MySQL root user: pure"
echo " MySQL root pass: $DBPASS"
echo ""
echo " To manage your server visit: http://$IP/admin"
echo " Default credentials are: admin@example.com / admin"
echo ""
echo "***********************************************************"
echo "          DO NOT LOSE AND KEEP SAFE THIS DATA"
echo "***********************************************************"
