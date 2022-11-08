# deploiement

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
