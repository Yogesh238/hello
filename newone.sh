#!/bin/bash
echo "Hi, this script will give provide you the way to automatically do all these things:"
echo "1) Make VPC, Subnets (Private and Public) and Instances (Nat, Public and Private) in AWS"
echo "2) Install httpd in Public instance and then automatically start it"
echo "3) Install Java, Tomcat and Jenkins.war (and then save it to webapps file) file in Private instance"
echo "4) Integrate Httpd (in Private Instance) and Tomcat (in Public Instance)"
      echo "      "
      read -p "Enter project name:" project
      read -p "enter cidr block value for vpc [default value: 10.0.0.0/16, Press enter for default value]: " cidr
      cidr=${cidr:-10.0.0.0/16}
      read -p "enter availability zone [default value: ap-south-1a, Press enter for default value]: " south
      south=${south:-ap-south-1a}
      read -p "enter cidr value for Public subnet [default value: 10.0.1.0/24, Press enter for default value]: " subn
      subn=${subn:-10.0.1.0/24}
      read -p "enter cidr value for Private subnet [default value: 10.0.0.0/24, Press enter for default value]: " subt
      subt=${subt:-10.0.0.0/24}
      echo "      "
      read -p "enter image id for nat instance [default value: ami-00999044593c895de, Press enter for default value]: " ami
      ami=${ami:-ami-00999044593c895de} 
      read -p "enter instance-type for nat instance [default value: t2.micro, Press enter for default value]: " micro
      micro=${micro:-t2.micro}
      read -p "enter image-id for public instance [default value: ami-04b1ddd35fd71475a, Press enter for default value]: " amin
      amin=${amin:-ami-04b1ddd35fd71475a}
      read -p "enter instance-type for public instance [default value: t2.micro, Press enter for default value]: " mic
      mic=${mic:-t2.micro}
      read -p "enter image-id for private instance [default value: ami-04b1ddd35fd71475a, Press enter for default value]: " pami
      pami=${pami:-ami-04b1ddd35fd71475a}
      read -p "enter instance type for private instance [default value: t2.micro, Press enter for default value]: " inst
      inst=${inst:-t2.micro}
      echo "       "
d=0
while [ $d -eq 0 ]
do
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
      echo "      "
      echo "According to the information provided by you, following resource will be create: "
      echo "VPC with name: " $value
      echo "Public subnet with name: " $names
      echo "Private subnet with name: " $namesp
      echo "Internet Gateway with name: " $igwna
      echo "Key for instance with name: " $kname
      echo "Nat instance with name: " $natname
      echo "Public instance with name: " $pubna
      echo "Private instance with name: " $pvtna
      echo "CIDR block value for VPC: " $cidr
      echo "Availability zone: " $south
      echo "CIDR block value for Public subnet: " $subn
      echo "CIDR block value for Private subnet: " $subt
      echo "Image id for Nat Instance: " $ami
      echo "Image id for Public Instance: " $amin
      echo "Image id for Private Instance: " $pami
      echo "Instance type for Nat Instance: " $micro
      echo "Instance type for Public Instance: " $mic
      echo "Instance type for Private Instance: " $inst
      echo "       " 
     read -p "Choose 1 to continue with above information or Press 0 if you want to change any information: " ch
      
      if [ $ch -eq 0 ]
      then 
              echo "    "
              echo "Whcih information you want to change:"
              echo "Enter 1 to change project name"
              echo "Enter 2 to change availability zone"
              echo "Enter 3 to change CIDR values for vpc and subnets"
              echo "Enter 4 to change Image id for instances"
              echo "Enter 5 to change Instance-type for instances"
              echo "Enter 6 to change all information"
              echo "    "
              read -p "Enter your choice: " chose
              case $chose in
		   1)
			read -p "Re-enter Project name: " project
			
			d=0
			;;
		   2)
			read -p "Re-enter availability zone [ap-south-1a]: " south
			south=${south:-ap-south-1a}
			
			d=0
			;;
		   3) 
			read -p "Enter CIDR value for VPC: " cidr
                        read -p "Enter CIDR value for Public subnet: " subn
			read -p "Enter CIDR value for Private subnet: " subt
			
			d=0
                        ;;
		   4)
			read -p "enter image id for nat instance [ami-00999044593c895de]: " ami
			ami=${ami:-ami-00999044593c895de} 
			read -p "enter image-id for public instance [ami-04b1ddd35fd71475a]: " amin
			amin=${amin:-ami-04b1ddd35fd71475a}
			read -p "enter image-id for private instance [ami-04b1ddd35fd71475a]: " pami
			pami=${pami:-ami-04b1ddd35fd71475a}
			
			d=0
			;;
		   5)
			read -p "enter instance-type for nat instance [t2.micro]: " micro
			micro=${micro:-t2.micro}
			read -p "enter instance-type for public instance [t2.micro]: " mic
			mic=${mic:-t2.micro}
			read -p "enter instance type for private instance [t2.micro]: " inst
			inst=${inst:-t2.micro}
			d=0
			;;
		   6)
			read -p "Enter project name:" project
			read -p "enter cidr value for vpc: " cidr
		        read -p "enter cidr value for Public subnet: " subn
		        read -p "enter cidr value for Private subnet: " subt
		        read -p "enter availability zone [ap-south-1a]: " south
		        south=${south:-ap-south-1a}
			read -p "enter image id for nat instance [ami-00999044593c895de]: " ami
			ami=${ami:-ami-00999044593c895de} 
			read -p "enter instance-type for nat instance [t2.micro]: " micro
			micro=${micro:-t2.micro}
			read -p "enter image-id for public instance [ami-04b1ddd35fd71475a]: " amin
			amin=${amin:-ami-04b1ddd35fd71475a}
			read -p "enter instance-type for public instance [t2.micro]: " mic
			pami=${pami:-ami-04b1ddd35fd71475a}
			read -p "enter image-id for private instance [ami-04b1ddd35fd71475a]: " pami
			pami=${pami:-ami-04b1ddd35fd71475a}
			read -p "enter instance type for private instance [t2.micro]: " inst
			inst=${inst:-t2.micro}
			d=0
			;;
                esac
          else
                        d=1
          fi
