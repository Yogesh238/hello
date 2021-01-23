#!/bin/bash
echo "Hi, First we are going to make VPC, Subnets, Gateways, Instances and their security groups"
c=0
while [ $c -eq 0 ]
do
      echo "Hi, Enter the names you want for the required fields given below"
      read -p "Enter name for vpc: " value
      read -p "Enter name for public subnet: " names
      read -p "Enter name for private subnet: " namesp
      read -p "Enter Internet Gateway name: " igwna
      read -p "Enter key name (will be used to create Instances): " kname
      read -p "Enter name of Nat Instance: " natname
      read -p "Enter name for Nat Instance security group: " natn
      read -p "Enter name for Public Instance: " pubna
      read -p "Enter name for Public Instance security group: " pubsg
      read -p "Enter name for Private Instance: " pvtna
      read -p "Enter name for Private Instance Security Group: " pgn
      echo "Fields you entered, check is all right"
      echo "VPC name: "$value
      echo "Public Subnet name: "$names
      echo "Private Subnet name: "$namesp
      echo "Internet Gateway name: "$igwna
      echo "Key Name: "$kname
      echo "Nat Instance name: "$natname
      echo "Nat Instance security group name: "$natn
      echo "Public Instance Name: "$pubna
      echo "Public Instance security group name: "$pubsg
      echo "Private Instance name: "$pvtna
      echo "Private Instance name: "$pgn
      read -p "If every field is correctly filled and you want to go on next step then enter '1' or if you want to change then enter '0': " choice
      c=$choice
done
echo "Names for every field successfully filled"
d=0
while [ $d -eq 0 ]
do
      echo "Choose CIDR block for VPC and subnets. Also enter the avaiblity zone"
      read -p "enter cidr value for vpc: " cidr
      read -p "enter cidr value for Public subnet: " subn
      read -p "enter cidr value for Private subnet: " subt
      read -p "enter availability zone: " south
      echo "CIDR for VPC: " $cidr
      echo "CIDR for Public subnet: " $subn
      echo "CIDR for Private subnet: "$subt
      echo "Availability Zone: " $south
      read -p "If above fields are correctly field and want to move next step then enter '1' or if you want to change then enter '0': " choce
      d=$choce
