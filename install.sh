#!/bin/bash

set -e

echo "======================================"
echo " Astro Dashboard Installer"
echo "======================================"

if ! command -v git >/dev/null 2>&1; then
    apt update
    apt install -y git
fi

if ! command -v npm >/dev/null 2>&1; then
    echo "Node.js/npm is not installed!"
    exit 1
fi

git clone https://github.com/Deepakdhakargamer/Free-Dasebord.git

cd Free-Dasebord

npm install

npm run dev
