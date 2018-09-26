#!/bin/sh

RELEASE_BRANCH=master
RELEASE_DIR=HCK_CI
AUTO_HCK=AutoHCK

rm -rf ${RELEASE_DIR}

if [ $1 == '--clean' ]
then
  exit
fi

# Array of the repositories' names, URLs and branchs for the release
repositories=(${AUTO_HCK} \
    "https://github.com/Daynix/AutoHCK2.git" \
    ${RELEASE_BRANCH} \
    "VirtHCK" \
    "https://github.com/daynix/VirtHCK.git" \
    ${RELEASE_BRANCH} \
    "HLK-Setup-Scripts" \
    "https://github.com/HCK-CI/HLK-Setup-Scripts.git" \
    ${RELEASE_BRANCH} \
    "OpenDHCPServerSetup" \
    "https://github.com/HCK-CI/OpenDHCPServerSetup.git" \
    ${RELEASE_BRANCH} \
    "toolsHCK" \
    "https://github.com/HCK-CI/toolsHCK.git" \
    ${RELEASE_BRANCH} \
    "rtoolsHCK" \
    "https://github.com/HCK-CI/rtoolsHCK.git" \
    ${RELEASE_BRANCH} \
    ${AUTO_HCK}"/playlists" \
    "https://github.com/HCK-CI/hlkplaylists.git" \
    ${RELEASE_BRANCH} \
    ${AUTO_HCK}"/filters" \
    "https://github.com/HCK-CI/hckfilters.git" \
    ${RELEASE_BRANCH} \
    )

# Array of external gems and versions
external_gems=("filelock" \
    "1.1.1" \
    "fileutils" \
    "1.0.2" \
    "net-ping" \
    "2.0.4" \
    "octokit" \
    "4.3.0" \
    "mixlib-cli" \
    "1.7.0" \
    "net-telnet" \
    "0.1.1" \
    "winrm" \
    "1.8.1" \
    "winrm-fs" \
    "1.2.0" \
    "dropbox_api" \
    "0.1.12" \
    "faraday" \
    "0.12.2" \
    )

# Array of internal gems and versions
internal_gems=("rtoolsHCK" \
    )

echo "Building AutoHCK release from branch:"${RELEASE_BRANCH}

mkdir ${RELEASE_DIR}

# Clone sources to release directory
repo_length=${#repositories[@]}
for (( i=0; i<${repo_length}; i=$i+3 ));
do
  echo "Cloning: ${repositories[i+1]}:${repositories[i+2]}"
  git clone ${repositories[i+1]} ${RELEASE_DIR}/${repositories[i]}
  cd ${RELEASE_DIR}/${repositories[i]}
  if [ ${repositories[i+2]} != "master" ]; then
    git checkout -b ${repositories[i+2]}
  fi
  cd -
done

mkdir ${RELEASE_DIR}/workspace
mkdir ${RELEASE_DIR}/images

# Copy the gems
mkdir ${RELEASE_DIR}/gems

# Build and copy internal gems
for gem in "${internal_gems[@]}"
do
  cd ${RELEASE_DIR}/${gem}
  rake build
  cd -
  mv ${RELEASE_DIR}/${gem}/pkg/*.gem ${RELEASE_DIR}/gems
  mv ${RELEASE_DIR}/${gem}/*.gem ${RELEASE_DIR}/gems
  rm -rf ${RELEASE_DIR}/${gem}
done

# Copy external gems
cd ${RELEASE_DIR}/gems
gems_length=${#external_gems[@]}
for (( i=0; i<${gems_length}; i=$i+2 ));
do
  gem fetch ${external_gems[i]} -v ${external_gems[i+1]}
done
cd -

# Rename example triggers file
mv ${RELEASE_DIR}/${AUTO_HCK}/triggers.yml.example ${RELEASE_DIR}/${AUTO_HCK}/triggers.yml

# Move toolsHCK script to AutoHCK
mv ${RELEASE_DIR}/toolsHCK/toolsHCK.ps1 ${RELEASE_DIR}/${AUTO_HCK}/.
rm -rf ${RELEASE_DIR}/toolsHCK

# Copy release notes
cp release_notes.txt ${RELEASE_DIR}

