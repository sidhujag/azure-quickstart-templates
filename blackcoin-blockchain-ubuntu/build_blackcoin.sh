#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running BlackCoin    #
#################################################################
sudo apt-get update
#################################################################
# Build BlackCoin from source                                      #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building BlackCoin            #
#################################################################

sudo apt-get install -y checkinstall subversion git git-core libssl-dev libminiupnpc-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev build-essential libboost-all-dev automake libtool autoconf pkg-config

cd /usr/local
file=/usr/local/blackcoin
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/rat4/blackcoin
fi

cd /usr/local/blackcoin
file=/usr/local/blackcoin/src/blackcoind
if [ ! -e "$file" ]
then
	cd src
	sudo make -f makefile.unix
fi

sudo cp /usr/local/blackcoin/src/blackcoind /usr/bin/blackcoind

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.blackcoin 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.blackcoin
fi

sudo printf 'rpcuser=%s\n' $2  >> $HOME/.blackcoin/blackcoin.conf
sudo printf 'rpcpassword=%s\n' $3 >> $HOME/.blackcoin/blackcoin.conf
sudo printf 'rpcport=%s\n' $4 >> $HOME/.blackcoin/blackcoin.conf
sudo printf 'rpcallowip=%s\n' $5 >> $HOME/.blackcoin/blackcoin.conf
sudo printf 'server=1' >> $HOME/.blackcoin/blackcoin.conf
sudo printf 'daemon=1' >> $HOME/.blackcoin/blackcoin.conf

file=/etc/init.d/blackcoin
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo blackcoind' | sudo tee /etc/init.d/blackcoin
	sudo chmod +x /etc/init.d/blackcoin
	sudo update-rc.d blackcoin defaults	
fi

/usr/bin/blackcoind
echo "BlackCoin has been setup successfully and is running..."
exit 0
