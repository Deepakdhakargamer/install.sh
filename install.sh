#!/bin/bash

clear

while true; do
    clear
    echo "======================================"
    echo "      Astro Dashboard Installer"
    echo "======================================"

    if [ -d "/root/Free-Dasebord" ]; then
        echo "Dashboard Status : Installed"
    else
        echo "Dashboard Status : Not Installed"
    fi

    echo ""
    echo "1) Install Dashboard"
    echo "2) Delete Dashboard"
    echo "3) Exit"
    echo ""
    read -p "Select an option [1-3]: " option

    case $option in
        1)
            apt update -y

            apt install -y \
                curl \
                git \
                ca-certificates \
                gnupg \
                build-essential \
                make \
                gcc \
                g++ \
                python3 \
                pkg-config \
                libsqlite3-dev

            if ! command -v node >/dev/null 2>&1; then
                curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
                apt install -y nodejs
            fi

            rm -rf /root/Free-Dasebord

            git clone https://github.com/Deepakdhakargamer/Free-Dasebord.git /root/Free-Dasebord

            cd /root/Free-Dasebord

            rm -rf node_modules package-lock.json

            npm install

            rm -f database.db database.sqlite
            find . -name "*.db" -delete
            find . -name "*.sqlite" -delete
            find . -name "*.sqlite3" -delete

            echo ""
            echo "Dashboard Installed Successfully!"
            echo ""
            npm run dev
            ;;

        2)
            rm -rf /root/Free-Dasebord

            echo ""
            echo "Dashboard Deleted Successfully!"
            read -p "Press Enter to continue..."
            ;;

        3)
            exit 0
            ;;

        *)
            echo "Invalid Option!"
            sleep 2
            ;;
    esac
done
