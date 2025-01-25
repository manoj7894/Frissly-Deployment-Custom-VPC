#!/bin/bash

# Update package list
echo "Updating package list..."
sudo apt-get update -y



# Install Jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install fontconfig openjdk-17-jre -y
sudo apt-get install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
echo "Jenkins installation complete."



# Install Docker
# Add Docker's official GPG key
sudo apt-get update -y
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
sudo systemctl enable docker
sudo systemctl start docker
echo "Docker installation complete."



# Install Maven
# Maven will be updated automatically by the package manager
sudo apt-get update -y
sudo apt-get install maven -y
mvn -version
echo "Maven installation complete."



# Install Git
# Git will be updated automatically by the package manager
sudo apt-get update -y
sudo apt-get install git -y
git --version
echo "Git installation complete."



# Install Trivy-Scanner
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
echo "Trivy installation complete."



# Install NPM
sudo apt install npm -y

# # installs fnm (Fast Node Manager)
# curl -fsSL https://fnm.vercel.app/install | bash

# # activate fnm
# source /home/ubuntu/.bashrc

# # download and install Node.js
# fnm use --install-if-missing 22

# # verifies the right Node.js version is in the environment
# node -v # should print `v22.7.0`

# # verifies the right npm version is in the environment
# npm -v # should print `10.8.2`



# Install AWS_CLI
sudo apt-get update -y
sudo apt-get install -y curl unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
# # Load environment variables from .env file
# export $(grep -v '^#' .env | xargs)
# echo "region = ${region}" >> /home/ubuntu/.aws/config
# echo "aws_access_key_id = ${access_key}" >> /home/ubuntu/.aws/credentials
# echo "aws_secret_access_key = ${secret_key}" >> /home/ubuntu/.aws/credentials



# # Set up automatic updates for security patches
# sudo apt-get install unattended-upgrades -y
# sudo dpkg-reconfigure --priority=low unattended-upgrades



# Install SonarQube
# Install unzip if not already installed
sudo apt-get install unzip -y

# Create a user for SonarQube
sudo adduser --disabled-password --gecos 'SonarQube' sonarqube

# Switch to SonarQube user and install SonarQube
sudo su - sonarqube <<EOF
# Fetch the latest SonarQube version from the official source
SONARQUBE_VERSION=$(curl -s https://api.github.com/repos/SonarSource/sonarqube/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
SONARQUBE_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip"

# Download and extract SonarQube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.4.0.54424.zip
unzip sonarqube-9.4.0.54424.zip
chmod -R 755 /home/sonarqube/sonarqube-9.4.0.54424
# Change ownership
chown -R sonarqube:sonarqube /home/sonarqube/sonarqube-9.4.0.54424
# Start SonarQube
cd sonarqube-9.4.0.54424/bin/linux-x86-64/
./sonar.sh start
EOF

echo "Installation complete. Jenkins, Docker, Maven, Git, and SonarQube are set up."
echo "Sonarqube installation complete."
sudo cat /var/lib/jenkins/secrets/initialAdminPassword