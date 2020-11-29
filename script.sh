#!/bin/bash

# Sha256 sum of included files
# 2e57a55cb059ee5535f1e4efcc3b1cd6f2ecc01a97326372126b7d98f343e624 dircolors
# 095ed1ef56d4f644c2ebbac01e93763affba300c7605c2ae937e32139000adf8 zshrc

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
     echo "zsh Installed Successfully"
  else
     echo "Installing zsh Failed Aborting"
     exit 1
  fi
}

_checkIntegrity() {
   echo "Verifying sha256sum of dircolors"
   sleep 1
   if [ $(sha256sum scripts/dircolors | cut -d ' ' -f 1) = "2e57a55cb059ee5535f1e4efcc3b1cd6f2ecc01a97326372126b7d98f343e624" ]; then
   echo "2e57a55cb059ee5535f1e4efcc3b1cd6f2ecc01a97326372126b7d98f343e624 Verified OK"
   else echo "2e57a55cb059ee5535f1e4efcc3b1cd6f2ecc01a97326372126b7d98f343e624 Failed"; exit 1
   fi
   echo "Verifying sha256sum of zshrc"
   sleep 1
   if [ $(sha256sum scripts/zshrc | cut -d ' ' -f 1) = "095ed1ef56d4f644c2ebbac01e93763affba300c7605c2ae937e32139000adf8" ]; then
   echo "095ed1ef56d4f644c2ebbac01e93763affba300c7605c2ae937e32139000adf8 Verified OK"
   else echo "095ed1ef56d4f644c2ebbac01e93763affba300c7605c2ae937e32139000adf8 Failed"; exit 1
   fi
}

if PM="$( which apt-get )" 2> /dev/null; then
   echo "Found apt-get"
   man=1
elif PM="$( which pacman )" 2> /dev/null; then
   echo "Found pacman"
   man=2
elif PM="$( which yum )" 2> /dev/null; then
   echo "Found yum"
   man=3
else
   echo "Unsupported distro" >&2
   exit 1
fi

# Install and set as default
if PM="$( which zsh )" 2> /dev/null; then
   echo "zsh already installed"
else
   _installzsh
   echo "Installed zsh successfully"
fi
chsh -s $(which zsh)
sleep 1

#Check integretiy of config files
_checkIntegrity
echo "Integrity check PASSED!"
sleep 1

echo "Backing Up Existing zsh config"
cp ~/.zshrc ~/.zshrc_backup

sleep 1
echo "Copying Kali's config"
cp scripts/zshrc ~/.zshrc

sleep 1
echo "Copying Auto Suggestions"
sudo mkdir -p /usr/share/
sudo git clone https://github.com/zsh-users/zsh-autosuggestions /usr/share/zsh-autosuggestions/

sleep 1
echo "Copying Highlighting script"
sudo git clone git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/zsh-syntax-highlighting/

sudo chmod 644 /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

sleep 1
echo "Copying Dircolors"
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
echo "Kali zsh config successfully installed. Log out and login to see the changes"
