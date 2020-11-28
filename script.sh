#!/bin/bash

# Sha256 sum of included files
# 2e57a55cb059ee5535f1e4efcc3b1cd6f2ecc01a97326372126b7d98f343e624 dircolors
# 7f5d56a502671c18cdf8056239c67963afd58bd21c19717ec5921cdc314dc75e zsh-autosuggestions.zsh
# b597811f7f6c1169d45d4820d3a3dcfc5053ceefb8f88c5b0f4562f500499884 zsh-syntax-highlighting.zsh
# 095ed1ef56d4f644c2ebbac01e93763affba300c7605c2ae937e32139000adf8 zshrc

# Variable that defines package manager
#
# 1-apt
# 2-pacman
# 3-yum
#
man=0

_installzsh() {
  if [ $man = 1 ]; then sudo apt install zsh; fi
  if [ $man = 2 ]; then sudo pacman -Sy zsh; fi
  if [ $man = 3 ]; then sudo yum update && sudo yum -y install zsh; fi
  if PM="$( which zsh )" 2> /dev/null; then
     echo "zsh already installed"
  else
     echo "Installing zsh Failed Aborting"
     exit 1
  fi
}

_checkIntegrity() {
   echo "Verifying sha256sum of dircolors"
   if [ $(sha256sum scripts/dircolors | cut -d ' ' -f 1) = "2e57a55cb059ee5535f1e4efcc3b1cd6f2ecc01a97326372126b7d98f343e624" ]; then
   echo "2e57a55cb059ee5535f1e4efcc3b1cd6f2ecc01a97326372126b7d98f343e624 Verified OK"
   else echo "2e57a55cb059ee5535f1e4efcc3b1cd6f2ecc01a97326372126b7d98f343e624 Failed"; exit 1
   fi
   echo "Verifying sha256sum of zsh-autosuggestions.zsh"
   if [ $(sha256sum scripts/zsh-autosuggestions.zsh | cut -d ' ' -f 1) = "7f5d56a502671c18cdf8056239c67963afd58bd21c19717ec5921cdc314dc75e" ]; then
   echo "7f5d56a502671c18cdf8056239c67963afd58bd21c19717ec5921cdc314dc75e Verified OK"
   else echo "7f5d56a502671c18cdf8056239c67963afd58bd21c19717ec5921cdc314dc75e Failed"; exit 1
   fi
   echo "Verifying sha256sum of zsh-syntax-highlighting.zsh"
   if [ $(sha256sum scripts/zsh-syntax-highlighting.zsh | cut -d ' ' -f 1) = "b597811f7f6c1169d45d4820d3a3dcfc5053ceefb8f88c5b0f4562f500499884" ]; then
   echo "b597811f7f6c1169d45d4820d3a3dcfc5053ceefb8f88c5b0f4562f500499884 Verified OK"
   else echo "b597811f7f6c1169d45d4820d3a3dcfc5053ceefb8f88c5b0f4562f500499884 Failed"; exit 1
   fi
   echo "Verifying sha256sum of zshrc"
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

#Check integretiy of config files
_checkIntegrity
echo "Integrity check PASSED!"

echo "Backing Up Existing zsh config"
cp ~/.zshrc ~/.zshrc_backup

echo "Copying Kali's config"
cp scripts/zshrc ~/.zshrc

echo "Copying Auto Suggestions"
sudo mkdir -p /usr/share/zsh-autosuggestions/
sudo cp scripts/zsh-autosuggestions.zsh /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

echo "Copying Highlighting script"
sudo mkdir -p /usr/share/zsh-syntax-highlighting/
sudo cp scripts/zsh-syntax-highlighting.zsh /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

sudo chmod 644 /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

echo "Copying Dircolors"
if [ -f /usr/bin/dircolors ]; then echo "Already Exists";
else
  if [ ! -d /usr/bin/ ]; then
    sudo mkdir -p /usr/bin
    echo "export PATH=$PATH:/usr/bin" >> ~/.zshrc
  fi
  sudo cp scripts/dircolors /usr/bin/dircolors
fi

sudo chmod +x /usr/bin/dircolors

echo "Kali zsh config successfully installed. Log out and login to see the changes"
