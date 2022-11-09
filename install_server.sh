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
	
	# pare-feu commenté car cause des problèmes avec le HTTPS plus tard
	#ufw allow 'Nginx HTTP'
	#ufw allow 'OpenSSH'
	#ufw enable

	# clone le repo Laravel dans Nginx pour pouvoir s'y référer dans le fichier de config serveur
	cd /var/www/html
	git clone https://github.com/laravel/laravel.git
	# Copie le fichier de config server pour l'hotel-arth dans nginx
	scp /home/romain/Code/deploiement/hotel-arth root@$1:/etc/nginx/sites-available/
	# Crée un lien symbolique de sites available vers sites enabled pour que ça puisse marcher
	ln -s /etc/nginx/sites-available/hotel-arth /etc/nginx/sites-enabled/hotel-arth
	# test nginx
	nginx -t
	# le restart pour mettre à jour la config
	systemctl restart nginx

	# on installe tranquillement Laravel
	cd laravel
	git checkout 8.x
	composer -n install
	# copier-coller du fichier .env modifé pour permettre la commande php artisan serve
	scp /home/romain/Code/deploiement/.env root@$1:/var/www/html/laravel/
	
#else
#  echo "Le paramètre doit être une adresse IP valide. Bisous."
#  exit
#fi
