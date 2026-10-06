#!/bin/bash

# ==========================================
# AstroCloude + Free Dashboard Installer
# ==========================================

set -u

ASTRO_PATH="/root/AstroCloude"
FREE_PATH="/root/Free-Dasebord"

ASTRO_REPO="https://github.com/Deepakdhakargamer/AstroCloude.git"
FREE_REPO="https://github.com/Deepakdhakargamer/Free-Dasebord.git"

PORT=3000

# ==========================================
# Colors
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ==========================================
# Root Check
# ==========================================

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run this installer as root.${NC}"
    exit 1
fi

# ==========================================
# Stop Port
# ==========================================

stop_port() {
    echo -e "${YELLOW}Checking port $PORT...${NC}"

    if command -v fuser >/dev/null 2>&1; then
        fuser -k "${PORT}/tcp" >/dev/null 2>&1 || true
    fi

    sleep 1
}

# ==========================================
# Install System Requirements
# ==========================================

install_requirements() {

    echo ""
    echo -e "${CYAN}=========================================${NC}"
    echo -e "${CYAN} Installing System Requirements${NC}"
    echo -e "${CYAN}=========================================${NC}"
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

    # ======================================
    # Node.js
    # ======================================

    if command -v node >/dev/null 2>&1; then

        NODE_VERSION=$(node -v)
        echo -e "${GREEN}Node.js already installed: $NODE_VERSION${NC}"

    else

        echo -e "${YELLOW}Installing Node.js 20...${NC}"

        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt-get install -y nodejs

    fi

    echo ""
    node -v
    npm -v
    echo ""
}

# ==========================================
# Install Free Dashboard
# ==========================================

install_free_dashboard() {

    echo ""
    echo -e "${CYAN}=========================================${NC}"
    echo -e "${CYAN} Installing Free Dashboard${NC}"
    echo -e "${CYAN}=========================================${NC}"
    echo ""

    if [ -d "$FREE_PATH" ]; then

        echo -e "${YELLOW}Free Dashboard already exists.${NC}"
        echo "Updating repository..."

        cd "$FREE_PATH" || {
            echo -e "${RED}Cannot enter $FREE_PATH${NC}"
            return 1
        }

        git pull

    else

        echo "Cloning Free Dashboard..."

        git clone "$FREE_REPO" "$FREE_PATH" || {
            echo -e "${RED}Failed to clone Free Dashboard.${NC}"
            return 1
        }

        cd "$FREE_PATH" || {
            echo -e "${RED}Cannot enter $FREE_PATH${NC}"
            return 1
        }

    fi

    if [ ! -f "package.json" ]; then
        echo -e "${RED}package.json not found in Free Dashboard.${NC}"
        return 1
    fi

    echo ""
    echo "Installing dependencies..."

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

# ==========================================
# Install AstroCloude
# ==========================================

install_astrocloude() {

    echo ""
    echo -e "${CYAN}=========================================${NC}"
    echo -e "${CYAN} Installing AstroCloude${NC}"
    echo -e "${CYAN}=========================================${NC}"
    echo ""

    if [ -d "$ASTRO_PATH" ]; then

        echo -e "${YELLOW}AstroCloude already exists.${NC}"
        echo "Updating repository..."

        cd "$ASTRO_PATH" || {
            echo -e "${RED}Cannot enter $ASTRO_PATH${NC}"
            return 1
        }

        git pull || {
            echo -e "${YELLOW}Git pull failed, continuing with existing files...${NC}"
        }

    else

        echo "Cloning AstroCloude..."

        git clone "$ASTRO_REPO" "$ASTRO_PATH" || {
            echo -e "${RED}Failed to clone AstroCloude.${NC}"
            return 1
        }

    fi

    # ======================================
    # ALWAYS ENTER CORRECT DIRECTORY
    # ======================================

    cd "$ASTRO_PATH" || {
        echo -e "${RED}ERROR: Cannot enter $ASTRO_PATH${NC}"
        return 1
    }

    # ======================================
    # Check package.json
    # ======================================

    if [ ! -f "package.json" ]; then

        echo -e "${RED}ERROR: package.json not found!${NC}"
        echo "Current directory:"
        pwd
        return 1

    fi

    echo ""
    echo -e "${CYAN}Current project directory:${NC}"
    pwd

    echo ""
    echo -e "${CYAN}=========================================${NC}"
    echo -e "${CYAN} Fixing Node.js dependencies${NC}"
    echo -e "${CYAN}=========================================${NC}"
    echo ""

    # ======================================
    # Remove broken dependencies
    # ======================================

    echo "[1/5] Removing node_modules and lock file..."

    rm -rf node_modules package-lock.json

    # ======================================
    # Clean npm cache
    # ======================================

    echo "[2/5] Cleaning npm cache..."

    npm cache clean --force

    # ======================================
    # Install optional dependencies
    # ======================================

    echo "[3/5] Installing dependencies..."

    npm install --include=optional || {

        echo -e "${RED}npm install failed.${NC}"
        return 1

    }

    # ======================================
    # Tailwind Oxide Native Binding
    # ======================================

    echo "[4/5] Installing Tailwind CSS Oxide..."

    npm install @tailwindcss/oxide --force || {

        echo -e "${RED}Failed to install @tailwindcss/oxide.${NC}"
        return 1

    }

    # ======================================
    # Verify Installation
    # ======================================

    echo "[5/5] Verifying installation..."

    if [ ! -d "node_modules/@tailwindcss/oxide" ]; then

        echo -e "${RED}Tailwind CSS Oxide installation was not found.${NC}"
        return 1

    fi

    echo ""
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN} AstroCloude installation completed${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo ""

    echo "Project: $ASTRO_PATH"
    echo "Port: $PORT"
    echo ""

    # ======================================
    # Stop Existing Vite Process
    # ======================================

    stop_port

    # ======================================
    # IMPORTANT:
    # Run npm from AstroCloude directory
    # ======================================

    cd "$ASTRO_PATH" || {

        echo -e "${RED}ERROR: Cannot enter AstroCloude directory.${NC}"
        return 1

    }

    echo -e "${CYAN}Starting AstroCloude...${NC}"
    echo ""

    npm run dev
}

# ==========================================
# Delete Free Dashboard
# ==========================================

delete_free_dashboard() {

    echo ""
    echo -e "${YELLOW}Deleting Free Dashboard...${NC}"

    if [ -d "$FREE_PATH" ]; then

        rm -rf "$FREE_PATH"

        echo -e "${GREEN}Free Dashboard deleted successfully.${NC}"

    else

        echo -e "${YELLOW}Free Dashboard is not installed.${NC}"

    fi
}

# ==========================================
# Delete AstroCloude
# ==========================================

delete_astrocloude() {

    echo ""
    echo -e "${YELLOW}Deleting AstroCloude...${NC}"

    if [ -d "$ASTRO_PATH" ]; then

        stop_port

        rm -rf "$ASTRO_PATH"

        echo -e "${GREEN}AstroCloude deleted successfully.${NC}"

    else

        echo -e "${YELLOW}AstroCloude is not installed.${NC}"

    fi
}

# ==========================================
# Main Menu
# ==========================================

while true; do

    clear

    echo ""
    echo -e "${CYAN}=========================================${NC}"
    echo -e "${CYAN}       AstroCloude Installer${NC}"
    echo -e "${CYAN}=========================================${NC}"
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
            echo -e "${RED}Invalid option.${NC}"
            sleep 2
            ;;

    esac

done
