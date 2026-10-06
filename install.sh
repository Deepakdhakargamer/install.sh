#!/bin/bash

# =====================================
# Astro Dashboard Installer
# Free Dashboard + AstroCloude
# =====================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

FREE_PATH="/root/Free-Dasebord"
ASTRO_PATH="/root/AstroCloude"

FREE_REPO="https://github.com/Deepakdhakargamer/Free-Dasebord.git"
ASTRO_REPO="https://github.com/Deepakdhakargamer/AstroCloude.git"

PORT="3000"

# =====================================
# Functions
# =====================================

install_requirements() {

    echo -e "${YELLOW}[1/4] Updating System...${NC}"
    apt update -y

    echo -e "${YELLOW}[2/4] Installing Required Packages...${NC}"

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
        libsqlite3-dev \
        lsof \
        psmisc

    echo -e "${YELLOW}[3/4] Checking Node.js...${NC}"

    if ! command -v node >/dev/null 2>&1; then

        echo -e "${CYAN}Installing Node.js 20...${NC}"

        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt install -y nodejs

    fi

    echo -e "${GREEN}Node Version : $(node -v)${NC}"
    echo -e "${GREEN}NPM Version  : $(npm -v)${NC}"

    echo -e "${YELLOW}[4/4] Requirements Ready!${NC}"

    echo ""
}


# =====================================
# Stop Dashboard Processes
# =====================================

stop_port() {

    echo -e "${YELLOW}Freeing port ${PORT}...${NC}"

    fuser -k ${PORT}/tcp >/dev/null 2>&1 || true

    sleep 2
}


# =====================================
# Install Free Dashboard
# =====================================

install_free_dashboard() {

    clear

    echo -e "${CYAN}==============================================${NC}"
    echo -e "${BLUE}       Installing Free Dashboard${NC}"
    echo -e "${CYAN}==============================================${NC}"

    install_requirements

    echo -e "${YELLOW}Stopping anything using port ${PORT}...${NC}"
    stop_port

    echo -e "${YELLOW}Downloading Free Dashboard...${NC}"

    rm -rf "$FREE_PATH"

    git clone "$FREE_REPO" "$FREE_PATH"

    if [ ! -d "$FREE_PATH" ]; then
        echo -e "${RED}Failed to download Free Dashboard!${NC}"
        read -p "Press Enter to continue..."
        return
    fi

    cd "$FREE_PATH" || exit

    echo -e "${YELLOW}Installing NPM Packages...${NC}"

    rm -rf node_modules

    npm install

    if [ $? -ne 0 ]; then
        echo -e "${RED}NPM installation failed!${NC}"
        read -p "Press Enter to continue..."
        return
    fi

    echo ""
    echo -e "${GREEN}==============================================${NC}"
    echo -e "${GREEN}Free Dashboard Installed Successfully!${NC}"
    echo -e "${GREEN}Starting Dashboard on port ${PORT}...${NC}"
    echo -e "${GREEN}==============================================${NC}"
    echo ""

    npm run dev
}


# =====================================
# Install AstroCloude
# =====================================

install_astrocloude() {

    clear

    echo -e "${CYAN}==============================================${NC}"
    echo -e "${BLUE}          Installing AstroCloude${NC}"
    echo -e "${CYAN}==============================================${NC}"

    install_requirements

    echo -e "${YELLOW}Stopping anything using port ${PORT}...${NC}"
    stop_port

    echo -e "${YELLOW}Downloading AstroCloude...${NC}"

    rm -rf "$ASTRO_PATH"

    git clone "$ASTRO_REPO" "$ASTRO_PATH"

    if [ ! -d "$ASTRO_PATH" ]; then
        echo -e "${RED}Failed to download AstroCloude!${NC}"
        read -p "Press Enter to continue..."
        return
    fi

    cd "$ASTRO_PATH" || exit

    echo -e "${YELLOW}Installing NPM Packages...${NC}"

   
    rm -rf node_modules package-lock.json

    npm cache clean --force

    npm install --include=optional

    npm install @tailwindcss/oxide-linux-x64-gnu --save-dev --force rm -rf node_modules

    if [ $? -ne 0 ]; then
        echo -e "${RED}NPM installation failed!${NC}"
        read -p "Press Enter to continue..."
        return
    fi

    echo ""
    echo -e "${GREEN}==============================================${NC}"
    echo -e "${GREEN}AstroCloude Installed Successfully!${NC}"
    echo -e "${GREEN}Starting AstroCloude on port ${PORT}...${NC}"
    echo -e "${GREEN}==============================================${NC}"
    echo ""

    npm run dev
}


