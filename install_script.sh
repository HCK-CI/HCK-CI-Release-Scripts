#!/bin/bash

#Update if you want to install in a different path
INSTALL_PATH=~/HCK-CI

#Disable if you are using existing/custom Qemu
#Update the path in the config.json file
INSTALL_QEMU=yes

#Disable if gems are already installed
INSTALL_GEMS=yes

#Disable if you already have a DHCP server configured on machine
#validate bridge and ip range in config.json file
INSTALL_DHCP=yes

#Update the following according to the release notes
GITHUB_REPO=
GITHUB_LOGIN=
GITHUB_TOKEN=
DROPBOX_TOKEN=

if [ -d "$INSTALL_PATH" ]; then
  echo "Installation path Already exists."
  exit
fi

if [ -z "$GITHUB_REPO" ]; then
  echo "WARNING: github repository value is empty"
fi

if [ -z "$GITHUB_LOGIN" ]; then
  echo "WARNING: github login value is empty"
fi

if [ -z "$GITHUB_TOKEN" ]; then
  echo "WARNING: github token value is empty"
fi


if [ -z "$DROPBOX_TOKEN" ]; then
  echo "WARNING: Dropbox token value is empty"
fi

if [ -z "$INSTALL_PATH" ]; then
  echo "Installation path Already exists, aborting."
  exit
fi

RELEASE_DIR=HCK_CI

echo Copying files to installtion path
mkdir -p $INSTALL_PATH
cd $INSTALL_PATH
#Get absolute path 
INSTALL_PATH=$(pwd)
cd -
cp -rf $RELEASE_DIR/* $INSTALL_PATH

if [[ "$INSTALL_QEMU" == "yes" ]]; then
  cd $INSTALL_PATH
  git clone https://github.com/qemu/qemu.git
  cd qemu
  ./configure --disable-docs --target-list=x86_64-softmmu
  make -j
  cd -
  qemu=$INSTALL_PATH/x86_64-softmmu/qemu-system-x86_64
  qemu_img=$INSTALL_PATH/qemu_img
  ivshmem_server=$INSTALL_PATH/ivshmem_server
fi

if [[ "$INSTALL_GEMS" == "yes" ]]; then
  cd $INSTALL_PATH/gems
  gem install *
  cd -
fi

if [[ "$INSTALL_DHCP" == "yes" ]]; then
  cd $INSTALL_PATH/OpenDHCPServerSetup
  sudo ./opendhcpserverSetup.sh
  cd -
fi

cat > $INSTALL_PATH/AutoHCK/config.json <<EOF
l
    "workspace_path": "$INSTALL_PATH/workspace",
    "virthck_path": "$INSTALL_PATH/VirtHCK",
    "images_path": "$INSTALL_PATH/images",
    "qemu_img": "$qemu_bin",
    "qemu_bin": "$qemu_img",
    "ivshmem_server_bin": "$ivshmem_server",
    "ip_segment": "192.168.0.",
    "id_range": [ 2, 90 ],
    "dhcp_bridge": "br1",
    "winrm_port": "5985",
    "platforms_defaults": {
      "world_net_device": "e1000e",
      "ctrl_net_device": "e1000e",
      "file_transfer_device": "e1000e",
      "machine_type": "pc",
      "s3": "on",
      "s4": "on",
      "enlightenments_state": "off",
      "vhost_state": "on"
    },
    "toolshck_path": "./toolsHCK.ps1",
    "filesystem_tests_image": "$INSTALL_PATH/images/filesystem_tests_image.qcow2",
    "studio_username": "Administrator",
    "studio_password": "Qum5net.",
    "repository": "$GITHUB_REPO",
    "github_credentials": {
      "login": "$GITHUB_LOGIN",
      "password": "$GITHUB_TOKEN"
    },
    "dropbox_token": "$dropbox_token"
}
EOF

echo "Intallation finished."
echo "AutoHCK general config file: $INSTALL_PATH/AutoHCK/config.json"
echo "AutoHCK devices config file: $INSTALL_PATH/AutoHCK/devices.json"
echo "AutoHCK platforms config file: $INSTALL_PATH/AutoHCK/platforms.json"