done
touch $lname
echo `date +%T` "Names for every field successfully filled" | tee -a $lname
echo "     "
e=0
while [ $e -eq 0 ]
do
      vpcid=`aws ec2 create-vpc --cidr-block $cidr --query Vpc.VpcId --output text`
      if [ -z $vpcid ]
      then
              echo "If error is due to wrong cidr block value, Press 1"
              echo "If error is due to other reason, Press 2"
              echo "    "
              read -p "enter choice: " chjo
              case $chjo in
                   1)
                        read -p "enter correct CIDR value for vpc: " cidr
			e=0
			;;
		   2)
			echo "Sorry, error is not identified, terminating the process due to error"
			read -p "Press ctrl+z to exit"
			;;
		esac
      else
		e=1
      fi
done 
f=0
while [ $f -eq 0 ]
do
      sub=`aws ec2 create-subnet --vpc-id $vpcid --cidr-block $subn --availability-zone $south --query Subnet.SubnetId --output text` 
      if [ -z $sub ]
      then
               echo "If error is due to wrong CIDR block value, Press 1"
               echo "If error is due to any other reason, Press 2"
               echo "    "
               read -p "enter choice: " chko
               case $chko in
                    1)
			read -p "Enter correct CIDR value for Public subnet: " subn
			f=0
			;;
		    2)
			echo "Sorry error is not identified, terminating the process and deleting all installations"
			aws ec2 delete-vpc --vpc-id $vpcid
			read -p "Press ctrl+z to exit"
			;;
		 esac
	else
		f=1
	fi
done
g=0
while [ $g -eq 0 ]
do 
      sut=`aws ec2 create-subnet --vpc-id $vpcid --cidr-block $subt --availability-zone $south --query Subnet.SubnetId --output text`                       
      if [ -z $sut ]
      then
               echo "If error is due to wrong CIDR block value, Press 1"
	       echo "If error is due to any other reason, Press 2"
	       echo "   "
	       read -p "enter choice: " cioc
	       case $cioc in 
		    1) 
			read -p "Enter correct CIDR value for Private subnet: " subt
			g=0
			;;
	 	    2)
			echo "Sorry error is not identified, terminating the process and deleting all installations"
			aws ec2 delete-subnet --subnet-id $subn 
                        aws ec2 delete-vpc --vpc-id $vpcid
                        read -p "Press ctrl+z to exit"
			;;
		esac
	 else
		g=1
	fi
done
aws ec2 create-tags --resources $vpcid --tags Key=Name,Value=$value
echo `date +%T` "Vpc successfully created with vpcid: " $vpcid | tee -a $lname
aws ec2 create-tags --resources $sub --tags Key=Name,Value=$names
echo `date +%T` "Public subnet successfully created with id: " $sub | tee -a $lname
aws ec2 create-tags --resources $sut --tags Key=Name,Value=$namesp
echo `date +%T` "Private subnet successfully created with id: " $sut | tee -a $lname
m=0
while [ $m -eq 0 ]
do
     igw=`aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text` >> $lname
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
aws ec2 associate-route-table  --subnet-id $sub --route-table-id $routeid >> $lname
echo `date +%T` "Route table containing Internet Gateway successfully created for Public subnet, Route id: " $routeid>>$lname
aws ec2 create-key-pair --key-name $kname --query 'KeyMaterial' --output text > $kname
chmod 400 $kname 
echo `date +%T` "Key successfully created which will be used for Instances" | tee -a $lname
groupid=`aws ec2 create-security-group --group-name $natn --description "Security group for Nat instance" --vpc-id $vpcid --query GroupId --output text` 
r=0
while [ $r -eq 0 ]
do
      aws ec2 run-instances --image-id $ami --count 1 --instance-type $micro --key-name $kname --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$natname'}]' --security-group-ids $groupid --subnet-id $sub --associate-public-ip-address >> $lname
      natid=`aws ec2 describe-instances --filters Name=tag-value,Values=$natname --query Reservations[*].Instances[*].[InstanceId] --output text`  
      if [ -z $natid ]
      then
              echo "If error is due to wrong Image-id, Press 1"
	      echo "If error is due to wrong Instance-type, Press 2"
              echo "If error is due to any another reason, Press 3"
              echo "    "
              read -p "enter choice: " chce
		case $chce in
		     1)
			read -p "Enter correct Image-id [default value: ami-00999044593c895de]: " ami
			ami=${ami:-ami-00999044593c895de}
			r=0
			;;
		     2)
			read -p "Enter correct Instance-type [default value: t2.micro]: " micro
			micro=${micro:-t2.micro}
			;;
		     3)
			echo "Sorry, error is not identified, terminating the process and deleting all installations"
			aws ec2 delete-subnet --subnet-id $subn
			aws ec2 delete-subnet --subnet-id $sut
			aws ec2 delete-vpc --vpc-id $vpcid
			read -p "Press ctrl+z to exit"
			;;
	      esac
      else
              r=1
      fi
