#!/bin/bash
read -p "enter cidr value for vpc: " cidr
read -p "enter name for vpc: " value
vpcid=`aws ec2 create-vpc --cidr-block $cidr --query Vpc.VpcId --output text`
aws ec2 create-tags --resources $vpcid --tags Key=Name,Value=$value
read -p "enter name for public subnet: " names
read -p "enter cidr value for subnet 1: " subn
read -p "enter availability zone: " south
sub=`aws ec2 create-subnet --vpc-id $vpcid --cidr-block $subn --availability-zone $south --query Subnet.SubnetId --output text`
aws ec2 create-tags --resources $sub --tags Key=Name,Value=$names
read -p "enter name for private subnet: " namesp
read -p "enter cidr value for subnet 2: " subt
sut=`aws ec2 create-subnet --vpc-id $vpcid --cidr-block $subt --availability-zone $south --query Subnet.SubnetId --output text`
aws ec2 create-tags --resources $sut --tags Key=Name,Value=$namesp
read -p "enter igw name: " igwna
igw=`aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text` 
aws ec2 create-tags --resources $igw --tags Key=Name,Value=$igwna
aws ec2 attach-internet-gateway --vpc-id $vpcid --internet-gateway-id $igw
routeid=`aws ec2 create-route-table --vpc-id $vpcid --query RouteTable.RouteTableId --output text`
aws ec2 create-route --route-table-id $routeid --destination-cidr-block 0.0.0.0/0 --gateway-id $igw
aws ec2 associate-route-table  --subnet-id $sub --route-table-id $routeid
read -p "enter key name: " kname
aws ec2 create-key-pair --key-name $kname --query 'KeyMaterial' --output text > $kname
chmod 400 $kname 
read -p "enter name for nat security group: " natn
groupid=`aws ec2 create-security-group --group-name $natn --description "Security group for Nat instance" --vpc-id $vpcid --query GroupId --output text` 
read -p "enter image id for nat instance: " ami 
read -p "enter instance-type for nat instance: " micro
aws ec2 run-instances --image-id $ami --count 1 --instance-type $micro --key-name $kname --security-group-ids $groupid --subnet-id $sub --associate-public-ip-address 
read -p "enter nat instance id: " natid
aws ec2 modify-instance-attribute --instance-id $natid --no-source-dest-check
read -p "enter name for natinstance: " vnat
aws ec2 create-tags --resources $natid --tags Key=Name,Value=$vnat
rid=`aws ec2 create-route-table --vpc-id $vpcid --query RouteTable.RouteTableId --output text`
aws ec2 create-route --route-table-id $rid --destination-cidr-block 0.0.0.0/0 --instance-id $natid
aws ec2 associate-route-table  --subnet-id $sut --route-table-id $rid
read -p "enter name for public security group: " pubsg
pubgroup=`aws ec2 create-security-group --group-name $pubsg --description "Security group for public instance" --vpc-id $vpcid --query GroupId --output text`
echo "enter security group rules for public instance"
aws ec2 describe-instances --filters "Name=instance-id,Values="$natid --query 'Reservations[*].Instances[*].[SecurityGroups[*].[GroupId]]' --output text
read -p "want to enter security rule(public ins) with source group, enter '0': " opt
i=$opt
while [ $i -eq 0 ]
do
	read -p "enter protocol: " prot
	read -p "enter port no: " port
	read -p "enter source group: " ci
	aws ec2 authorize-security-group-ingress --group-id $pubgroup --protocol $prot --port $port --source-group $ci
	read -p "want to enter more security groups enter '0': " new
	i=$new
done
read -p "want to enter security rule (public ins) with cidr, enter '0': " pot
t=$pot
while [ $t -eq 0 ]
do
	read -p "enter protocol: " prots
	read -p "enter port no: " ports
	read -p "enter source cidr: " sourcep
	aws ec2 authorize-security-group-ingress --group-id $pubgroup --protocol $prots --port $ports --cidr $sourcep
	read -p "want to enter more security group, enter '0': " pew
	t=$pew
