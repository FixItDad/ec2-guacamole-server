################################################################
# Script_Name : xrdp-install.sh
# Description : Perform an automated custom installation of xrdp
# on ubuntu 15.04 or later when systemd is used
# Date : April 2016
# written by : Griffon
# Web Site :http://www.c-nergy.be - http://www.c-nergy.be/blog
# Version : 1.7
#
# Disclaimer : Script provided AS IS. Use it at your own risk....
#
##################################################################
 
##################################################################
#Step 1 - Install prereqs for compilation
##################################################################
 
echo "Installing prereqs for compiling xrdp..."
echo "----------------------------------------"

sudo apt-get -y update
sudo apt-get -y install libx11-dev libxfixes-dev libssl-dev libpam0g-dev libtool libjpeg-dev flex bison gettext autoconf libxml-parser-perl libfuse-dev xsltproc libxrandr-dev python-libxml2 nasm xserver-xorg-dev fuse make pkg-config

#Install git 
echo "Installing git software..."
sudo apt-get -y install git 
 
 
##################################################################
#Step 2 - Install the desktop of you choice
################################################################## 
 
#Here, we are installing Mate Desktop environment 

#echo "Installing alternate desktop to be used with xrdp..."
#echo "----------------------------------------------------"
#sudo apt-get -y update
#sudo apt-get -y install mate-core mate-desktop-environment mate-notification-daemon --force-yes
#echo "Desktop Install Done"
 

##################################################################
#Step 3 - Obtain xrdp packages and xorgxrdp packages
################################################################## 

mkdir -p ~/tmp
cd ~/tmp

#Download the xrdp latest files
echo "Ready to start the download of xrdp package"
echo "-------------------------------------------"
git clone https://github.com/neutrinolabs/xrdp.git

#move to xorgxrdp folder and download needed packages
cd xrdp/
git clone  https://github.com/neutrinolabs/xorgxrdp.git
 
##################################################################
#Step 4 - compiling xorgxrdp packages
################################################################## 
cd xorgxrdp 
sudo ./bootstrap 
sudo ./configure 
sudo make
sudo make install
cd ~/tmp/xrdp

##################################################################
#Step 5 - Fallback scenario - using x11vnc sesman
################################################################## 
 
#Install the X11VNC
echo "Installing X11VNC..."
echo "----------------------------------------"
sudo apt-get -y install x11vnc

#Add/Remove Ubuntu xrdp packages (used to create startup service)
echo "Add/Remove xrdp packages..."
echo "---------------------------"
sudo apt-get -y install xrdp
sudo apt-get -y remove xrdp
 
##################################################################
#Step 6 - compiling xrdp packages
################################################################## 
 
#Compile and make xrdp

echo "Installing and compiling xrdp..."
echo "--------------------------------"

# needed because libtool not found in Ubuntu 15.04 and later
# Need to use libtoolize

#sudo sed -i.bak 's/which libtool/which libtoolize/g' bootstrap

sudo ./bootstrap
sudo ./configure --enable-fuse --enable-jpeg
sudo make
sudo make install

#Final Post Setup configuration
echo "---------------------------"
echo "Post Setup Configuration..."
echo "---------------------------"

echo "Set Default xVnc-Sesman"
echo "-----------------------"

sudo sed -i.bak '/\[Xorg\]/i [xrdp0] \nname=SessionManager-Griffon \nlib=libxup.so \nusername=ask \npassword=ask \nip=127.0.0.1 \nport=-1 \nxserverbpp=24 \ncode=20 \n' /etc/xrdp/xrdp.ini

echo "Set Xorg executable for xrdp-sesman"
echo "-----------------------"

sudo sed -i.bak '/^param=Xorg$/s?=?=/usr/lib/xorg/?' /etc/xrdp/sesman.ini


echo "Symbolic links for xrdp"
echo "-----------------------"

sudo mv /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.backup
sudo ln -s /etc/X11/Xsession /etc/xrdp/startwm.sh
sudo mkdir /usr/share/doc/xrdp
sudo cp /etc/xrdp/rsakeys.ini /usr/share/doc/xrdp/rsakeys.ini

## Needed in order to have systemd working properly with xrdp
echo "-----------------------"
echo "Modify xrdp.service "
echo "-----------------------"

#Comment the EnvironmentFile - Ubuntu does not have sysconfig folder
sudo sed -i.bak 's/EnvironmentFile/#EnvironmentFile/g' /lib/systemd/system/xrdp.service

#Replace /sbin/xrdp with /sbin/local/xrdp as this is the correct location
sudo sed -i.bak 's?usr/sbin/xrdp?usr/local/sbin/xrdp?g' /lib/systemd/system/xrdp.service
echo "-----------------------"
echo "Modify xrdp-sesman.service "
echo "-----------------------"

#Comment the EnvironmentFile - Ubuntu does not have sysconfig folder
sudo sed -i.bak 's/EnvironmentFile/#EnvironmentFile/g' /lib/systemd/system/xrdp-sesman.service

#Replace /sbin/xrdp with /sbin/local/xrdp as this is the correct location
sudo sed -i.bak 's?usr/sbin/xrdp?usr/local/sbin/xrdp?g' /lib/systemd/system/xrdp-sesman.service

#Issue systemctl command to reflect change and enable the service
sudo systemctl daemon-reload
sudo systemctl enable xrdp.service

# Set keyboard layout in xrdp sessions
cd /etc/xrdp 
test=$(setxkbmap -query | awk -F":" '/layout/ {print $2}') 
echo "your current keyboard layout is.." $test
setxkbmap -layout $test
sudo cp /etc/xrdp/km-0409.ini /etc/xrdp/km-0409.ini.bak
sudo xrdp-genkeymap km-0409.ini

## Try configuring multiple users system 
sudo sed -i.bak '/^exit 0/i xfce4-session' /etc/xrdp/startwm.sh

# Load new / updated libraries
sudo ldconfig

#echo "Restart the Computer"
#echo "----------------------------"
#sudo shutdown -r now 
