#!/bin/bash

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

# Configure the DHCP server
echo "Please provide the network interface name for DHCP (e.g., eth0):"
read interface

echo "Please provide the IP range for DHCP (e.g., 192.168.1.100 192.168.1.200):"
read ip_range
echo "Please provide the subnet mask for DHCP (e.g., 255.255.255.0):"
read subnet_mask

echo "Please provide the default gateway for DHCP:"
read default_gateway

echo "Please provide the DNS server for DHCP:"
read dns_server

cat > /etc/dhcp/dhcpd.conf << EOF
subnet $(ip -o -f inet addr show $interface | awk '{print $4}' | cut -d '/' -f 1) netmask $subnet_mask {
  range $ip_range;
 option domain-name-servers $dns_server;
   default-lease-time ;
  max-lease-time 720}
EOF

# Restart the DHCP server
systemctl restart isc-dhcp-server

# Enable the DHCP server to start on boot
systemctl enable isc-dhcp-server

echo "DHCP configuration completed successfully."