done      
aws ec2 modify-instance-attribute --instance-id $natid --no-source-dest-check
echo `date +%T` "Nat Instance successfully created with id: " $natid | tee -a $lname
sleep 20s
rid=`aws ec2 create-route-table --vpc-id $vpcid --query RouteTable.RouteTableId --output text`               
aws ec2 create-route --route-table-id $rid --destination-cidr-block 0.0.0.0/0 --instance-id $natid >> $lname
aws ec2 associate-route-table  --subnet-id $sut --route-table-id $rid >> $lname
echo `date +%T` "Route Table containing Nat Gateway successfully created and attached with Private subnet, Route id: " $rid | tee -a $lname
pubgroup=`aws ec2 create-security-group --group-name $pubsg --description "Security group for public instance" --vpc-id $vpcid --query GroupId --output text`          
v=0 
while [ $v -eq 0 ]
do
        aws ec2 run-instances --image-id $amin --count 1 --instance-type $mic --key-name $kname --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$pubna'}]' --security-group-ids $pubgroup --subnet-id $sub --associate-public-ip-address >> $lname 
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
         aws ec2 run-instances --image-id $pami --count 1 --instance-type $inst --key-name $kname --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$pvtna'}]' --security-group-ids $pvtgroup --subnet-id $sut >> $lname
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
echo `date +%T` "VPC, subnets, Instances and their security groups are successfully created in AWS" | tee -a $lname
echo "Now we will proceed to Install Apache, creating Virtual Host and Html file in Public Instance"
echo "    "
sleep 20s
scp -i $kname $kname ec2-user@$pubip:/home/ec2-user/
echo "Httpd installation start"
ssh -i $kname ec2-user@$pubip sudo yum install httpd -y >> $lname
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
ssh -i $kname ec2-user@$pubip sudo yum install -y mod_ssl >> $lname
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
echo "    "
echo "Now Installation Process is over in Public Instance"
echo "    "
echo "Now Process will start in Private Instance for installing Java, Tomcat and Jenkins.war file"
echo "      "
ssh -i $kname ec2-user@$pubip sudo ssh -o StrictHostKeyChecking=no ec2-user@$pvtip
echo "Java Installation process start" 
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo yum install java -y >> $lname
echo `date +%T` "Java successfully installed" | tee -a $lname
echo "Tomcat installation process start"
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo wget https://mirrors.estointernet.in/apache/tomcat/tomcat-8/v8.5.61/bin/apache-tomcat-8.5.61.tar.gz | -a $lname
echo `date +%T` "Tomcat successfully installed" | tee -a $lname
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo tar -xzf apache-tomcat-8.5.61.tar.gz | -a $lname
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo wget https://get.jenkins.io/war/2.272/jenkins.war | -a $lname
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo chmod 766 /home/ec2-user/apache-tomcat-8.5.61/webapps
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo mv /home/ec2-user/jenkins.war /home/ec2-user/apache-tomcat-8.5.61/webapps
echo `date +%T` "Jenkins file successfully installed and placed in webapps directory" | tee -a $lname
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo chmod 766 /home/ec2-user/apache-tomcat-8.5.61/bin
ssh -i $kname ec2-user@$pubip sudo ssh -i $kname ec2-user@$pvtip sudo sh /home/ec2-user/apache-tomcat-8.5.61/bin/startup.sh
echo `date +%T` "Tomcat started successfully" | tee -a $lname
ssh -i $kname ec2-user@$pubip sudo systemctl start httpd
echo `date +%T` "HTTPD started successfully" | tee -a $lname
echo "To access use this link: https://"$server
echo "To access the jenkins use this link: https://"$server"/jenkins"
echo "To access html file use this link: http://"$server"/"$file 