done
read -p "enter image-id for public instance: " amin
read -p "enter instance-type for public instance: " mic
aws ec2 run-instances --image-id $amin --count 1 --instance-type $mic --key-name $kname --security-group-ids $pubgroup --subnet-id $sub --associate-public-ip-address 
read -p "enter public instance id: " pubid
read -p "enter public ip of public instance: " pubip
##read -p "enter public instance name: " publicn
##aws ec2 create-tags --resources $pubid --tags Key=Name,Value=$publicn
read -p "security group name for private instance: " pgn
pvtgroup=`aws ec2 create-security-group --group-name $pgn --description "Security group for private instance" --vpc-id $vpcid --query GroupId --output text`
echo "enter security group rules for private instnace"
echo "security group of nat ins: "
aws ec2 describe-instances --filters "Name=instance-id,Values="$natid --query 'Reservations[*].Instances[*].[SecurityGroups[*].[GroupId]]' --output text
echo "security group of public ins: "
aws ec2 describe-instances --filters "Name=instance-id,Values="$pubid --query 'Reservations[*].Instances[*].[SecurityGroups[*].[GroupId]]' --output text
read -p "want to enter security rules(private ins) with source group, enter '0': " ten
q=$ten
while [ $q -eq 0 ]
do
	read -p "enter protcol: " pprot
	read -p "enter port no: " pport
	read -p "enter source group: " dr
	aws ec2 authorize-security-group-ingress --group-id $pvtgroup --protocol $pprot --port $pport --source-group $dr
	read -p "want to enter more rule, enter '0': " newer
	q=$newer
done
read -p "want to enter security group (private ins) with cidr, enter '0': " eleven
y=$eleven
while [ $y -eq 0 ]
do
	read -p "enter protocal: " protsp
	read -p "enter portno: " portsp
	read -p "enter source cidr: " sourcesp
	aws ec2 authorize-security-group-ingress --group-id $pvtgroup --protocol $protsp --port $portsp --cidr $sourcesp
	read -p "want to enter more rule, enter '0': " newerp
	y=$newerp
done
read -p "enter image-id for private instance: " pami
read -p "enter instance type for private instance: " inst
aws ec2 run-instances --image-id $pami --count 1 --instance-type $inst --key-name $kname --security-group-ids $pvtgroup --subnet-id $sut
read -p "enter private instance id: " pvtid
read -p "enter private ip of private instance: " pvtip
##read -p "enter private instance name: " privaten
##aws ec2 create-tags --resources $pvtid --tags Key=Name,Value=$privaten
echo "enter security group for nat instance"
aws ec2 describe-instances --filters "Name=instance-id,Values="$pvtid --query 'Reservations[*].Instances[*].[SecurityGroups[*].[GroupId]]' --output text
read -p "want to enter security rule (for nat ins) with source group, enter '0': " twelve
w=$twelve
while [ $w -eq 0 ]
do
	read -p "enter protocol: " col
	read -p "enter port: " ort
	read -p "enter source group: " dir
	aws ec2 authorize-security-group-ingress --group-id $groupid --protocol $col --port $ort --source-group $dir
        read -p "want to enter more rules, enter '0': " whjk
	w=$whjk
done
read -p "want to enter security rule (for nat ins) with cidr, enter '0': " thirt
l=$thirt
while [ $l -eq 0 ]
do
	read -p "enter protocol: " coln
	read -p "enter port no: " ortn
	read -p "enter source cidr: " dirn
	aws ec2 authorize-security-group-ingress --group-id $groupid --protocol $coln --port $ortn --cidr $dirn
	read -p "want to enter more rules, enter '0': " whjkn
	l=$whjkn
