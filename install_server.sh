#!bin/bash

# Bien penser à lancer create_instance d'abord, et récupérer l'IP de l'instance.
# $1 est l'adresse IP
# Le script doit être lancé sur une machine distante avec
# ssh root@ip bash < install_server.sh
# L'adresse ip ci-dessous doit être modifée par celle de l'instance scaleway

ip=51.15.211.31


# À voir plus tard, si tout marche
# if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
# if [ true ];
#  then
	apt -y update && apt -y upgrade
	echo "---------- COMPOSER INSTALL --------------"
	# apt composer install
	curl -sS https://getcomposer.org/installer | php 
 	mv composer.phar /usr/bin/composer
	echo "---------- PHP PLUGINS INSTALL -----------"
	apt install -y php8.1-fpm php-pgsql openssl php-common php-curl php-json php-mbstring php-mysql php-xml php-zip
	echo "---------- UFW / NGINX PLUGINS INSTALL -----------"
	apt install -y ufw nginx
	
	# pare-feu commenté car cause des problèmes avec le HTTPS plus tard
	# ufw allow 'Nginx HTTP'
	# ufw allow 'Nginx HTTPS'
	# ufw allow 'OpenSSH'
	# ufw enable

	# clone le repo Laravel dans Nginx pour pouvoir s'y référer dans le fichier de config serveur
	cd /var/www/html
	echo "---------- CLONING LARAVEL -----------\n"
	git clone https://github.com/laravel/laravel.git

	echo "---------- MOVING SERVER BLOCK CONFIG -----------\n"
	# Déplace le fichier de config server copié pour l'hotel-arth dans nginx
	mv /root/hotel-arth /etc/nginx/sites-available/
	
	echo "---------- MOVING SECURITY FILES ----------------\n"
	# Crée l'arborescence
	mkdir /etc/letsencrypt
	mkdir /etc/letsencrypt/live/
	mkdir /etc/letsencrypt/live/hotel-arth.fr-0001
	
	# Déplace les fichiers sécurisés dans l'arborescence créée
	mv /root/fullchain.pem /etc/letsencrypt/live/hotel-arth.fr-0001/fullchain.pem
	mv /root/privkey.pem /etc/letsencrypt/live/hotel-arth.fr-0001/privkey.pem
	mv /root/options-ssl-nginx.conf /etc/letsencrypt/options-ssl-nginx.conf
	mv /root/ssl-dhparams.pem /etc/letsencrypt/options-ssl-nginx.conf
	
	echo "---------- CREATING SYMBOLIC LINK -----------\n"
	# Crée un lien symbolique de sites available vers sites enabled pour que ça puisse marcher
	ln -s /etc/nginx/sites-available/hotel-arth /etc/nginx/sites-enabled/hotel-arth
	
	
	echo "---------- TESTING NGINX -----------\n"
	# test nginx
	nginx -t
	
	echo "---------- RESTARTING NGINX -----------\n"
	# le restart pour mettre à jour la config
	systemctl restart nginx

	echo "---------- LARAVEL --------------\n"
	# on installe tranquillement Laravel
	cd laravel
	git checkout 8.x
	composer -n install
	# déplace le fichier .env modifé pour permettre la commande php artisan serve
	# mv /root/.env /var/www/html/laravel/
	cp .env.example .env
	
	echo "----------- DONE -----------------\n"
	
#else
#  echo "Le paramètre doit être une adresse IP valide. Bisous."
#  exit
#fi
