#!/bin/bash
echo "Hi, First we are going to make VPC, Subnets, Gateways, Instances and their security groups"
echo "Hi, Enter the names you want for the required fields given below"
t=0
while [ $t -eq 0 ]
do
      read -p "Enter project name:" project
      read -p "If you want to change the name of project then enter '0', otherwise enter '1'" hoic
      t=$hoic
done
value=$project-vpc                       #vpc name
names=$project-pubsub                    #public subnet name
namesp=$project-pvtsub                   #private subnet name
igwna=$project-igw                       #internet gateway name
kname=$project-key                       #key name
natname=$project-natins                  #nat instance name
natn=$project-natsg                      #nat instance security group
pubna=$project-pubins                    #public instance name
pubsg=$project-pubsg                     #public security group
pvtna=$project-pvtsub                    #private instance name
pgn=$project-pvtsg                       #private security group
time=`date +%F_%T`
lname=$project-log$time                  #log file name
touch $lname
echo `date +%T` "Names for every field successfully filled" | tee -a $lname
d=0
while [ $d -eq 0 ]
do
      read -p "enter cidr value for vpc: " cidr
      vpcid=`aws ec2 create-vpc --cidr-block $cidr --query Vpc.VpcId --output text`
      if [ -z $vpcid ]
      then
             echo "CIDR block value for VPC is not valid, Enter valid CIDR value again"
             d=0
      else
             d=1
      fi
done
read -p "enter availability zone [ap-south-1a]: " south
south=${south:-ap-south-1a}
k=0
while [ $k -eq 0 ]
do
      read -p "enter cidr value for Public subnet: " subn
      sub=`aws ec2 create-subnet --vpc-id $vpcid --cidr-block $subn --availability-zone $south --query Subnet.SubnetId --output text`
      if [ -z $sub ]
      then
             echo "CIDR block value for Public subnet is not valid, Enter valid CIDR value for Public subnet again"
             k=0
      else
             k=1
      fi
done
l=0
while [ $l -eq 0 ]
do
      read -p "enter cidr value for Private subnet: " subt
      sut=`aws ec2 create-subnet --vpc-id $vpcid --cidr-block $subt --availability-zone $south --query Subnet.SubnetId --output text`         
      if [ -z $sut ]
      then
             echo "CIDR block value for Private subnet is not valid, Enter valid CIDR value for Private subnet again"
             l=0
      else
             l=1
      fi
done
      echo "CIDR for VPC: " $cidr
      echo "CIDR for Public subnet: " $subn
      echo "CIDR for Private subnet: "$subt
      echo "Availability Zone: " $south
echo `date +%T` "CIDR and Availability Zone fields are successfully filled" | tee -a $lname
y=0
while [ $y -eq 0 ]
do
      read -p "enter image id for nat instance [default value: ami-00999044593c895de]: " ami
      ami=${ami:-ami-00999044593c895de} 
      read -p "enter instance-type for nat instance [default value: t2.micro]: " micro
      micro=${micro:-t2.micro}
      read -p "enter image-id for public instance [default value: ami-04b1ddd35fd71475a]: " amin
      amin=${amin:-ami-04b1ddd35fd71475a}
      read -p "enter instance-type for public instance [default value: t2.micro]: " mic
      mic=${mic:-t2.micro}
      read -p "enter image-id for private instance [default value: ami-04b1ddd35fd71475a]: " pami
      pami=${pami:-ami-04b1ddd35fd71475a}
      read -p "enter instance type for private instance [default value: t2.micro]: " inst
      inst=${inst:-t2.micro}  
      echo "Image-id for nat instance" $ami
      echo "Image-id for private instance" $pami
      echo "Image-id for public instance" $amin
      echo "Instance type of nat instance" $micro
      echo "Instance type of public instance" $mic
      echo "Instance type of private instance" $inst
      read -p "If you want to change Image-id and instance type of instances then enter '0', otherwise enter '1'" chice
      y=$chice
done      
aws ec2 create-tags --resources $vpcid --tags Key=Name,Value=$value
echo `date +%T` "VPC successfully created with vpcid: " $vpcid | tee -a $lname                  
aws ec2 create-tags --resources $sub --tags Key=Name,Value=$names
echo `date +%T` "Public subnet successfully created with id: " $sub | tee -a $lname
aws ec2 create-tags --resources $sut --tags Key=Name,Value=$namesp
echo `date +%T` "Private subnet successfully created with id: " $sut | tee -a $lname
m=0
while [ $m -eq 0 ]
do
     igw=`aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text`
     if [ -z $igw ]
     then
             echo "internet gateway not created, retrying to create internet gateway"
             m=0
     else
             m=1
     fi
