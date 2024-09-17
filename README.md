
### 1. Préparation du Serveur

Connexion au Serveur
```http
  ssh your_user@your_server_ip
```
Mettre à jour les Paquets
```http
  sudo apt-get update sudo apt-get upgrade -y
```

### 2. Installation d’Apache, MariaDB et PHP

Installer Apache, MariaDB et PHP
```http
  sudo apt-get install -y apache2 mariadb-server php php-mysql libapache2-mod-php php-cli php-curl php-zip php-gd php-mbstring php-xml php-soap
```
Démarrer les Services
```http
  sudo systemctl start apache2 sudo systemctl start mariadb
```
### 3. Configurer MariaDB
```http
  sudo mysql_secure_installation
```
Créer une Base de Données et un Utilisateur pour WordPress
```http
  CREATE DATABASE wordpress; 
  CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'wppassword';   
  GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';   
  FLUSH PRIVILEGES; 
  EXIT;
```
### 4. Installer et Configurer WordPress 
Télécharger et Extraire WordPress
```http
  wget https://wordpress.org/latest.tar.gz tar -xzvf latest.tar.gz
```
Déplacer les Fichiers WordPress
```http
  sudo rsync -av wordpress/ /var/www/html/
```
Définir les Permissions
```
  sudo chown -R www-data:www-data /var/www/html/
  sudo find /var/www/html/ -type d -exec chmod 755 {} ;
  sudo find /var/www/html/ -type f -exec chmod 644 {} ;
```
### 5. Configurer Apache pour WordPress
Créer un Fichier de Configuration Apache
```http
  sudo nano /etc/apache2/sites-available/wordpress.conf
```
Ajouter la Configuration 👇🏽 dans wordpress.conf
```
<VirtualHost *:80> 
ServerAdmin admin@mounka.net 
DocumentRoot /var/www/html 
ServerName mounka.net 
ServerAlias www.mounka.net

<Directory /var/www/html/>
    Options FollowSymlinks
    AllowOverride All
    Require all granted
</Directory>

ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
```
Activer le Site et le Module de Réécriture
```
sudo a2ensite wordpress.conf sudo a2enmod rewrite sudo systemctl restart apache2
```
### 6. Configurer SSL avec Certbot
Installer Certbot
```
sudo apt-get install -y certbot python3-certbot-apache
```
Obtenir et Installer le Certificat SSL
```
sudo certbot --apache
```
#### NB :👆🏽 Suivez les instructions pour sélectionner les domaines et installer le certificat.

### 7. Forcer les Redirections HTTP vers HTTPS
Modifier le Fichier .htaccess
```
cd /var/www/html 
sudo nano .htaccess
```
ajoute ceci 👇🏽 dans .htaccess
```
# BEGIN WordPress
<IfModule mod_rewrite.c> 
RewriteEngine On RewriteCond %{HTTPS} off 
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301] </IfModule> 
# END WordPress
```

### 8. Configurer les URLs dans WordPress
Accéder à l’Admin WordPress
#### Connectez-vous à votre tableau de bord WordPress via https://mounka.net/wp-admin. 

Vérifiez les URLs
#### Allez à Réglages > Général et assurez-vous que les URLs sont définies sur https://mounka.net pour Adresse Web de WordPress (URL) et Adresse Web du Site (URL).

### 9. Configurer les Enregistrements DNS
Configurer les Enregistrements DNS
#### Connectez-vous à votre service de gestion DNS (ex : Route 53).

Configurer les Enregistrements A
Type: A 
Nom: mounka.net et www.mounka.net 
Valeur: [Votre adresse IP publique du serveur] 
### 10. Validation 
Accédez à [https://mounka.net] pour vérifier que le site est accessible via HTTPS. 
####Assurez-vous que toutes les redirections fonctionnent correctement et que le certificat SSL est valide. 

Remarques Pour plus d’informations sur la gestion des certificats SSL avec Certbot, consultez la documentation suivantes :

- [Awesome README](https://www.digitalocean.com/community/tutorials/how-to-secure-apache-with-let-s-encrypt-on-ubuntu-20-04-fr)
- [Awesome README](https://youtu.be/8Uofkq718n8?si=49Qmbl8UtRHLUGeB)


Pour résoudre les problèmes liés à l’installation d’Apache, WordPress ou Certbot, vérifiez les journaux des erreurs ou consultez les forums de support.










