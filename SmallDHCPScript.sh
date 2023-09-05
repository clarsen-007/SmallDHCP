#!/bin/bash

# Version: 01.00.00.00

echo "Script was created for Ubuntu 22.04..."
echo ""

# Script, should be run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or sudo."
   exit 1
fi

# Install the DHCP server package
apt install isc-dhcp-server -y

# Backup the original DHCP configuration file
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dh.cpdconf
echo "Created Backup of original Configuration file to -- /etc/dhcp/dh.cpdconf"
cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.old.config
echo "Created Backup of original Server Configuration file to -- /etc/default/isc-dhcp-server.old.config"

# Configure the DHCP server
echo "Please provide the network interface name for DHCP (e.g., eth0):"
read interface

echo "Please provide the IP range for DHCP (e.g., 192.168.1.100 192.168.1.200) - Note - you have to set start and end range - as per example:"
read ip_range
echo "Please provide the subnet for DHCP (e.g., 192.168.1.0):"
read subnet_sub
echo "Please provide the subnet mask for DHCP (e.g., 255.255.255.0):"
read subnet_mask

echo "Please provide the default gateway for DHCP:"
read default_gateway

echo "Please provide the DNS server for DHCP:"
read dns_server

cat > /etc/dhcp/dhcpd.conf << EOF
subnet $subnet_sub netmask $subnet_mask {
  range $ip_range;
 option domain-name-servers $dns_server;
 option routers $default_gateway;
   default-lease-time 3000;
   max-lease-time 7200;}
EOF

gawk -i inplace '!/INTERFACESv4/' /etc/default/isc-dhcp-server
echo -e "INTERFACESv4=\"$interface\"" >> /etc/default/isc-dhcp-server

# Restart the DHCP server
systemctl restart isc-dhcp-server

# Enable the DHCP server to start on boot
systemctl enable isc-dhcp-server

echo "DHCP configuration completed successfully."
echo ""

echo "Testing DHCP configuration...  if it does not show ERRORS, then it should work fine!! Hold thumbs..."
dhcpd -t -cf /etc/dhcp/dhcpd.conf
