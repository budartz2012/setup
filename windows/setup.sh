#! /bin/bash

# ===============================================================

vagrant_version="1.9.5"
php_version="7.0"
node_version="8.x"

# ===============================================================

clear

printf "\e[35m
  ____                 _             __  __           
 |  _ \  _____   _____| | ___  _ __ |  \/  | ___      
 | | | |/ _ \ \ / / _ \ |/ _ \| '_ \| |\/| |/ _ \     
 | |_| |  __/\ V /  __/ | (_) | |_) | |  | |  __/     
 |____/ \___| \_/ \___|_|\___/| .__/|_|  |_|\___|____ 
                              |_|              |_____|

 \e[32m
 Windows Setup Script v1.0

 —————————————————————————————————————————————————————

 This will install the following command line tools:

 • Git: version control made simple(ish)
 • Node: JavaScript on the command line 
 • Sass: makes CSS betterer 
 • Composer: installs all the PHP things 

 —————————————————————————————————————————————————————

 Ready? (y/n) \e[39m"

read -r input

if ([ "$input" == "no" ] || [ "$input" == "n" ]); then
    exit 1
fi

if [ "$USER" == "root" ]; then
    printf "
 \e[34m
 You are logged in as the root user

 You'll need to create a new user and then run the
 setup script again
 
 Pick a username (lowercase, no spaces): \e[39m"
    read -r username

    # create user
    useradd "$username" -m

    # add to sudo group
    sudo adduser "$username" sudo

    # set password
    passwd "$username"

    su -l "$username" 

    exit 0
fi

printf "\e[34m
 Ok, let's go...
 \e[39m
"

mkdir "$HOME/bin"

# allow non standard repos
sudo apt-get install -y python-software-properties

# add latest node repo
cd "$HOME" 
curl -sL "https://deb.nodesource.com/setup_${node_version}" | sudo -E bash -

sudo apt-get install -y git "php${php_version}" ruby nodejs
sudo gem install sass

# ===============================================================

# composer
EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    printf "Composer couldn't be installed"
else
    php composer-setup.php --quiet
    mv composer.phar "$HOME/bin/composer"
fi

rm composer-setup.php
source "$HOME/.profile"

# ===============================================================

# vagrant

cd "$HOME"
wget "https://releases.hashicorp.com/vagrant/${vagrant_version}/vagrant_${vagrant_version}_x86_64.deb"
sudo dpkg -i "vagrant_${vagrant_version}_x86_64.deb"

printf "\n\nexport VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=\"1\"" >> "$HOME/.profile"


# ===============================================================

printf "\e[35m

 —————————————————————————————————————————————————————

 And we're done!
 \e[39m
"