done
read -p "enter image id for nat instance: " ami 
read -p "enter instance-type for nat instance: " micro
read -p "enter image-id for public instance: " amin
read -p "enter instance-type for public instance: " mic
read -p "enter image-id for private instance: " pami
read -p "enter instance type for private instance: " inst
echo "CIDR and Availability Zone fields are successfully filled"
vpcid=`aws ec2 create-vpc --cidr-block $cidr --query Vpc.VpcId --output text`        
aws ec2 create-tags --resources $vpcid --tags Key=Name,Value=$value
echo "VPC successfully created with vpcid: " $vpcid 
sub=`aws ec2 create-subnet --vpc-id $vpcid --cidr-block $subn --availability-zone $south --query Subnet.SubnetId --output text`                  
aws ec2 create-tags --resources $sub --tags Key=Name,Value=$names
echo "Public subnet successfully created with id: " $sub
sut=`aws ec2 create-subnet --vpc-id $vpcid --cidr-block $subt --availability-zone $south --query Subnet.SubnetId --output text`         
aws ec2 create-tags --resources $sut --tags Key=Name,Value=$namesp
echo "Private subnet successfully created with id: " $sut
igw=`aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text`            
aws ec2 create-tags --resources $igw --tags Key=Name,Value=$igwna
aws ec2 attach-internet-gateway --vpc-id $vpcid --internet-gateway-id $igw
echo "Internet gateway successfully created and attached with vpc, IGW id: " $igw
routeid=`aws ec2 create-route-table --vpc-id $vpcid --query RouteTable.RouteTableId --output text`       
aws ec2 create-route --route-table-id $routeid --destination-cidr-block 0.0.0.0/0 --gateway-id $igw
aws ec2 associate-route-table  --subnet-id $sub --route-table-id $routeid
echo "Route table containing Internet Gateway successfully created for Public subnet, Route id: " $routeid
read -p "enter key name: " kname
aws ec2 create-key-pair --key-name $kname --query 'KeyMaterial' --output text > $kname
chmod 400 $kname 
echo "Key successfully created which will be used for Instances"
groupid=`aws ec2 create-security-group --group-name $natn --description "Security group for Nat instance" --vpc-id $vpcid --query GroupId --output text` 
aws ec2 run-instances --image-id $ami --count 1 --instance-type $micro --key-name $kname --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$natname'}]' --security-group-ids $groupid --subnet-id $sub --associate-public-ip-address 
natid=`aws ec2 describe-instances --filters Name=tag-value,Values=$natname --query Reservations[*].Instances[*].[InstanceId] --output text`                    
aws ec2 modify-instance-attribute --instance-id $natid --no-source-dest-check
echo "Nat Instance successfully created with id: " $natid
sleep 15s
rid=`aws ec2 create-route-table --vpc-id $vpcid --query RouteTable.RouteTableId --output text`               
aws ec2 create-route --route-table-id $rid --destination-cidr-block 0.0.0.0/0 --instance-id $natid
aws ec2 associate-route-table  --subnet-id $sut --route-table-id $rid
echo "Route Table containing Nat Gateway successfully created and attached with Private subnet, Route id: " $rid
pubgroup=`aws ec2 create-security-group --group-name $pubsg --description "Security group for public instance" --vpc-id $vpcid --query GroupId --output text`          
aws ec2 run-instances --image-id $amin --count 1 --instance-type $mic --key-name $kname --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$pubna'}]' --security-group-ids $pubgroup --subnet-id $sub --associate-public-ip-address 
pubid=`aws ec2 describe-instances --filters Name=tag-value,Values=$pubna --query Reservations[*].Instances[*].[InstanceId] --output text`    
echo "Public Instance successfull created with id: " $pubid
pvtgroup=`aws ec2 create-security-group --group-name $pgn --description "Security group for private instance" --vpc-id $vpcid --query GroupId --output text`               
aws ec2 run-instances --image-id $pami --count 1 --instance-type $inst --key-name $kname --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$pvtna'}]' --security-group-ids $pvtgroup --subnet-id $sut 
pvtid=`aws ec2 describe-instances --filters Name=tag-value,Values=$pvtna --query Reservations[*].Instances[*].[InstanceId] --output text`                 
pvtip=`aws ec2 describe-instances --filters Name=tag-value,Values=$pvtna --query Reservations[*].Instances[*].[PrivateIpAddress] --output text`
echo "Private Instance successfully created with id: " $pvtid
echo "Enter Security Rules for Public Instance"
echo "Use this Nat Instance Security Group if required"
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
echo "Security Group rules are successfully filled for Public Instance"
echo "Enter Security Rules for Private Instance"
echo "security group of Nat instance: "
aws ec2 describe-instances --filters "Name=instance-id,Values="$natid --query 'Reservations[*].Instances[*].[SecurityGroups[*].[GroupId]]' --output text
echo "security group of Public instance: "
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
echo "Security Group rules are successfully filled for Private instance" 
echo "Enter Security Rules for Nat Instance"
echo "Use this Private instance sg id if required"
aws ec2 describe-instances --filters "Name=instance-id,Values="$pvtid --query 'Reservations[*].Instances[*].[SecurityGroups[*].[GroupId]]' --output text
read -p "want to enter security rule (for nat ins) with source group, enter '0': " twelve
w=$twelve
while [ $w -eq 0 ]
do
	read -p "enter protocol: " col
	read -p "enter port: " ort
	read -p "enter source group: " dir
	aws ec2 authorize-security-group-ingress --group-id $groupid --protocol $col --port $ort --source-group $dir
  read -p "want to enter more rules, enter '0': " enter
	w=$enter
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
echo "Security Group rules are successfully filled for Nat Instance"
pubip=`aws ec2 describe-instances --filters Name=tag-value,Values=$pubna --query Reservations[*].Instances[*].[PublicIpAddress] --output text`             
echo "VPC, subnets, Instances and their security groups are successfully created"
echo "Now we will work on insatlling Apache, creating Virtual Host and Html file in Public Instance"
scp -i $kname $kname ec2-user@$pubip:/home/ec2-user/
ssh -i $kname ec2-user@$pubip sudo yum install httpd
echo "HTTPD successfully installed"
read -p 'Enter key name for SSL Certificate: ' name
read -p 'Enter key.org name (for SSL Certification purpose): ' orna
read -p 'enter conf file name: ' var
read -p 'enter ServerName: ' servern
read -p 'enter server alias: ' server
read -p "enter html filename" html
ssh -i $kname ec2-user@$pubip sudo openssl genrsa -des3 -out $name.key 1024
ssh -i $kname ec2-user@$pubip sudo openssl req -new -key $name.key -out $name.csr
ssh -i $kname ec2-user@$pubip sudo cp $name.key $orna.key.org
ssh -i $kname ec2-user@$pubip sudo openssl rsa -in $orna.key.org -out $name.key
ssh -i $kname ec2-user@$pubip sudo openssl x509 -req -days 365 -in $name.csr -signkey $name.key -out $name.crt
ssh -i $kname ec2-user@$pubip sudo mv $name.* /etc/pki/tls/certs/
ssh -i $kname ec2-user@$pubip sudo mv $orna.* /etc/pki/tls/certs/
ssh -i $kname ec2-user@$pubip sudo yum install -y mod_ssl
echo "SSL certificate successfully created" 
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
echo "Virtual host file successfully created in conf.d"
ssh -i $kname ec2-user@$pubip sudo chmod 666 /etc/hosts
ssh -i $kname ec2-user@$pubip "echo $pubip ' '$servern>>/etc/hosts"
ssh -i $kname ec2-user@$pubip sudo chmod 644 /etc/hosts
ssh -i $kname ec2-user@$pubip sudo touch /var/www/html/$html
ssh -i $kname ec2-user@$pubip sudo chmod 777 /var/www/html/$html
ssh -i $kname ec2-user@$pubip "echo '<html>'>>/var/www/html/$html"
ssh -i $kname ec2-user@$pubip "echo '<body>'>>/var/www/html/$html"
ssh -i $kname ec2-user@$pubip "echo 'hlo '>>/var/www/html/$html"
ssh -i $kname ec2-user@$pubip "echo '</body>'>>/var/www/html/$html"
ssh -i $kname ec2-user@$pubip "echo '</html>'>>/var/www/html/$html" 
echo "Html file successfully created"
echo "Now Process will start in Private Instance for installing Java, Tomcat and Jenkins.war file"
ssh -i $kname ec2-user@$pubip sudo ssh -o StrictHostKeyChecking=no ec2-user@$pvtip 
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo yum install java
echo "Java successfully installed"
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo wget https://mirrors.estointernet.in/apache/tomcat/tomcat-8/v8.5.61/bin/apache-tomcat-8.5.61.tar.gz
echo "Tomcat successfully installed"
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo tar -xzf apache-tomcat-8.5.61.tar.gz
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo wget https://get.jenkins.io/war/2.272/jenkins.war
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo chmod 766 /home/ec2-user/apache-tomcat-8.5.61/webapps
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo mv /home/ec2-user/jenkins.war /home/ec2-user/apache-tomcat-8.5.61/webapps
echo "Jenkins file successfully installed and placed in webapps directory"
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo chmod 766 /home/ec2-user/apache-tomcat-8.5.61/bin
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo sh /home/ec2-user/apache-tomcat-8.5.61/bin/startup.sh
echo "Tomcat started successfully"
ssh -i $kname ec2-user@$pubip sudo systemctl start httpd
echo "HTTPD started successfully"
