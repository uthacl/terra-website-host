#!/bin/bash
sudo apt-get update
sudo yum install httpd -y
cd /var/www/html
echo "<h1>Deployed via Terraform</h1>" > index.html
curl -s http://169.254.169.254/latest/dynamic/instance-identity/document > details.html
service httpd start
chkconfig httpd on