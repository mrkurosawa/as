read -p "Enter SSL port name: " portnum
[[ -z "$portnum" ]] && { echo "SSL port cannot be empty" ; exit 1; }

ifconfig | grep 'Bcast'

sudo apt-get install -y apache2 ufw && sudo a2enmod ssl proxy proxy_http && sudo mkdir -p /etc/apache2/ssl && sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt

innerportnum=$(expr $portnum - 2000)
sed -E -i 's/(\#LogLevel info ssl\:warn)/\1 \n\n\t\tProxyPreserveHost On\n\t\tProxyPass \/ http:\/\/127\.0\.0\.1\:'$innerportnum'\/\n\t\tProxyPassReverse \/ http\:\/\/127\.0\.0\.1\:'$innerportnum'\//' /etc/apache2/sites-available/default-ssl.conf
sed -E -i 's/(VirtualHost _default_\:)443/\1'$portnum'/' /etc/apache2/sites-available/default-ssl.conf
sed -E -i 's/SSLCertificateFile.+$/SSLCertificateFile\t\/etc\/apache2\/ssl\/apache\.crt/' /etc/apache2/sites-available/default-ssl.conf
sed -E -i 's/SSLCertificateKeyFile.+$/SSLCertificateKeyFile\t\/etc\/apache2\/ssl\/apache\.key/' /etc/apache2/sites-available/default-ssl.conf
sed -E -i 's/Listen 443/# Listen 443\n\tListen '$portnum'/' /etc/apache2/ports.conf

sudo a2ensite default-ssl && sudo service apache2 restart

sudo ufw allow ssh && sudo ufw allow from $1 to any && sudo ufw enable

date +%s | sha256sum | base64 | head -c 32 ; echo
sudo ufw status
