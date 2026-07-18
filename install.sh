#!/bin/bash
set -e

echo "======================================"
echo " Astro Dashboard Installer"
echo "======================================"

apt update
apt install -y curl git ca-certificates gnupg

if ! command -v node >/dev/null 2>&1; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
fi

echo "Node Version: $(node -v)"
echo "NPM Version: $(npm -v)"

rm -rf Free-Dasebord

git clone https://github.com/Deepakdhakargamer/Free-Dasebord.git

cd Free-Dasebord

npm install

npm run dev
