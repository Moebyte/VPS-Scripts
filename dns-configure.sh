#!/bin/bash

if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root."
    exit 1
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "curl not found, installing..."
    apt update && apt install -y curl
fi

ipv4=$(curl -4 ipv4.ip.sb 2>/dev/null)
ipv6=$(curl -6 ipv6.ip.sb 2>/dev/null)

# Check if IP address is in China
if curl -m 10 -s https://ipapi.co/json | grep -q 'China'; then
  echo "IP address is in China."
  if [ -n "$ipv4" ] && [ -n "$ipv6" ]; then
    echo "Both IPv4 and IPv6 are available."
    echo "nameserver 119.29.29.29" > /etc/resolv.conf
    echo "nameserver 223.5.5.5" >> /etc/resolv.conf
    echo "nameserver 2402:4e00::" >> /etc/resolv.conf
    echo "nameserver 2400:3200::1" >> /etc/resolv.conf
  elif [ -n "$ipv4" ]; then
    echo "Only IPv4 is available."
    echo "nameserver 119.29.29.29" > /etc/resolv.conf
    echo "nameserver 223.5.5.5" >> /etc/resolv.conf
  elif [ -n "$ipv6" ]; then
    echo "Only IPv6 is available."
    echo "nameserver 2402:4e00::" > /etc/resolv.conf
    echo "nameserver 2400:3200::1" >> /etc/resolv.conf
  else
    echo "Neither IPv4 nor IPv6 is available."
  fi
else
  echo "IP address is not in China."
  if [ -n "$ipv4" ] && [ -n "$ipv6" ]; then
    echo "Both IPv4 and IPv6 are available."
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    echo "nameserver 1.0.0.1" >> /etc/resolv.conf
    echo "nameserver 2001:4860:4860::8888" >> /etc/resolv.conf
    echo "nameserver 2606:4700:4700::1111" >> /etc/resolv.conf
  elif [ -n "$ipv4" ]; then
    echo "Only IPv4 is available."
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    echo "nameserver 1.0.0.1" >> /etc/resolv.conf
  elif [ -n "$ipv6" ]; then
    echo "Only IPv6 is available."
    echo "nameserver 2001:4860:4860::8888" > /etc/resolv.conf
    echo "nameserver 2606:4700:4700::1111" >> /etc/resolv.conf
  else
    echo "Neither IPv4 nor IPv6 is available."
  fi
fi
