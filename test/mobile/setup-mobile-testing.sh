#!/bin/bash

# Mobile Testing Setup Script
echo "📱 Setting up Mobile Testing Environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if Homebrew is installed
echo "🍺 Checking Homebrew..."
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo -e "${GREEN}✅ Homebrew is installed${NC}"
fi

# Install Java (required for Maestro)
echo "☕ Checking Java..."
if ! java -version &> /dev/null; then
    echo -e "${YELLOW}Installing Java...${NC}"
    brew install openjdk@11
    
    # Add Java to PATH
    echo 'export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"' >> ~/.zshrc
    export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
    
    echo -e "${GREEN}✅ Java installed${NC}"
else
    echo -e "${GREEN}✅ Java is already installed${NC}"
fi

# Check if Maestro is installed
echo "🎭 Checking Maestro..."
if ! command -v maestro &> /dev/null; then
    echo -e "${YELLOW}Installing Maestro...${NC}"
    curl -Ls "https://get.maestro.mobile.dev" | bash
    
    # Add Maestro to PATH
    echo 'export PATH="$PATH:$HOME/.maestro/bin"' >> ~/.zshrc
    export PATH="$PATH:$HOME/.maestro/bin"
    
    echo -e "${GREEN}✅ Maestro installed${NC}"
else
    echo -e "${GREEN}✅ Maestro is already installed${NC}"
fi

# Check Xcode Command Line Tools
echo "🔨 Checking Xcode Command Line Tools..."
if ! command -v xcrun &> /dev/null; then
    echo -e "${YELLOW}Installing Xcode Command Line Tools...${NC}"
    xcode-select --install
    echo -e "${BLUE}Please complete the Xcode Command Line Tools installation in the popup${NC}"
    echo -e "${BLUE}Press Enter after installation is complete...${NC}"
    read
else
    echo -e "${GREEN}✅ Xcode Command Line Tools are installed${NC}"
fi

# Test installations
echo ""
echo "🧪 Testing installations..."

# Test Java
if java -version &> /dev/null; then
    echo -e "${GREEN}✅ Java is working${NC}"
    java -version 2>&1 | head -1
else
    echo -e "${RED}❌ Java installation failed${NC}"
fi

# Test Maestro
if ~/.maestro/bin/maestro --version &> /dev/null; then
    echo -e "${GREEN}✅ Maestro is working${NC}"
    ~/.maestro/bin/maestro --version
else
    echo -e "${RED}❌ Maestro installation failed${NC}"
fi

# Test Xcode tools
if command -v xcrun &> /dev/null; then
    echo -e "${GREEN}✅ Xcode Command Line Tools are working${NC}"
else
    echo -e "${RED}❌ Xcode Command Line Tools not available${NC}"
fi

echo ""
echo "📋 Setup Summary:"
echo "================================"
echo "1. ☕ Java Runtime - Required for Maestro"
echo "2. 🎭 Maestro CLI - Mobile automation framework"  
echo "3. 🔨 Xcode Tools - iOS simulator management"
echo ""
echo "📱 Next Steps:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Start an iOS Simulator"
echo "3. Run: ./quick-mobile-test.sh"
echo ""
echo -e "${BLUE}🎉 Mobile testing environment setup complete!${NC}"