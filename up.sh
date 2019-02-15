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

git submodule init
git submodule sync
git submodule update

# create menu.ipxe file
cp ./netboot/menu.ipxe.sample ./netboot/menu.ipxe
sed -i "s/replace_with_ip/$NFS_SRV_IP/g"  ./netboot/menu.ipxe

# download kernels
wget https://cloud.3mdeb.com/index.php/s/UQQVYrNIhg7ddwj/download -O kernels.tar.gz
tar -xzvf kernels.tar.gz -C ./netboot && rm kernels.tar.gz

# download root file systems
wget https://cloud.3mdeb.com/index.php/s/9b8h6WmJcNsuB57/download -O debian-stable.tar.gz
wget https://cloud.3mdeb.com/index.php/s/fzQ2FaRTdMvzXqO/download -O xen.tar.gz
wget https://cloud.3mdeb.com/index.php/s/AQuUdsYkBzO9UJz/download -O core.tar.gz
wget https://cloud.3mdeb.com/index.php/s/rUZPwRHOjxpSxN4/download -O voyage-0.11.0_amd64.tar.gz

NFS_EXPORT_DIR="./nfs-export"
mkdir -p $NFS_EXPORT_DIR

# extract debian
DEBIAN_DIR="$NFS_EXPORT_DIR/debian"
tar -xvpzf debian-stable.tar.gz -C $NFS_EXPORT_DIR --numeric-owner
mv $NFS_EXPORT_DIR/debian-stable $DEBIAN_DIR

# extract xen
XEN_DIR="$NFS_DIR/xen"
tar -xvpzf xen.tar.gz -C $NFS_EXPORT_DIR --numeric-owner

# extract voyage
VOYAGE_DIR="$NFS_EXPORT_DIR/voyage"
mkdir -p $VOYAGE_DIR
tar -xzvf voyage-0.11.0_amd64.tar.gz -C $VOYAGE_DIR

# extract core ??
tar -xvpzf core.tar.gz -C ./netboot

# remove
rm voyage-0.11.0_amd64.tar.gz
rm debian-stable.tar.gz
rm xen.tar.gz
rm core.tar.gz

# start containers
docker-compose up
