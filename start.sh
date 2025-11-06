#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Auth Test Project...${NC}"

# Function to cleanup on exit
cleanup() {
    echo -e "\n${RED}🛑 Shutting down servers...${NC}"
    pkill -f "nodemon index.js" 2>/dev/null
    pkill -f "vite" 2>/dev/null
    exit 0
}

# Trap signals to cleanup properly
trap cleanup SIGINT SIGTERM

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if ports are already in use
if lsof -Pi :3001 -sTCP:LISTEN -t >/dev/null ; then
    echo -e "${YELLOW}⚠️  Port 3001 is already in use. Killing existing process...${NC}"
    pkill -f "node.*3001" 2>/dev/null || true
    sleep 1
fi

if lsof -Pi :5173 -sTCP:LISTEN -t >/dev/null ; then
    echo -e "${YELLOW}⚠️  Port 5173 is already in use. Killing existing process...${NC}"
    pkill -f "vite" 2>/dev/null || true
    sleep 1
fi

# Start the server in background
echo -e "${GREEN}📡 Starting server on port 3001...${NC}"
cd "$SCRIPT_DIR/server"
npm run dev > server.log 2>&1 &
SERVER_PID=$!

# Wait for server to start
echo -e "${BLUE}⏳ Waiting for server to start...${NC}"
sleep 3

# Check if server started successfully
if ! lsof -Pi :3001 -sTCP:LISTEN -t >/dev/null ; then
    echo -e "${RED}❌ Server failed to start. Check server.log for details.${NC}"
    cat "$SCRIPT_DIR/server/server.log"
    exit 1
fi

# Start the client in background
echo -e "${GREEN}🌐 Starting client on port 5173...${NC}"
cd "$SCRIPT_DIR/client"
npm run dev > client.log 2>&1 &
CLIENT_PID=$!

# Wait for client to start
echo -e "${BLUE}⏳ Waiting for client to start...${NC}"
sleep 3

# Check if client started successfully
if ! lsof -Pi :5173 -sTCP:LISTEN -t >/dev/null ; then
    echo -e "${RED}❌ Client failed to start. Check client.log for details.${NC}"
    cat "$SCRIPT_DIR/client/client.log"
    cleanup
    exit 1
fi

echo -e "${GREEN}✅ Both servers are running successfully!${NC}"
echo -e "${BLUE}🔗 Server: http://localhost:3001${NC}"
echo -e "${BLUE}🔗 Client: http://localhost:5173${NC}"
echo -e "${BLUE}📝 Login credentials:${NC}"
echo -e "   Username: ${GREEN}admin${NC}"
echo -e "   Password: ${GREEN}SecurePass123!${NC}"
echo ""
echo -e "${BLUE}📋 Log files:${NC}"
echo -e "   Server: $SCRIPT_DIR/server/server.log"
echo -e "   Client: $SCRIPT_DIR/client/client.log"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop both servers${NC}"

# Monitor processes and restart if they crash
while true; do
    if ! kill -0 $SERVER_PID 2>/dev/null; then
        echo -e "${RED}❌ Server process died. Check server.log${NC}"
        break
    fi
    if ! kill -0 $CLIENT_PID 2>/dev/null; then
        echo -e "${RED}❌ Client process died. Check client.log${NC}"
        break
    fi
    sleep 5
done

cleanup