#!/bin/bash
set -e

echo "======================================"
echo "     Astro Dashboard Installer"
echo "======================================"

echo "[1/6] Updating system..."
apt update -y

echo "[2/6] Installing required packages..."
apt install -y curl git ca-certificates gnupg \
build-essential make gcc g++ python3 pkg-config libsqlite3-dev

if ! command -v node >/dev/null 2>&1; then
    echo "[3/6] Installing Node.js 20..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
fi

echo "Node Version: $(node -v)"
echo "NPM Version: $(npm -v)"

echo "[4/6] Downloading project..."

if [ -d "Free-Dasebord" ]; then
    rm -rf Free-Dasebord
fi

git clone https://github.com/Deepakdhakargamer/Free-Dasebord.git

cd Free-Dasebord

echo "[5/6] Installing npm packages..."
rm -rf node_modules package-lock.json
npm install

echo "[6/6] Starting website..."
npm run dev
