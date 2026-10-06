#!/bin/bash

# ==========================================================
# AstroCloude + Free Dashboard Installer
# ==========================================================

set -u

# ==========================================================
# Paths / Repositories
# ==========================================================

ASTRO_PATH="/root/AstroCloude"
FREE_PATH="/root/Free-Dasebord"

ASTRO_REPO="https://github.com/Deepakdhakargamer/AstroCloude.git"
FREE_REPO="https://github.com/Deepakdhakargamer/Free-Dasebord.git"

PORT=3000

# ==========================================================
# Colors
# ==========================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ==========================================================
# Root Check
# ==========================================================

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}ERROR: Please run this installer as root.${NC}"
    exit 1
fi

# ==========================================================
# Stop Port
# ==========================================================

stop_port() {

    echo -e "${YELLOW}Checking port ${PORT}...${NC}"

    if command -v fuser >/dev/null 2>&1; then
        fuser -k "${PORT}/tcp" >/dev/null 2>&1 || true
    fi

    sleep 2
}

# ==========================================================
# Install System Requirements
# ==========================================================

install_requirements() {

    echo ""
    echo -e "${CYAN}==========================================${NC}"
    echo -e "${CYAN}     Installing System Requirements${NC}"
    echo -e "${CYAN}==========================================${NC}"
    echo ""

    apt-get update

    apt-get install -y \
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

    # ------------------------------------------------------
    # Install Node.js 20 if Node.js is missing
    # ------------------------------------------------------

    if command -v node >/dev/null 2>&1; then

        echo -e "${GREEN}Node.js already installed:${NC}"
        node -v

    else

        echo -e "${YELLOW}Installing Node.js 20...${NC}"

        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

        apt-get install -y nodejs

    fi

    echo ""
    echo "Node.js:"
    node -v

    echo "NPM:"
    npm -v

    echo ""
}

# ==========================================================
# Clone / Update Free Dashboard
# ==========================================================

prepare_free_dashboard() {

    if [ -d "$FREE_PATH/.git" ]; then

        echo "Free Dashboard already exists."
        echo "Updating repository..."

        cd "$FREE_PATH" || return 1

        git pull || {
            echo -e "${YELLOW}Git pull failed. Using existing files.${NC}"
        }

    elif [ -d "$FREE_PATH" ]; then

        echo -e "${YELLOW}Free Dashboard directory exists but is not a git repository.${NC}"

    else

        echo "Cloning Free Dashboard..."

        git clone "$FREE_REPO" "$FREE_PATH" || {
            echo -e "${RED}Failed to clone Free Dashboard.${NC}"
            return 1
        }

    fi

    return 0
}

# ==========================================================
# Install Free Dashboard
# ==========================================================

install_free_dashboard() {

    echo ""
    echo -e "${CYAN}==========================================${NC}"
    echo -e "${CYAN}       Installing Free Dashboard${NC}"
    echo -e "${CYAN}==========================================${NC}"
    echo ""

    prepare_free_dashboard || return 1

    cd "$FREE_PATH" || {
        echo -e "${RED}Cannot enter $FREE_PATH${NC}"
        return 1
    }

    if [ ! -f "package.json" ]; then

        echo -e "${RED}ERROR: package.json not found.${NC}"
        return 1

    fi

    echo ""
    echo "Installing Free Dashboard dependencies..."
    echo ""

    npm install || {
        echo -e "${RED}Free Dashboard npm install failed.${NC}"
        return 1
    }

    echo ""
    echo -e "${GREEN}Free Dashboard installation completed.${NC}"
    echo ""

    stop_port

    cd "$FREE_PATH" || return 1

    echo -e "${CYAN}Starting Free Dashboard...${NC}"
    echo ""

    npm run dev
}

# ==========================================================
# Clone / Update AstroCloude
# ==========================================================

prepare_astrocloude() {

    if [ -d "$ASTRO_PATH/.git" ]; then

        echo "AstroCloude already exists."
        echo "Updating repository..."

        cd "$ASTRO_PATH" || return 1

        git pull || {
            echo -e "${YELLOW}Git pull failed. Using existing files.${NC}"
        }

    elif [ -d "$ASTRO_PATH" ]; then

        echo -e "${YELLOW}AstroCloude directory exists but is not a git repository.${NC}"

    else

        echo "Cloning AstroCloude..."

        git clone "$ASTRO_REPO" "$ASTRO_PATH" || {
            echo -e "${RED}Failed to clone AstroCloude.${NC}"
            return 1
        }

    fi

    return 0
}

# ==========================================================
# Install AstroCloude
# ==========================================================