done
#read -p "enter public ip: " pubip
ssh -i $knmae ec2-user@$pubip
scp -i $kname $kname ec2-user@$pubip:/home/ec2-user/
ssh -i $kname ec2-user@$pubip sudo yum install httpd
read -p 'enter key name: ' name
read -p 'enter key.org name: ' orna
ssh -i $kname ec2-user@$pubip sudo openssl genrsa -des3 -out $name.key 1024
ssh -i $kname ec2-user@$pubip sudo openssl req -new -key $name.key -out $name.csr
ssh -i $kname ec2-user@$pubip sudo cp $name.key $orna.key.org
ssh -i $kname ec2-user@$pubip sudo openssl rsa -in $orna.key.org -out $name.key
ssh -i $kname ec2-user@$pubip sudo openssl x509 -req -days 365 -in $name.csr -signkey $name.key -out $name.crt
ssh -i $kname ec2-user@$pubip sudo mv $name.* /etc/pki/tls/certs/
ssh -i $kname ec2-user@$pubip sudo mv $orna.* /etc/pki/tls/certs/
ssh -i $kname ec2-user@$pubip sudo yum install -y mod_ssl
read -p 'enter conf file name: ' var
read -p 'enter ServerName: ' servern
read -p 'enter server alias: ' server
ssh -i $kname ec2-user@$pubip sudo touch $var
ssh -i $kname ec2-user@$pubip sudo chmod 666 $var
ssh -i $kname ec2-user@$pubip "echo '<VirtualHost *:443>' >>$var"
ssh -i $kname ec2-user@$pubip "echo '       ServerAdmin webmaster@localhost'>>$var"
ssh -i $kname ec2-user@$pubip "echo '       ServerName ' $servern>>$var"
ssh -i $kname ec2-user@$pubip "echo '       ServerAlias ' $server>>$var"
ssh -i $kname ec2-user@$pubip "echo '       DocumentRoot /var/www/html/'>>$var"
ssh -i $kname ec2-user@$pubip "echo '       '>>$var"
ssh -i $kname ec2-user@$pubip "echo '       SSLEngine on'>>$var"
ssh -i $kname ec2-user@$pubip "echo '       SSLCertificateFile /etc/pki/tls/certs/'$name.crt>>$var"
ssh -i $kname ec2-user@$pubip "echo '       SSLCertificateKeyFile /etc/pki/tls/certs/'$name.key>>$var"
ssh -i $kname ec2-user@$pubip "echo '       '>>$var"
ssh -i $kname ec2-user@$pubip "echo '       ProxyPass / http://'$pvtip':8080/'>>$var"
ssh -i $kname ec2-user@$pubip "echo '       ProxyPassReverse / http://'$pvtip':8080/'>>$var"
ssh -i $kname ec2-user@$pubip "echo '</VirtualHost>'>>$var"
ssh -i $kname ec2-user@$pubip sudo touch /etc/httpd/conf.d/$var.conf
ssh -i $kname ec2-user@$pubip sudo chmod 666 /etc/httpd/conf.d/$var.conf
ssh -i $kname ec2-user@$pubip sudo cp $var /etc/httpd/conf.d/$var.conf
ssh -i $kname ec2-user@$pubip sudo chmod 644 /etc/httpd/conf.d/$var.conf
ssh -i $kname ec2-user@$pubip sudo chmod 666 /etc/hosts
ssh -i $kname ec2-user@$pubip "echo $pubip ' '$servern>>/etc/hosts"
ssh -i $kname ec2-user@$pubip sudo chmod 644 /etc/hosts
read -p "enter html filename" html
ssh -i $kname ec2-user@$pubip sudo touch /var/www/html/$html
ssh -i $kname ec2-user@$pubip sudo chmod 777 /var/www/html/$html
ssh -i $kname ec2-user@$pubip "echo '<html>'>>/var/www/html/$html"
ssh -i $kname ec2-user@$pubip "echo '<body>'>>/var/www/html/$html"
ssh -i $kname ec2-user@$pubip "echo 'hlo '>>/var/www/html/$html"
ssh -i $kname ec2-user@$pubip "echo '</body>'>>/var/www/html/$html"
ssh -i $kname ec2-user@$pubip "echo '</html>'>>/var/www/html/$html"
ssh -i $kname ec2-user@$pubip sudo ssh -o StrictHostKeyChecking=no ec2-user@$pvtip
# ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo yum update
# sleep 10s 
# ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.rpm

 ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo yum install java
 ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo wget https://mirrors.estointernet.in/apache/tomcat/tomcat-8/v8.5.61/bin/apache-tomcat-8.5.61.tar.gz
 ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo tar -xzf apache-tomcat-8.5.61.tar.gz
 ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo wget https://get.jenkins.io/war/2.272/jenkins.war
 ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo chmod 766 /home/ec2-user/apache-tomcat-8.5.61/webapps
 ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo mv /home/ec2-user/jenkins.war /home/ec2-user/apache-tomcat-8.5.61/webapps
 ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo chmod 766 /home/ec2-user/apache-tomcat-8.5.61/bin
 ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo sh /home/ec2-user/apache-tomcat-8.5.61/bin/startup.sh
 ssh -i $kname ec2-user@$pubip sudo systemctl start httpd
