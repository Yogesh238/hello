pipeline {
      agent {
        docker {
            image 'maven:3-alpine' 
            args '-v /root/.m2:/root/.m2' 
        }
    }
     stages {
           stage('Build') { 
            steps {
                sh 'mvn -B -DskipTests clean package' 
            }
        }
        stage("install maven"){
           steps{
              sh "echo wget https://archive.apache.org/dist/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz >> /home/ec2-user/code/Dockerfile"
              }
          }
      }
 }     
