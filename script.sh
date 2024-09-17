#!/bin/bash

# Update package lists
sudo apt-get update

# Install necessary packages
sudo apt-get install -y apache2 mariadb-server php php-mysql libapache2-mod-php php-cli php-curl php-zip php-gd php-mbstring php-xml php-soap certbot python3-certbot-apache

# Start Apache and MariaDB services
sudo systemctl start apache2
sudo systemctl start mariadb

# Secure MariaDB installation
sudo mysql_secure_installation <<EOF

y
strongpassword
strongpassword
y
y
y
y
EOF

# Create WordPress database and user
sudo mysql -uroot -pstrongpassword <<EOF
CREATE DATABASE wordpress;
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'wppassword';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

# Download and extract WordPress
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz

# Move WordPress files to /var/www/html/wordpress directory
sudo mkdir -p /var/www/html/wordpress
sudo rsync -av wordpress/ /var/www/html/wordpress/

# Set proper ownership and permissions
sudo chown -R www-data:www-data /var/www/html/wordpress/
sudo find /var/www/html/wordpress/ -type d -exec chmod 755 {} \;
sudo find /var/www/html/wordpress/ -type f -exec chmod 644 {} \;

# Create Apache configuration file for WordPress
sudo tee /etc/apache2/sites-available/wordpress.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerAdmin admin@mounka.net
    DocumentRoot /var/www/html/wordpress
    ServerName mounka.net
    ServerAlias www.mounka.net

    <Directory /var/www/html/wordpress/>
        Options FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Enable WordPress site and rewrite module
sudo a2ensite wordpress.conf
sudo a2enmod rewrite

# Restart Apache to apply changes
sudo systemctl restart apache2

# Install SSL certificate with Certbot
sudo certbot --apache -d mounka.net -d www.mounka.net

# Output message
echo "WordPress installation completed successfully. Please visit https://mounka.net to finish the setup."
