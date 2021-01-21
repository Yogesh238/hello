#!/bin/bash
sudo yum install httpd
read -p 'enter key name ' name
sudo openssl genrsa -des3 -out $name.key 1024
sudo openssl req -new -key $name.key -out $name.csr
sudo cp $name.key $name.key.org
sudo openssl rsa -in $name.key.org -out $name.key 
sudo openssl x509 -req -days 365 -in $name.csr -signkey $name.key -out $name.crt
sudo mv $name.* /etc/pki/tls/certs/
sudo yum install -y mod_ssl
read -p 'enter conf file name ' var
read -p 'enter ServerName ' servern
read -p 'enter server alias ' server
read -p 'enter ip for proxypass' ip
sudo touch $var
sudo chmod 666 $var
echo "<VirtualHost *:443>" >>$var
echo "       ServerAdmin webmaster@localhost">>$var
echo "       ServerName " $servern>>$var
echo "       ServerAlias " $server>>$var
echo "       DocumentRoot /var/www/html/">>$var
echo "       ">>$var
echo "       SSLEngine on">>$var
echo "       SSLCertificateFile /etc/pki/tls/certs/"$name.crt>>$var
echo "       SSLCertificateKeyFile /etc/pki/tls/certs/"$name.key>>$var
echo "       ">>$var
echo "       ProxyPass / http://"$ip":8080/">>$var
echo "       ProxyPassReverse / http://"$ip":8080/">>$var
echo "</VirtualHost>">>$var
sudo chmod 666 /etc/httpd/conf.d/$var.conf
sudo cp $var /etc/httpd/conf.d/$var.conf
sudo chmod 644 /etc/httpd/conf.d/$var.conf
sudo chmod 666 /etc/hosts
read -p "enter public ip " public
echo $public ' '$servern>>/etc/hosts
sudo chmod 644 /etc/hosts
read -p "enter html filename" html 
sudo touch /var/www/html/$html
sudo chmod 666 /var/www/html/$html
echo "<html>">>/var/www/html/$html
echo "<body>">>/var/www/html/$html
echo "hlo ">>/var/www/html/$html
echo "</body>">>/var/www/html/$html
echo "</html>">>/var/www/html/$html
sudo ssh -i /home/ec2-user/pvt ec2-user@172.31.0.41 sudo yum install java
sudo ssh -i /home/ec2-user/pvt ec2-user@172.31.0.41 sudo wget https://mirrors.estointernet.in/apache/tomcat/tomcat-8/v8.5.61/bin/apache-tomcat-8.5.61.tar.gz
sudo ssh -i /home/ec2-user/pvt ec2-user@172.31.0.41 sudo tar -xzf apache-tomcat-8.5.61.tar.gz
sudo ssh -i /home/ec2-user/pvt ec2-user@172.31.0.41 sudo wget https://get.jenkins.io/war/2.272/jenkins.war
sudo ssh -i /home/ec2-user/pvt ec2-user@172.31.0.41 sudo chmod 766 /home/ec2-user/apache-tomcat-8.5.61/webapps
sudo ssh -i /home/ec2-user/pvt ec2-user@172.31.0.41 sudo mv /home/ec2-user/jenkins.war /home/ec2-user/apache-tomcat-8.5.61/webapps
 
