#!/bin/bash

# This script installs Asterisk on Ubuntu 20.04 and installs the necessary dependencies.

# Check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "Please run this script as root or with sudo." 1>&2
   exit 1
fi

# Update the system
echo "Updating the system..."
apt update && apt upgrade -y

# Install necessary packages
echo "Installing required dependencies..."
apt install -y build-essential git wget libncurses5-dev libncursesw5-dev libssl-dev \
libxml2-dev libsqlite3-dev uuid-dev libjansson-dev libedit-dev pkg-config curl \
libmp3lame-dev

# Download Asterisk source code
echo "Downloading Asterisk source code..."
cd /usr/src
ASTERISK_VERSION="20.4.0"  # Use the latest stable version number
wget -4 https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${ASTERISK_VERSION}.tar.gz

# Extract the source code
echo "Extracting Asterisk source code..."
tar xvf asterisk-${ASTERISK_VERSION}.tar.gz
cd asterisk-${ASTERISK_VERSION}/

# Install additional dependencies
echo "Installing additional dependencies..."
contrib/scripts/install_prereq install

# Configure Asterisk
echo "Configuring Asterisk..."
./configure

# Enable MP3 support with 'menuselect'
echo "Enabling MP3 module..."
make menuselect.makeopts
menuselect/menuselect --enable FORMAT_MP3 menuselect.makeopts

# Compile and install Asterisk
echo "Compiling and installing Asterisk..."
make -j$(nproc)
make install

# Install sample configuration files
echo "Installing sample configuration files..."
make samples

# Add Asterisk as a system service
echo "Adding Asterisk as a system service..."
make config
ldconfig

# Create Asterisk user and group
echo "Creating Asterisk user and group..."
adduser --quiet --system --group --home /var/lib/asterisk asterisk

# Set file permissions
echo "Setting file permissions..."
chown -R asterisk:asterisk /etc/asterisk
chown -R asterisk:asterisk /var/{lib,log,spool}/asterisk
chown -R asterisk:asterisk /usr/lib/asterisk

# Start the Asterisk service and enable it at boot
echo "Starting Asterisk service and enabling it at boot..."
systemctl start asterisk
systemctl enable asterisk

echo "Asterisk installation completed successfully!"