done     
aws ec2 create-tags --resources $igw --tags Key=Name,Value=$igwna
aws ec2 attach-internet-gateway --vpc-id $vpcid --internet-gateway-id $igw
echo `date +%T` "Internet gateway successfully created and attached with vpc, IGW id: " $igw | tee -a $lname
routeid=`aws ec2 create-route-table --vpc-id $vpcid --query RouteTable.RouteTableId --output text`       
aws ec2 create-route --route-table-id $routeid --destination-cidr-block 0.0.0.0/0 --gateway-id $igw
aws ec2 associate-route-table  --subnet-id $sub --route-table-id $routeid
echo `date +%T` "Route table containing Internet Gateway successfully created for Public subnet, Route id: " $routeid>>$lname
aws ec2 create-key-pair --key-name $kname --query 'KeyMaterial' --output text > $kname
chmod 400 $kname 
echo `date +%T` "Key successfully created which will be used for Instances" | tee -a $lname
groupid=`aws ec2 create-security-group --group-name $natn --description "Security group for Nat instance" --vpc-id $vpcid --query GroupId --output text` 
r=0
while [ $r -eq 0 ]
do
      aws ec2 run-instances --image-id $ami --count 1 --instance-type $micro --key-name $kname --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$natname'}]' --security-group-ids $groupid --subnet-id $sub --associate-public-ip-address 
      natid=`aws ec2 describe-instances --filters Name=tag-value,Values=$natname --query Reservations[*].Instances[*].[InstanceId] --output text`                    
      if [ -z $natid ]
      then
              echo "Nat Instance not created, retrying to create Nat instance"
              r=0
      else
              r=1
      fi
done      
aws ec2 modify-instance-attribute --instance-id $natid --no-source-dest-check
echo `date +%T` "Nat Instance successfully created with id: " $natid | tee -a $lname
sleep 20s
rid=`aws ec2 create-route-table --vpc-id $vpcid --query RouteTable.RouteTableId --output text`               
aws ec2 create-route --route-table-id $rid --destination-cidr-block 0.0.0.0/0 --instance-id $natid
aws ec2 associate-route-table  --subnet-id $sut --route-table-id $rid
echo `date +%T` "Route Table containing Nat Gateway successfully created and attached with Private subnet, Route id: " $rid | tee -a $lname
pubgroup=`aws ec2 create-security-group --group-name $pubsg --description "Security group for public instance" --vpc-id $vpcid --query GroupId --output text`
v=0 
while [ $v -eq 0 ]
do
        aws ec2 run-instances --image-id $amin --count 1 --instance-type $mic --key-name $kname --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$pubna'}]' --security-group-ids $pubgroup --subnet-id $sub --associate-public-ip-address 
        pubid=`aws ec2 describe-instances --filters Name=tag-value,Values=$pubna --query Reservations[*].Instances[*].[InstanceId] --output text`    
        if [ -z $pubid ]
        then
                 echo "Public Instance not created, retrying to create Public Instance"
                 v=0
        else
                 v=1
        fi
done        
echo `date +%T` "Public Instance successfull created with id: " $pubid | tee -a $lname
pvtgroup=`aws ec2 create-security-group --group-name $pgn --description "Security group for private instance" --vpc-id $vpcid --query GroupId --output text`               
x=0
while [ $x -eq 0 ]
do
         aws ec2 run-instances --image-id $pami --count 1 --instance-type $inst --key-name $kname --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$pvtna'}]' --security-group-ids $pvtgroup --subnet-id $sut 
         pvtid=`aws ec2 describe-instances --filters Name=tag-value,Values=$pvtna --query Reservations[*].Instances[*].[InstanceId] --output text`                 
         if [ -z $pvtid ]
         then
                  echo "Private Instance not created, retrying to create Private Instance"
                  x=0
         else
                  x=1
         fi
 done        
