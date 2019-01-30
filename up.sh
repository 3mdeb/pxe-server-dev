#!/bin/bash

usage() {
  echo "Usage:"
  echo "NFS_SRV_IP=<server-ip> $0"
  exit 1
}

ipvalid() {
  # Set up local variables
  local ip=$NFS_SRV_IP
  local IFS=.; local -a a=($ip)
  # Start with a regex format test
  [[ $ip =~ ^[0-9]+(\.[0-9]+){3}$ ]] || return 1
  # Test values of quads
  for quad in {0..3}; do
    [[ "${a[$quad]}" -gt 255 ]] && return 1
  done
  return 0
}

# validate IP address
if [ -z "$NFS_SRV_IP" ]; then
  usage
fi

if ipvalid "$NFS_SRV_IP"; then
  echo "NFS server ip ($NFS_SRV_IP) is valid"
else
  echo "Wrong server ip address ($NFS_SRV_IP)"
  exit 1
fi

# create menu.ipxe file
cp ./netboot/menu.ipxe.sample ./netboot/menu.ipxe
sed -i "s/replace_with_ip/$NFS_SRV_IP/g"  ./netboot/menu.ipxe

# download kernels
wget https://cloud.3mdeb.com/index.php/s/UQQVYrNIhg7ddwj/download -O kernels.tar.gz
tar -xzvf kernels.tar.gz -C ./netboot && rm kernels.tar.gz

# start containers
docker-compose up
