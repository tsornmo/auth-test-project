#!/bin/bash

# Comprehensive Playwright Test Runner
# Usage: ./run-tests.sh [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
MODE="test"
BROWSER="chromium"
HEADED=false
REPORT=true
INSTALL_DEPS=false

# Function to display usage
usage() {
    echo -e "${BLUE}Playwright Test Runner for Auth Test Project${NC}"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -m, --mode MODE     Test mode: test, debug, ui, codegen (default: test)"
    echo "  -b, --browser NAME  Browser: chromium, firefox, webkit, all (default: chromium)"
    echo "  -H, --headed        Run in headed mode (visible browser)"
    echo "  -r, --report        Open report after tests (default: true)"
    echo "  -i, --install       Install browser dependencies"
    echo "  --mobile           Run mobile tests only"
    echo "  --auth-only        Run authentication tests only"
    echo ""
    echo "Examples:"
    echo "  $0                           # Run all tests headless with chromium"
    echo "  $0 -H -b firefox            # Run with Firefox in headed mode"
    echo "  $0 -m debug                 # Run in debug mode"
    echo "  $0 -m ui                    # Run with Playwright UI"
    echo "  $0 --mobile                 # Run mobile tests only"
    echo "  $0 --auth-only -H           # Run auth tests only in headed mode"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        -b|--browser)
            BROWSER="$2"
            shift 2
            ;;
        -H|--headed)
            HEADED=true
            shift
            ;;
        -r|--report)
            REPORT=true
            shift
            ;;
        -i|--install)
            INSTALL_DEPS=true
            shift
            ;;
        --mobile)
            BROWSER="mobile"
            shift
            ;;
        --auth-only)
            TEST_FILE="tests/auth.spec.js"
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Function to install dependencies
install_dependencies() {
    echo -e "${YELLOW}Installing Playwright browsers and dependencies...${NC}"
    npm run test:install
    npm run test:install-deps
    echo -e "${GREEN}Dependencies installed successfully!${NC}"
}

# Function to check if servers are running
check_servers() {
    echo -e "${BLUE}Checking if development servers are running...${NC}"
    
    # Check if client is running
    if ! curl -s http://localhost:5173 > /dev/null 2>&1; then
        echo -e "${YELLOW}Client server not running. Starting...${NC}"
        cd ../../client && npm run dev &
        CLIENT_PID=$!
        echo "Client PID: $CLIENT_PID"
        
        # Wait for server to start
        echo "Waiting for client server to start..."
        for i in {1..30}; do
            if curl -s http://localhost:5173 > /dev/null 2>&1; then
                echo -e "${GREEN}Client server is ready!${NC}"
                break
            fi
            sleep 1
        done
    else
        echo -e "${GREEN}Client server is already running!${NC}"
    fi
    
    # Check if server is running (if needed)
    if ! curl -s http://localhost:3001 > /dev/null 2>&1; then
        echo -e "${YELLOW}API server not running. Consider starting it for full functionality.${NC}"
    else
        echo -e "${GREEN}API server is running!${NC}"
    fi
}

# Function to run tests
run_tests() {
    local cmd="npx playwright"
    
    case $MODE in
        "test")
            cmd="$cmd test"
            ;;
        "debug")
            cmd="$cmd test --debug"
            ;;
        "ui")
            cmd="$cmd test --ui"
            ;;
        "codegen")
            cmd="$cmd codegen http://localhost:5173"
            return 0
            ;;
        *)
            echo -e "${RED}Invalid mode: $MODE${NC}"
            exit 1
            ;;
    esac
    
    # Add browser selection
    if [ "$BROWSER" = "mobile" ]; then
        cmd="$cmd --project='Mobile Chrome' --project='Mobile Safari'"
    elif [ "$BROWSER" = "all" ]; then
        # Use all browsers (default projects)
        true
    elif [ "$BROWSER" != "chromium" ]; then
        cmd="$cmd --project=$BROWSER"
    else
        cmd="$cmd --project=chromium"
    fi
    
    # Add headed mode
    if [ "$HEADED" = true ]; then
        cmd="$cmd --headed"
    fi
    
    # Add specific test file if set
    if [ -n "$TEST_FILE" ]; then
        cmd="$cmd $TEST_FILE"
    fi
    
    echo -e "${BLUE}Running command: $cmd${NC}"
    eval $cmd
}

# Function to generate and show report
show_report() {
    if [ "$REPORT" = true ] && [ "$MODE" = "test" ]; then
        echo -e "${BLUE}Opening test report...${NC}"
        npm run test:report
    fi
}

# Function to cleanup
cleanup() {
    if [ -n "$CLIENT_PID" ]; then
        echo -e "${YELLOW}Stopping client server (PID: $CLIENT_PID)...${NC}"
        kill $CLIENT_PID 2>/dev/null || true
    fi
}

# Set up cleanup trap
trap cleanup EXIT

# Main execution
main() {
    echo -e "${BLUE}🚀 Playwright Test Runner for Auth Test Project${NC}"
    echo "========================================================"
    
    # Install dependencies if requested
    if [ "$INSTALL_DEPS" = true ]; then
        install_dependencies
    fi
    
    # Check and start servers if needed
    check_servers
    
    # Run tests
    echo -e "${BLUE}Starting tests...${NC}"
    if run_tests; then
        echo -e "${GREEN}✅ Tests completed successfully!${NC}"
        show_report
    else
        echo -e "${RED}❌ Tests failed!${NC}"
        exit 1
    fi
}

# Run main function
main