pvtip=`aws ec2 describe-instances --filters Name=tag-value,Values=$pvtna --query Reservations[*].Instances[*].[PrivateIpAddress] --output text`
echo `date +%T` "Private Instance successfully created with id: " $pvtid | tee -a $lname
natpin=`aws ec2 describe-instances --filters "Name=instance-id,Values="$natid --query 'Reservations[*].Instances[*].[SecurityGroups[*].[GroupId]]' --output text`
aws ec2 authorize-security-group-ingress --group-id $pubgroup --protocol all --port all --source-group $natpin
aws ec2 authorize-security-group-ingress --group-id $pubgroup --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $pubgroup --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $pubgroup --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $pubgroup --protocol tcp --port 8080 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $pubgroup --protocol tcp --port 22 --cidr 13.233.177.0/29
echo `date +%T` "Security Group rules are successfully filled for Public Instance" | tee -a $lname
pubpin=`aws ec2 describe-instances --filters "Name=instance-id,Values="$pubid --query 'Reservations[*].Instances[*].[SecurityGroups[*].[GroupId]]' --output text`
aws ec2 authorize-security-group-ingress --group-id $pvtgroup --protocol all --port all --source-group $natpin
aws ec2 authorize-security-group-ingress --group-id $pvtgroup --protocol tcp --port 8080 --source-group $pubpin
aws ec2 authorize-security-group-ingress --group-id $pvtgroup --protocol icmp --port all --source-group $pubpin
aws ec2 authorize-security-group-ingress --group-id $pvtgroup --protocol tcp --port 22 --cidr $subn
echo `date +%T` "Security Group rules are successfully filled for Private instance" | tee -a $lname
pvtpin=`aws ec2 describe-instances --filters "Name=instance-id,Values="$pvtid --query 'Reservations[*].Instances[*].[SecurityGroups[*].[GroupId]]' --output text`
aws ec2 authorize-security-group-ingress --group-id $groupid --protocol tcp --port 22 --source-group $pvtpin
aws ec2 authorize-security-group-ingress --group-id $groupid --protocol tcp --port 80 --cidr $subt
aws ec2 authorize-security-group-ingress --group-id $groupid --protocol tcp --port 443 --cidr $subt
aws ec2 authorize-security-group-ingress --group-id $groupid --protocol icmp --port all --cidr $subt
echo `date +%T` "Security Group rules are successfully filled for Nat Instance" | tee -a $lname
pubip=`aws ec2 describe-instances --filters Name=tag-value,Values=$pubna --query Reservations[*].Instances[*].[PublicIpAddress] --output text`             
echo `date +%T` "VPC, subnets, Instances and their security groups are successfully created" | tee -a $lname
echo "Now Install Apache, creating Virtual Host and Html file in Public Instance"
sleep 20s
scp -i $kname $kname ec2-user@$pubip:/home/ec2-user/
ssh -i $kname ec2-user@$pubip sudo yum install httpd -y | tee -a $lname
echo `date +%T` "HTTPD successfully installed" | tee -a $lname
read -p 'Enter key name for SSL Certificate [keyyy]: ' name
name=${name:-keyyy}
read -p 'Enter key.org name (for SSL Certification purpose) [keyy]: ' orna
orna=${orna:-keyy}
read -p 'enter conf file name [virtual]: ' var
var=${var:-virtual}
read -p 'enter ServerName [yogesh.cloud.com]: ' servern
servern=${servern:-yogesh.cloud.com}
read -p 'enter server alias [www.yogesh.cloud.com]: ' server
server=${server:-www.yogesh.cloud.com}
read -p "enter html filename [file]: " html
html=${html:-file}
ssh -i $kname ec2-user@$pubip sudo openssl genrsa -des3 -out $name.key 1024
ssh -i $kname ec2-user@$pubip sudo openssl req -new -key $name.key -out $name.csr
ssh -i $kname ec2-user@$pubip sudo cp $name.key $orna.key.org
ssh -i $kname ec2-user@$pubip sudo openssl rsa -in $orna.key.org -out $name.key
ssh -i $kname ec2-user@$pubip sudo openssl x509 -req -days 365 -in $name.csr -signkey $name.key -out $name.crt
ssh -i $kname ec2-user@$pubip sudo mv $name.* /etc/pki/tls/certs/
ssh -i $kname ec2-user@$pubip sudo mv $orna.* /etc/pki/tls/certs/
echo `date +%T` "SSL certificate successfully created" | tee -a $lname 
ssh -i $kname ec2-user@$pubip sudo yum install -y mod_ssl | tee -a $lname
echo `date +%T` "mod_ssl get installed" | tee -a $lname 
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
echo `date +%T` "Virtual host file successfully created in conf.d" | tee -a $lname
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
echo `date +%T` "Html file successfully created" | tee -a $lname
echo "Now Process will start in Private Instance for installing Java, Tomcat and Jenkins.war file"
ssh -i $kname ec2-user@$pubip sudo ssh -o StrictHostKeyChecking=no ec2-user@$pvtip 
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo yum install java -y | tee -a $lname
echo `date +%T` "Java successfully installed" | tee -a $lname
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo wget https://mirrors.estointernet.in/apache/tomcat/tomcat-8/v8.5.61/bin/apache-tomcat-8.5.61.tar.gz | tee -a $lname
echo `date +%T` "Tomcat successfully installed" | tee -a $lname
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo tar -xzf apache-tomcat-8.5.61.tar.gz 
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo wget https://get.jenkins.io/war/2.272/jenkins.war | tee -a $lname
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo chmod 766 /home/ec2-user/apache-tomcat-8.5.61/webapps
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo mv /home/ec2-user/jenkins.war /home/ec2-user/apache-tomcat-8.5.61/webapps
echo `date +%T` "Jenkins file successfully installed and placed in webapps directory" | tee -a $lname
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo chmod 766 /home/ec2-user/apache-tomcat-8.5.61/bin
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo sh /home/ec2-user/apache-tomcat-8.5.61/bin/startup.sh
echo `date +%T` "Tomcat started successfully" | tee -a $lname
ssh -i $kname ec2-user@$pubip sudo systemctl start httpd
echo `date +%T` "HTTPD started successfully" | tee -a $lname
echo "To access use this link: https://"$server"
echo "To access the jenkins use this link: https://"$server"/jenkins"
echo "To access html file use this link: http://"$server"/"$file 