# =====================================
# Delete Free Dashboard
# =====================================

delete_free_dashboard() {

    clear

    echo -e "${RED}==============================================${NC}"
    echo -e "${RED}       Removing Free Dashboard${NC}"
    echo -e "${RED}==============================================${NC}"

    echo -e "${YELLOW}Stopping Dashboard...${NC}"

    fuser -k ${PORT}/tcp >/dev/null 2>&1 || true

    if command -v pm2 >/dev/null 2>&1; then
        pm2 delete astro-dashboard >/dev/null 2>&1 || true
    fi

    echo -e "${YELLOW}Deleting Dashboard Files...${NC}"

    rm -rf "$FREE_PATH"

    echo ""
    echo -e "${GREEN}==============================================${NC}"
    echo -e "${GREEN}Free Dashboard Deleted Successfully!${NC}"
    echo -e "${GREEN}==============================================${NC}"

    read -p "Press Enter to continue..."
}


# =====================================
# Delete AstroCloude
# =====================================

delete_astrocloude() {

    clear

    echo -e "${RED}==============================================${NC}"
    echo -e "${RED}          Removing AstroCloude${NC}"
    echo -e "${RED}==============================================${NC}"

    echo -e "${YELLOW}Stopping AstroCloude...${NC}"

    fuser -k ${PORT}/tcp >/dev/null 2>&1 || true

    if command -v pm2 >/dev/null 2>&1; then
        pm2 delete astrocloude >/dev/null 2>&1 || true
    fi

    echo -e "${YELLOW}Deleting AstroCloude Files...${NC}"

    rm -rf "$ASTRO_PATH"

    echo ""
    echo -e "${GREEN}==============================================${NC}"
    echo -e "${GREEN}AstroCloude Deleted Successfully!${NC}"
    echo -e "${GREEN}==============================================${NC}"

    read -p "Press Enter to continue..."
}


# =====================================
# Main Menu
# =====================================

while true; do

    clear

    echo -e "${CYAN}==============================================${NC}"
    echo -e "${BLUE}          Astro Dashboard Installer${NC}"
    echo -e "${CYAN}==============================================${NC}"

    echo ""

    # Free Dashboard Status
    if [ -d "$FREE_PATH" ]; then
        echo -e "${GREEN}Free Dashboard : Installed${NC}"
    else
        echo -e "${RED}Free Dashboard : Not Installed${NC}"
    fi

    # AstroCloude Status
    if [ -d "$ASTRO_PATH" ]; then
        echo -e "${GREEN}AstroCloude    : Installed${NC}"
    else
        echo -e "${RED}AstroCloude    : Not Installed${NC}"
    fi

    echo ""
    echo -e "${YELLOW}1) Install Free Dashboard${NC}"
    echo -e "${YELLOW}2) Install AstroCloude${NC}"
    echo -e "${YELLOW}3) Delete Free Dashboard${NC}"
    echo -e "${YELLOW}4) Delete AstroCloude${NC}"
    echo -e "${YELLOW}5) Exit${NC}"
    echo ""

    read -p "Select an option [1-5]: " OPTION

    case $OPTION in

        1)
            install_free_dashboard
            ;;

        2)
            install_astrocloude
            ;;

        3)
            delete_free_dashboard
            ;;

        4)
            delete_astrocloude
            ;;

        5)
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
