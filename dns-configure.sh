#!/bin/bash

ipv4=$(curl -4 ipv4.ip.sb 2>/dev/null)
ipv6=$(curl -6 ipv6.ip.sb 2>/dev/null)

echo "" > /etc/resolv.conf

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