install_astrocloude() {

    echo ""
    echo -e "${CYAN}==========================================${NC}"
    echo -e "${CYAN}          Installing AstroCloude${NC}"
    echo -e "${CYAN}==========================================${NC}"
    echo ""

    # ------------------------------------------------------
    # Clone / Update
    # ------------------------------------------------------

    prepare_astrocloude || return 1

    # ------------------------------------------------------
    # IMPORTANT: Always enter project directory
    # ------------------------------------------------------

    cd "$ASTRO_PATH" || {

        echo -e "${RED}ERROR: Cannot enter $ASTRO_PATH${NC}"
        return 1

    }

    echo ""
    echo -e "${GREEN}AstroCloude directory:${NC}"
    pwd
    echo ""

    # ------------------------------------------------------
    # package.json check
    # ------------------------------------------------------

    if [ ! -f "package.json" ]; then

        echo -e "${RED}ERROR: package.json not found!${NC}"
        echo ""
        echo "Current directory:"
        pwd
        echo ""

        return 1

    fi

    # ------------------------------------------------------
    # Node / NPM information
    # ------------------------------------------------------

    echo "Node version:"
    node -v

    echo "NPM version:"
    npm -v

    echo ""

    # ------------------------------------------------------
    # Stop existing Vite
    # ------------------------------------------------------

    stop_port

    # ------------------------------------------------------
    # Remove broken dependencies
    # ------------------------------------------------------

    echo -e "${CYAN}[1/7] Removing old node_modules...${NC}"

    rm -rf node_modules

    echo -e "${CYAN}[2/7] Removing package-lock.json...${NC}"

    rm -f package-lock.json

    # ------------------------------------------------------
    # Clean npm cache
    # ------------------------------------------------------

    echo -e "${CYAN}[3/7] Cleaning npm cache...${NC}"

    npm cache clean --force

    # ------------------------------------------------------
    # Install dependencies
    # ------------------------------------------------------

    echo -e "${CYAN}[4/7] Installing dependencies with optional packages...${NC}"

    npm install --include=optional || {

        echo ""
        echo -e "${RED}ERROR: npm install failed.${NC}"
        return 1

    }

    # ------------------------------------------------------
    # Install Tailwind Oxide
    # ------------------------------------------------------

    echo -e "${CYAN}[5/7] Installing @tailwindcss/oxide...${NC}"

    npm install @tailwindcss/oxide --force || {

        echo ""
        echo -e "${RED}ERROR: @tailwindcss/oxide installation failed.${NC}"
        return 1

    }

    # ------------------------------------------------------
    # Install Linux x64 native binding
    # ------------------------------------------------------

    echo -e "${CYAN}[6/7] Installing Linux native Tailwind Oxide binding...${NC}"

    npm install @tailwindcss/oxide-linux-x64-gnu --force || {

        echo ""
        echo -e "${RED}ERROR: Linux native Tailwind Oxide binding failed.${NC}"
        echo ""
        echo "Your system may not be compatible with the x64 GNU binding."
        return 1

    }

    # ------------------------------------------------------
    # Verify native binding
    # ------------------------------------------------------

    echo -e "${CYAN}[7/7] Verifying Tailwind native binding...${NC}"

    if [ ! -d "node_modules/@tailwindcss/oxide" ]; then

        echo -e "${RED}ERROR: @tailwindcss/oxide is missing.${NC}"
        return 1

    fi

    if [ ! -d "node_modules/@tailwindcss/oxide-linux-x64-gnu" ]; then

        echo -e "${RED}ERROR: Linux native Oxide binding is missing.${NC}"
        return 1

    fi

    echo ""
    echo -e "${GREEN}==========================================${NC}"
    echo -e "${GREEN}     AstroCloude Dependencies Ready${NC}"
    echo -e "${GREEN}==========================================${NC}"
    echo ""

    echo "Project:"
    echo "$ASTRO_PATH"

    echo ""
    echo "Port:"
    echo "$PORT"

    echo ""

    # ------------------------------------------------------
    # Final directory check
    # ------------------------------------------------------

    cd "$ASTRO_PATH" || {

        echo -e "${RED}ERROR: Cannot enter AstroCloude directory.${NC}"
        return 1

    }

    # ------------------------------------------------------
    # Verify package.json before starting
    # ------------------------------------------------------

    if [ ! -f "package.json" ]; then

        echo -e "${RED}ERROR: package.json disappeared or is missing.${NC}"
        return 1

    fi

    echo -e "${GREEN}Starting AstroCloude...${NC}"
    echo ""

    # package.json already contains:
    # vite --port=3000 --host=0.0.0.0

    npm run dev
}

# ==========================================================
# Delete Free Dashboard
# ==========================================================

delete_free_dashboard() {

    echo ""
    echo -e "${YELLOW}Deleting Free Dashboard...${NC}"
    echo ""

    if [ -d "$FREE_PATH" ]; then

        rm -rf "$FREE_PATH"

        echo -e "${GREEN}Free Dashboard deleted successfully.${NC}"

    else

        echo -e "${YELLOW}Free Dashboard is not installed.${NC}"

    fi

    echo ""
}

# ==========================================================
# Delete AstroCloude
# ==========================================================

delete_astrocloude() {

    echo ""
    echo -e "${YELLOW}Deleting AstroCloude...${NC}"
    echo ""

    if [ -d "$ASTRO_PATH" ]; then

        stop_port

        rm -rf "$ASTRO_PATH"

        echo -e "${GREEN}AstroCloude deleted successfully.${NC}"

    else

        echo -e "${YELLOW}AstroCloude is not installed.${NC}"

    fi

    echo ""
}

# ==========================================================
# Main Menu
# ==========================================================

while true; do

    clear

    echo ""
    echo -e "${CYAN}==========================================${NC}"
    echo -e "${CYAN}       AstroCloude Installer${NC}"
    echo -e "${CYAN}==========================================${NC}"
    echo ""
    echo "1) Install Free Dashboard"
    echo "2) Install AstroCloude"
    echo "3) Delete Free Dashboard"
    echo "4) Delete AstroCloude"
    echo "5) Exit"
    echo ""
    read -p "Select an option [1-5]: " OPTION

    case "$OPTION" in

        1)
            install_requirements
            install_free_dashboard
            ;;

        2)
            install_requirements
            install_astrocloude
            ;;

        3)
            delete_free_dashboard
            read -p "Press Enter to continue..."
            ;;

        4)
            delete_astrocloude
            read -p "Press Enter to continue..."
            ;;

        5)
            echo ""
            echo "Exiting..."
            exit 0
            ;;

        *)
            echo ""
            echo -e "${RED}Invalid option. Please select 1-5.${NC}"
            sleep 2
            ;;

    esac

done
