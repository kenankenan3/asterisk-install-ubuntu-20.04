#!/bin/bash

# This script installs Asterisk on Ubuntu 20.04 and sets up necessary dependencies.

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "Please run this script as root or with sudo privileges." 1>&2
   exit 1
fi

# Update the system
echo "Updating the system..."
apt update && apt upgrade -y

# Install required packages
echo "Installing necessary dependencies..."
apt install -y build-essential git wget libncurses5-dev libncursesw5-dev libssl-dev \
libxml2-dev libsqlite3-dev uuid-dev libjansson-dev libedit-dev pkg-config curl

# Download the Asterisk source code
echo "Downloading the Asterisk source code..."
cd /usr/src
ASTERISK_VERSION="20-current"
wget -4 http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${ASTERISK_VERSION}.tar.gz

# Extract the source code
echo "Extracting the Asterisk source code..."
tar xvf asterisk-${ASTERISK_VERSION}.tar.gz
cd asterisk-*/

# Install additional dependencies
echo "Installing additional dependencies..."
contrib/scripts/install_prereq install

# Configure Asterisk
echo "Configuring Asterisk..."
./configure

# Download files required for MP3 support
echo "Downloading MP3 module..."
contrib/scripts/get_mp3_source.sh

# Compile and install Asterisk
echo "Compiling and installing Asterisk..."
make -j$(nproc)
make install

# Install sample configuration files
echo "Installing sample configuration files..."
make samples

# Set up Asterisk as a system service
echo "Setting up Asterisk as a system service..."
make config
ldconfig

# Create the Asterisk user and group
echo "Creating Asterisk user and group..."
adduser --quiet --system --group --home /var/lib/asterisk asterisk

# Set file permissions
echo "Setting file permissions..."
chown -R asterisk:asterisk /etc/asterisk
chown -R asterisk:asterisk /var/{lib,log,spool}/asterisk
chown -R asterisk:asterisk /usr/lib/asterisk

# Start the Asterisk service and enable it to start on boot
echo "Starting Asterisk service and enabling it to start on boot..."
systemctl start asterisk
systemctl enable asterisk

echo "Asterisk installation completed successfully!"
