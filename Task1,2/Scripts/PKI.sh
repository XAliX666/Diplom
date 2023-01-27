#!/bin/bash

#Install EASY_RSA 
read -r -s -p "Password for sudo: " passwd
echo $passwd | sudo -S apt-get update
echo $passwd | yes | sudo -S apt-get install easy-rsa
 
dpkg -s easy-rsa &>> /dev/null
if [ $? -eq 0 ]
then
  echo "Successfully install easy-rsa"
else
  echo "No intall easy-rsa >&2"
fi