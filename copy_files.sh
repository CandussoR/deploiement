#!/bin/bash

#Ce script s'exécute sur la machine locale

ip=51.15.211.31
# Copie le fichier de config server pour l'hotel-arth 
scp /home/romain/Code/deploiement/hotel-arth root@$ip:/root/

# copier-coller du fichier .env modifé pour permettre la commande php artisan serve
scp /home/romain/Code/deploiement/.env root@$ip:/root/

# fichiers contenant les clés du wildcard certificate de sécurité pour le HTTPS
scp /home/romain/Code/deploiement/fullchain.pem root@$ip:/root/
scp /home/romain/Code/deploiement/privkey.pem root@$ip:/root/

# fichier de conf de sécurité qui provoque une erreur s'il n'est pas là
# scp /home/romain/Code/deploiement/options-ssl-nginx.conf root@$ip:/root/

# dernier fichier de conf
# scp /home/romain/Code/deploiement/ssl-dhparams.pem root@$ip:/root/
