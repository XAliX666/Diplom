#!/bin/bash
#First query enter enter, Second query enter servername, Threes query enter passwd servername
read -r -p "Enter file in which to save the key (/Users/siur/.ssh/id_rsa):" enter
read -r -p "Enter Who is sent pub.key(ali@123.123.1331.21): " servername
#Create keys and passphrasa(by hand)
echo  $enter | ssh-keygen
#sent our public key in server and need enter password in server
ssh-copy-id -i $HOME/.ssh/id_rsa.pub $servername

