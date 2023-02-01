#!/bin/bash

#STEP 1 Установка  Easy-RSA
#Install EASY_RSA. Common name = server
read -r -p "Common name for server: " sername
read -r -s -p "Password for sudo: " passwd
echo $passwd | sudo -S apt-get update
echo $passwd | yes | sudo -S apt-get install easy-rsa
 
dpkg -s easy-rsa &>> /dev/null
if [ $? -eq 0 ]
then
    echo "Successfully install easy-rsa"
else
    echo "No intall easy-rsa >&2"
    exit 1
fi
#Creat direct for our PKI
mkdir ~/easy-rsa 
#Creat symlink 
ln -s /usr/share/easy-rsa/* ~/easy-rsa/
#Making us the owner
sudo chown $USER ~/easy-rsa
chmod 700 ~/easy-rsa

#STEP 2 Создание PKI для OpenVPN ( создание инфраструктуру открытых ключей)
cd ~/easy-rsa 
./easyrsa init-pki
#Install our deb-package 
echo $passwd | sudo dpkg -i vars_0.1-1_all.deb &>> /dev/null
if [ $? -eq 0 ]
then
    echo "Successfully install deb-package vars"
else
    echo "No intall deb-package var >&2"
    exit 1
fi
#Enter passpharasa and common name enter. Ca.crt  это файл открытый ключ PKI
./easyrsa build-ca 

#STEP 3 Создание запроса сертификата и закрытого ключа сервера OpenVPN
#Install openvpn
cd ~/easy-rsa
echo $passwd | yes | sudo apt-intall openvpn 
cd ~/easy-rsa
#Create query certification and key (common server)
echo $sername | ./easyrsa gen-req server nopass
echo $passwd | sudo cp /home/sammy/easy-rsa/pki/private/server.key /etc/openvpn/server/

#STEP 4 Подпись запроса сертификата сервера OpenVPN
# Yes and passpharasa 
echo yes| ./easyrsa sign-req server server
#Cерверный сертификат и сертификат удостоверяющего центра перемещаем в openvpn/server/
sudo cp pki/issued/server.crt /etc/openvpn/server/
sudo cp pki/ca.crt /etc/openvpn/server/

#STEP 5 Настройка криптографических материалов OpenVPN
cd ~/easy-rsa
#Добавляем доп секретный ключ для того чтобы для клиентов и сервером использовался tls скрипт ключ 
openvpn --genkey --secret ta.key || /usr/sbin/openvpn --genkey --secret ta.key
#Copy ta.key in openvpn
sudo cp ta.key /etc/openvpn/server

#STEP 6 Создание сертификата клиента и пары ключей
#Create direct for clients
cd ~/easy-rsa
mkdir -p ~/client-configs/keys
chmod -R 700 ~/client-configs
#Create certificate and key for client1
echo | ./easyrsa gen-req client1 nopass
#Copy key in client-configs
cp pki/private/client1.key ~/client-configs/keys/
#Подписываем запрос для клиента с ником client1 и вводим passphrase
echo yes | ./easyrsa sign-req client client1
#Copy ta.key and client1.crt in client-configs
echo $passwd | sudo cp ta.key ~/client-configs/keys/ 
echo $passwd | sudo cp pki/issued/client1.crt ~/client-configs/keys/
#Making us the owner
echo $passwd | sudo chown $USER:$USER ~/client-configs/keys/*

#STEP 7 Настройка OpenVPN
#Install our deb-package 
echo $passwd | sudo dpkg -i server-conf_0.1-1_all.deb &>> /dev/null
if [ $? -eq 0 ]
then
    echo "Successfully install deb-package server-conf_0.1-1_all.deb"
else
    echo "No intall deb-package server-conf_0.1-1_all.deb >&2"
    exit 1
fi

#STEP 8	Настройка конфигурации сети сервера OpenVPN
echo $passwd | sudo sed -i '28c\net.ipv4.ip_forward=1' sysctl.conf 
echo $passwd | sudo sysctl -p

