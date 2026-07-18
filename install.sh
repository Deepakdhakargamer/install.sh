#!/bin/bash

# ==========================
# Astro Dashboard Installer
# ==========================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

while true; do
    clear

    echo -e "${CYAN}==============================================${NC}"
    echo -e "${BLUE}         Astro Dashboard Installer${NC}"
    echo -e "${CYAN}==============================================${NC}"

    if [ -d "/root/Free-Dasebord" ]; then
        echo -e "${GREEN}Dashboard Status : Installed${NC}"
    else
        echo -e "${RED}Dashboard Status : Not Installed${NC}"
    fi

    echo ""
    echo -e "${YELLOW}1) Install Dashboard${NC}"
    echo -e "${YELLOW}2) Delete Dashboard${NC}"
    echo -e "${YELLOW}3) Exit${NC}"
    echo ""
    read -p "Select an option [1-3]: " OPTION

    case $OPTION in
    1)
        clear
        echo -e "${CYAN}Installing Astro Dashboard...${NC}"

        echo -e "${YELLOW}[1/7] Updating System...${NC}"
        apt update -y

        echo -e "${YELLOW}[2/7] Installing Required Packages...${NC}"
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

        echo -e "${YELLOW}[3/7] Installing Node.js 20...${NC}"
        if ! command -v node >/dev/null 2>&1; then
            curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
            apt install -y nodejs
        fi

        echo ""
        echo -e "${GREEN}Node Version : $(node -v)${NC}"
        echo -e "${GREEN}NPM Version  : $(npm -v)${NC}"
        echo ""

        echo -e "${YELLOW}[4/7] Downloading Dashboard...${NC}"

        rm -rf /root/Free-Dasebord

        git clone https://github.com/Deepakdhakargamer/Free-Dasebord.git /root/Free-Dasebord

        cd /root/Free-Dasebord

        echo -e "${YELLOW}[5/7] Installing NPM Packages...${NC}"

        rm -rf node_modules package-lock.json
        npm install

        echo -e "${YELLOW}[6/7] Resetting Database...${NC}"

        rm -f database.db database.sqlite
        find . -name "*.db" -delete
        find . -name "*.sqlite" -delete
        find . -name "*.sqlite3" -delete

        echo -e "${YELLOW}[7/7] Starting Dashboard...${NC}"

        npm run dev

        ;;
    2)
        clear

        if [ -d "/root/Free-Dasebord" ]; then
            echo -e "${YELLOW}Deleting Dashboard...${NC}"

            rm -rf /root/Free-Dasebord

            echo -e "${GREEN}Dashboard Deleted Successfully!${NC}"
        else
            echo -e "${RED}Dashboard is not installed.${NC}"
        fi

        echo ""
        read -p "Press Enter to return to menu..."
        ;;
    3)
        clear
        echo -e "${GREEN}Thank you for using Astro Dashboard Installer!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid Option!${NC}"
        sleep 2
        ;;
    esac
done
