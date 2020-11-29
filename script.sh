#!/bin/bash

# Sha256 sum of included files
# 2e57a55cb059ee5535f1e4efcc3b1cd6f2ecc01a97326372126b7d98f343e624 dircolors
# 095ed1ef56d4f644c2ebbac01e93763affba300c7605c2ae937e32139000adf8 zshrc

# Colors
Red="\033[1;31m"
Green="\033[1;32m"
Yellow="\033[1;33m"
Brown="\033[38:2:255:165:0m"
Cyan="\033[1;36m"
Rst="\033[0m"

# Variable that defines package manager
#
# 1-apt
# 2-pacman
# 3-yum
#
man=0

_installzsh() {
  if [ $man = 1 ]; then sudo apt install -y zsh git; fi
  if [ $man = 2 ]; then sudo pacman -Sy zsh git; fi
  if [ $man = 3 ]; then sudo yum update && sudo yum -y install zsh git; fi
  if PM="$( which zsh )" 2> /dev/null; then
     echo -e ${Green}"zsh Installed Successfully"${Rst}
  else
     echo -e ${Red}"Installing zsh Failed Aborting"${Rst}
     exit 1
  fi
}

_checkIntegrity() {
   echo -e ${Yellow}"Verifying sha256sum of dircolors"${Rst}
   sleep 1
   if [ $(sha256sum scripts/dircolors | cut -d ' ' -f 1) = "2e57a55cb059ee5535f1e4efcc3b1cd6f2ecc01a97326372126b7d98f343e624" ]; then
   echo -e ${Green}"2e57a55cb059ee5535f1e4efcc3b1cd6f2ecc01a97326372126b7d98f343e624 Verified OK"${Rst}
   else echo -e ${Red}"2e57a55cb059ee5535f1e4efcc3b1cd6f2ecc01a97326372126b7d98f343e624 Failed"${Rst}; exit 1
   fi
   echo -e ${Yellow}"Verifying sha256sum of zshrc"${Rst}
   sleep 1
   if [ $(sha256sum scripts/zshrc | cut -d ' ' -f 1) = "095ed1ef56d4f644c2ebbac01e93763affba300c7605c2ae937e32139000adf8" ]; then
   echo -e ${Green}"095ed1ef56d4f644c2ebbac01e93763affba300c7605c2ae937e32139000adf8 Verified OK"${Rst}
   else echo -e ${Red}"095ed1ef56d4f644c2ebbac01e93763affba300c7605c2ae937e32139000adf8 Failed"${Rst}; exit 1
   fi
}

if PM="$( which apt-get )" 2> /dev/null; then
   echo -e ${Brown}"Found apt-get"${Rst}
   man=1
elif PM="$( which pacman )" 2> /dev/null; then
   echo -e ${Brown}"Found pacman"${Rst}
   man=2
elif PM="$( which yum )" 2> /dev/null; then
   echo -e ${Brown}"Found yum"${Rst}
   man=3
else
   echo -e ${Red}"Unsupported distro"${Rst} >&2
   exit 1
fi

# Install and set as default
if PM="$( which zsh )" 2> /dev/null; then
   echo -e ${Brown}"zsh already installed"${Rst}
else
   _installzsh
fi

# Setting zsh as default
echo -e ${Yellow}"Setting zsh as default Terminal"${Rst}
chsh -s $(which zsh)
sleep 1

#Check integretiy of config files
_checkIntegrity
echo -e ${Green}"Integrity check PASSED!"${Rst}
sleep 1

echo -e ${Yellow}"Backing Up Existing zsh config"${Rst}
cp ~/.zshrc ~/.zshrc_backup

sleep 1
echo -e ${Yellow}"Copying Kali's config"${Rst}
cp scripts/zshrc ~/.zshrc

sleep 1
echo -e ${Yellow}"Copying Auto Suggestions"${Rst}
sudo mkdir -p /usr/share/
sudo git clone https://github.com/zsh-users/zsh-autosuggestions /usr/share/zsh-autosuggestions/

sleep 1
echo -e ${Yellow}"Copying Highlighting script"${Rst}
sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/zsh-syntax-highlighting/

sudo chmod 644 /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

sleep 1
echo -e ${Yellow}"Copying Dircolors"${Rst}
if [ -f /usr/bin/dircolors ]; then echo "Dircolors Already Exists";
else
  if [ ! -d /usr/bin/ ]; then
    sudo mkdir -p /usr/bin
    echo "export PATH=$PATH:/usr/bin" >> ~/.zshrc
  fi
  sudo cp scripts/dircolors /usr/bin/dircolors
fi

sudo chmod +x /usr/bin/dircolors

sleep 1
echo -e ${Cyan}"Kali zsh config successfully installed."${Rst}
echo -e ${Yellow}"Log out and login to see the changes"${Rst}
echo -e ${Cyan}"Old zshrc copied to ~/.zshrc_old"${Rst}
