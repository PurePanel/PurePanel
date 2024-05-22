cd /var/www && php8.1 /usr/local/bin/composer update -n &
pid1=$!
wait=$pid1
cd /var/www && php8.1 artisan migrate --all-addons --force &
pid2=$!
wait=$pid2
cd /var/www && php8.1 artisan streams:compile &
pid3=$!
wait=$pid3
cd /var/www && php8.1 artisan refresh &
pid4=$!
wait=$pid4
