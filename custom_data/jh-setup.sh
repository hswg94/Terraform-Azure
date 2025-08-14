#!/bin/bash
apt-get update
apt-get install -y openssh-client curl wget htop

# Create a welcome message
echo "Welcome to Jumphost VM" > /etc/motd
echo "Use this server to SSH into private VMs:" >> /etc/motd
echo "VM1: ssh azureuser@10.18.0.20" >> /etc/motd
echo "VM2: ssh azureuser@10.18.0.21" >> /etc/motd