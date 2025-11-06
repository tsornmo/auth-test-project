#!/bin/bash

# Simple script to start both client and server in separate terminal windows
# This works better for development as you can see logs from both services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting Auth Test Project in separate terminals..."

# Start server in new terminal
osascript -e "tell application \"Terminal\" to do script \"cd '$SCRIPT_DIR/server' && npm run dev\""

# Wait a moment
sleep 1

# Start client in new terminal  
osascript -e "tell application \"Terminal\" to do script \"cd '$SCRIPT_DIR/client' && npm run dev\""

echo "✅ Started both services in separate Terminal windows"
echo "🔗 Server: http://localhost:3001"
echo "🔗 Client: http://localhost:5173"
echo "📝 Login: admin / SecurePass123!"