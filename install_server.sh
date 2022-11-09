#!bin/bash

# Bien penser à lancer create_instance d'abord, et récupérer l'IP de l'instance.
# $1 est l'adresse IP

# if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
#if [ true ];
#  then
	apt -y update && apt -y upgrade
	apt -y composer install
	apt install -y php8.1-fpm php-pgsql openssl php-common php-curl php-json php-mbstring php-mysql php-xml php-zip
	apt install -y ufw nginx
	ufw allow 'Nginx HTTP'
	ufw allow 'OpenSSH'
	ufw enable

	scp /home/romain/Code/deploiement/default root@$1:/etc/nginx/sites-available/
	nginx -t
	systemctl restart nginx

	cd /var/www/html
	git clone https://github.com/laravel/laravel.git
	cd laravel
	git checkout 8.x
	composer -n install
	scp /home/romain/Code/deploiement/.env root@$1:/var/www/html/laravel/
	
#else
#  echo "Le paramètre doit être une adresse IP valide. Bisous."
#  exit
#fi
