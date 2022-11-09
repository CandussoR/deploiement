# Déploiement

# Scaleway
- Se créer une clé SSH à partir de la [docu de Scaleway](https://www.scaleway.com/en/docs/console/my-project/how-to/create-ssh-key)
- Pour installer Scaleway CLI:
  - cf [la doc](https://github.com/scaleway/scaleway-cli/)
  - api key: SCWJ1RVTMV9G6D0V7MJ4
  - secret key: c98c853c-04de-44c0-89b3-5f58db73600a
- Pour initialiser le VPS via la ligne de commande :
  ```
  scw instance server create type=PLAY2-PICO zone=fr-par-1 image=ubuntu_jammy root-volume=b:10G additional-volumes.0=b:10G name=Roro-dev ip=new project-id=f7cfc317-a399-4804-b3bf-9e55f4ce842c
  ```
- Depuis la ligne de commande, on peut par exemple lister tous les serveurs d'une instance :
  ```
  scw instance server list
  ```
  - On peut se reférer à l'aide de manière générale avec `scw -h`
- Pour se connecter en SSH à son instance:
  ```
  ssh -i ~/.ssh/<fichier_clé_ssh> root@<ip_instance>
  ```
- Pour supprimer un serveur :
  ```
  scw instance server terminate <id_instance>
  ```

## Installation de packages depuis la ligne de commande
- Doc pour [lancer des commandes en ssh](https://www.ssh.com/academy/ssh/command#ssh-command-in-linux)
- Doc de Scaleway pour installer [LEMP](https://www.scaleway.com/en/docs/tutorials/installation-lemp-ubuntu-focal/)
  - Autre doc chez DigitalOcean :
    - [install LEMP](https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-in-ubuntu-16-04)
    - set [nginx server block](https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-server-blocks-virtual-hosts-on-ubuntu-16-04)

## Se connecter en ssh et lancer un script
- Se connecter en ssh:
  ```
  ssh root@<instance_ip>
  ```
  Si on est déjà superuser, `ssh <instance_ip>` fonctionne.
- Exécuter un script en ssh :
  ```
  ssh root@<instance_ip> bash < nom_ficher
  ```
  - Rappel :
    - Copier le contenu d'un fichier sur un autre :
      ```
      fichier_base > fichier_copie
      ```
    - Copier un fichier d'un ordi à un autre, avec scp :
      ```
      scp user@ip:source destination
      ```
    - Rsync, pour synchroniser des repos après calcul des différences
    
## Hébergement, DNS, Certbot et Nginx
- Le nom de domaine s'achète chez un fournisseur (LWS, pour nous)
  - LWS nous permet dans son interface de changer l'IP à laquelle renvoie le nom de domaine.
    - L'enregistrement DNS de type A est celle qui pointe l'adresse IP au nom de domaine.
    - L'enregistrement CNAME permet de spécifier qu'un nom de domaine est un alias pour un autre domaine.
- **Il vaut mieux désactivier le pare-feu ufw avant de commencer les manips de redirection vers du HTTPS, car ufw le bloque.**
- Il existe plusieurs manière d'encrypter un serveur pour avoir une adresse HTTPS.
  - LWS ne permet de certifier l'encryption qu'avec l'adresse qui nous est initialement fournie. Puisqu'on l'a changé pour l'associer à l'IP de notre instance sur Scaleway, on doit procéder d'une autre façon.
  - On utilise donc [certbot](https://certbot.eff.org/) pour créer une certification de sécurité.
    - Comme Certbot ne dispose pas de plugins permettant une installation facile avec CertBot, on doit y aller à la mano :
      - on se connecte en ssh à son instance Scaleway :
        ```
        ssh root@<ip>
        ```
      - on lance la commande certbot (pour linux ici):
        ```
        certbot certonly --manual --classic
        ```
      - quand certbot renvoie une chaîne de caractères et dit de créer un fichier dans l'url spécifiée, il faut :
        - créer le fichier dont le nom doit correspondre à la dernière partie de l'url, avec dedans la chaîne (je l'ai fait sur ma machine locale) ;
        - aller dans le fichier root du site pour créer le début de l'url : 
          ```
          cd /var/www/html/<projet>/public
          mkdir .well-known
          mkdir .well-known/acme-challenges
          ```
        - on ressort de l'instance scaleway pour copier le fichier créé sur la machine locale au bout de l'arborescence qu'on vient de créer :
          ```
          scp /chemin/fichier/créé root@<ip>:/var/www/html/<projet>/public/.well-known/acme-challenges/
          ```
          et une fois fait, après avoir appuyé sur entrée, on devrait avoir confirmation de la création des certificats.
        - On doit ensuite mettre à jour le fichier nginx qui chapeaute la connexion au site :
          ```
          certbot run -a manual -i nginx -d <nomdedomaine.joemama>
          ```
        - On peut alors essayer dans son navigateur de se connecter à son site. S'il ne marche pas; la suite pourra aider. Peut-être.
        - Il semble que certbot crée une redirection https étrange qui fait que des requêtes https sont redirigées vers un 404. On ira donc bien vérifier son fichier de configuration serveur dans `/etc/nginx/sites-available/<nom-fichier>`, qu'on peut modifier d'une façon analogue à la suivante, si besoin :
          ```
          server {
            listen 80 default_server;
            listen [::]:80 default_server;
            root /var/www/html/<repo-laravel>/public;
            server_name <nom de domaine>;

            listen 443 ssl; # managed by Certbot

            add_header X-Frame-Options "SAMEORIGIN";
            add_header X-Content-Type-Options "nosniff";

            index index.php;

            charset utf-8;

            location / {
                try_files $uri $uri/ /index.php?$query_string;
            }

            location = /favicon.ico { access_log off; log_not_found off; }
            location = /robots.txt  { access_log off; log_not_found off; }

            error_page 404 /index.php;

            location ~ \.php$ {
                fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
                fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
                include fastcgi_params;
            }

            location ~ /\.(?!well-known).* {
                deny all;
            }

            # RSA certificate
            ssl_certificate /etc/letsencrypt/live/<nom de domaine>/fullchain.pem; # managed by Certbot
            ssl_certificate_key /etc/letsencrypt/live/<nom de domaine>/privkey.pem; # managed by Certbot
            include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
            ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

            # Redirect non-https traffic to https
            if ($scheme != "https") {
                return 301 https://$host$request_uri;
            } # managed by Certbot
          }
          ```
