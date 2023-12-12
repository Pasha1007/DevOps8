#!/bin/bash

# Оновлення пакетів та встановлення apache2
apt update -y
apt install apache2 -y
systemctl start apache2
systemctl enable apache2

# Створення конфігураційного файлу SSL
cat <<EOF > ssl-config.conf
[ req ]
default_bits       = 2048
default_md         = sha256
prompt             = no
encrypt_key        = no
distinguished_name = dn

[ dn ]
C=US
ST=Ohio
L=Cleveland
O=My Organization
OU=My Organizational Unit
emailAddress=my-email@example.com
CN = www.hometask8.com
EOF

# Генерація SSL сертифікату за допомогою openssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt -config ssl-config.conf

# Створення конфігураційного файлу Apache
cat <<EOF > apache-config.conf
<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
</VirtualHost>
EOF

# Застосування конфігурації Apache
sudo cp apache-config.conf /etc/apache2/sites-available/000-default.conf
sudo a2enmod ssl
sudo a2ensite default-ssl
sudo systemctl restart apache2

# Створення стартової веб сторінки
echo "<html><body><h1>Welcome my unprotected web site</h1></body></html>" | sudo tee /var/www/html/index.html