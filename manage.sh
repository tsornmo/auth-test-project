#!/bin/bash

# Auth Test Project Management Script
# Unified script for managing all project operations

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_DIR="$SCRIPT_DIR/.pids"
LOGS_DIR="$SCRIPT_DIR/logs"

# Ensure directories exist
mkdir -p "$PID_DIR" "$LOGS_DIR"

# Show usage information
show_usage() {
    echo -e "${BLUE}🚀 Auth Test Project Management${NC}"
    echo "=================================="
    echo ""
    echo -e "${YELLOW}Usage:${NC} ./manage.sh <command> [options]"
    echo ""
    echo -e "${YELLOW}Development Commands:${NC}"
    echo "  start, start-dev       Start development environment (default)"
    echo "  start-prod, prod       Start production environment"
    echo "  stop, shutdown         Stop all services"
    echo "  restart [dev|prod]     Restart services (default: dev)"
    echo "  status, st             Show service status"
    echo ""
    echo -e "${YELLOW}Log Management:${NC}"
    echo "  logs [view|tail|clear] [server|client|all]"
    echo "                     Manage application logs"
    echo "  logs-list          List available log files"
    echo ""
    echo -e "${YELLOW}Maintenance:${NC}"
    echo "  cleanup [--all|--logs|--builds|--deps|--temp]"
    echo "                     Clean build artifacts and temporary files"
    echo "  install            Install all dependencies"
    echo "  build              Build client for production"
    echo "  rebuild            Complete rebuild (clean + install + build + start)"
    echo ""
    echo -e "${YELLOW}Testing:${NC}"
    echo "  test-web           Run web tests (Playwright)"
    echo "  test-mobile        Run mobile tests (Maestro)"
    echo "  test-all           Run all tests"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  ./manage.sh start                  # Start development (default)"
    echo "  ./manage.sh status                 # Check status"
    echo "  ./manage.sh logs tail server       # Follow server logs"
    echo "  ./manage.sh restart prod           # Restart in production"
    echo "  ./manage.sh cleanup --all          # Clean everything"
}

# Function to check service status
check_service() {
    local service_name="$1"
    local port="$2"
    local pid_file="$PID_DIR/${service_name}.pid"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
                return 0  # Running
            else
                return 1  # Process exists but port not listening
            fi
        else
            rm -f "$pid_file"
            return 2  # Not running, stale PID
        fi
    else
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            return 3  # Running without PID file
        else
            return 2  # Not running
        fi
    fi
}

# Function to start development environment
start_dev() {
    echo -e "${BLUE}🚀 Starting Auth Test Project (Development Mode)...${NC}"

    # Check if services are already running
    check_service "server" "3001"
    local server_status=$?
    
    check_service "client" "5173"
    local client_status=$?

    if [ $server_status -eq 0 ]; then
        echo -e "${YELLOW}⚠️  Server is already running (PID: $(cat "$PID_DIR/server.pid"))${NC}"
    else
        echo -e "${GREEN}📡 Starting server on port 3001...${NC}"
        cd "$SCRIPT_DIR/server"
        
        # Start server and capture PID
        nohup npm run dev > "$LOGS_DIR/server-dev.log" 2>&1 &
        local server_pid=$!
        echo $server_pid > "$PID_DIR/server.pid"
        
        echo -e "${BLUE}   ⏳ Waiting for server to start...${NC}"
        
        # Wait up to 15 seconds for server to start
        local count=0
        local server_ready=false
        while [ $count -lt 15 ]; do
            if lsof -Pi :3001 -sTCP:LISTEN -t >/dev/null 2>&1; then
                server_ready=true
                break
            fi
            
            # Check if process is still running
            if ! kill -0 $server_pid 2>/dev/null; then
                echo -e "${RED}   ❌ Server process died during startup${NC}"
                echo -e "${YELLOW}   📋 Last few lines of server log:${NC}"
                tail -n 5 "$LOGS_DIR/server-dev.log" | sed 's/^/      /'
                return 1
            fi
            
            echo -e "${BLUE}   ⏳ Still waiting... ($((count + 1))/15)${NC}"
            sleep 1
            count=$((count + 1))
        done
        
        if [ "$server_ready" = true ]; then
            echo -e "${GREEN}   ✅ Server started successfully (PID: $server_pid)${NC}"
        else
            echo -e "${RED}   ❌ Server failed to start (timeout)${NC}"
            echo -e "${YELLOW}   📋 Last few lines of server log:${NC}"
            tail -n 5 "$LOGS_DIR/server-dev.log" | sed 's/^/      /'
            return 1
        fi
    fi

    if [ $client_status -eq 0 ]; then
        echo -e "${YELLOW}⚠️  Client is already running (PID: $(cat "$PID_DIR/client.pid"))${NC}"
    else
        echo -e "${GREEN}🌐 Starting client on port 5173...${NC}"
        cd "$SCRIPT_DIR/client"
        
        # Start client and capture PID
        nohup npm run dev > "$LOGS_DIR/client-dev.log" 2>&1 &
        local client_pid=$!
        echo $client_pid > "$PID_DIR/client.pid"
        
        echo -e "${BLUE}   ⏳ Waiting for client to start...${NC}"
        
        # Wait up to 20 seconds for client to start (Vite can be slower)
        local count=0
        local client_ready=false
        while [ $count -lt 20 ]; do
            if lsof -Pi :5173 -sTCP:LISTEN -t >/dev/null 2>&1; then
                client_ready=true
                break
            fi
            
            # Check if process is still running
            if ! kill -0 $client_pid 2>/dev/null; then
                echo -e "${RED}   ❌ Client process died during startup${NC}"
                echo -e "${YELLOW}   📋 Last few lines of client log:${NC}"
                tail -n 5 "$LOGS_DIR/client-dev.log" | sed 's/^/      /'
                return 1
            fi
            
            echo -e "${BLUE}   ⏳ Still waiting... ($((count + 1))/20)${NC}"
            sleep 1
            count=$((count + 1))
        done
        
        if [ "$client_ready" = true ]; then
            echo -e "${GREEN}   ✅ Client started successfully (PID: $client_pid)${NC}"
        else
            echo -e "${RED}   ❌ Client failed to start (timeout)${NC}"
            echo -e "${YELLOW}   📋 Last few lines of client log:${NC}"
            tail -n 5 "$LOGS_DIR/client-dev.log" | sed 's/^/      /'
            return 1
        fi
    fi

    echo ""
    echo -e "${GREEN}🎉 Development environment ready!${NC}"
    
    # Test if services are actually responding
    echo -e "${BLUE}🔍 Verifying services are responding...${NC}"
    
    # Test server endpoint
    if curl -s http://localhost:3001 >/dev/null 2>&1; then
        echo -e "${GREEN}   ✅ Server is responding${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Server port is open but may not be fully ready yet${NC}"
    fi
    
    # Test client endpoint
    if curl -s http://localhost:5173 >/dev/null 2>&1; then
        echo -e "${GREEN}   ✅ Client is responding${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Client port is open but may not be fully ready yet${NC}"
    fi
    
    echo ""
    show_urls
    
    echo ""
    echo -e "${CYAN}💡 Quick commands:${NC}"
    echo -e "   ${GREEN}./manage.sh status${NC}        - Check detailed status"
    echo -e "   ${GREEN}./manage.sh logs tail${NC}     - Follow all logs"
    echo -e "   ${GREEN}./manage.sh stop${NC}          - Stop all services"
}

# Function to start production environment
start_prod() {
    echo -e "${BLUE}🚀 Starting Auth Test Project (Production Mode)...${NC}"

    # Build client first
    echo -e "${GREEN}🔨 Building client for production...${NC}"
    cd "$SCRIPT_DIR/client"
    npm run build
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Client build failed${NC}"
        exit 1
    fi

    # Check if server is already running
    check_service "server" "3001"
    if [ $? -eq 0 ]; then
        echo -e "${YELLOW}⚠️  Server is already running (PID: $(cat "$PID_DIR/server.pid"))${NC}"
    else
        echo -e "${GREEN}📡 Starting server on port 3001...${NC}"
        cd "$SCRIPT_DIR/server"
        nohup npm start > "$LOGS_DIR/server-prod.log" 2>&1 &
        echo $! > "$PID_DIR/server.pid"
        echo -e "${GREEN}✅ Server started (PID: $!)${NC}"
    fi

    sleep 3
    echo ""
    echo -e "${GREEN}🎉 Production environment ready!${NC}"
    show_urls
}

# Function to stop services
stop_services() {
    echo -e "${BLUE}🛑 Shutting down Auth Test Project...${NC}"

    local stopped_any=false

    # Stop server
    if [ -f "$PID_DIR/server.pid" ]; then
        local pid=$(cat "$PID_DIR/server.pid")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "${YELLOW}🛑 Stopping server (PID: $pid)...${NC}"
            kill "$pid"
            wait_for_shutdown "$pid" "server"
            stopped_any=true
        fi
        rm -f "$PID_DIR/server.pid"
    fi

    # Stop client
    if [ -f "$PID_DIR/client.pid" ]; then
        local pid=$(cat "$PID_DIR/client.pid")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "${YELLOW}🛑 Stopping client (PID: $pid)...${NC}"
            kill "$pid"
            wait_for_shutdown "$pid" "client"
            stopped_any=true
        fi
        rm -f "$PID_DIR/client.pid"
    fi

    # Additional cleanup
    echo -e "${BLUE}🧹 Cleaning up any remaining processes...${NC}"
    cleanup_ports

    if [ "$stopped_any" = true ]; then
        echo -e "${GREEN}✅ All services stopped${NC}"
    else
        echo -e "${BLUE}ℹ️  No services were running${NC}"
    fi
}

# Function to wait for process shutdown
wait_for_shutdown() {
    local pid="$1"
    local service="$2"
    local count=0
    
    while kill -0 "$pid" 2>/dev/null && [ $count -lt 10 ]; do
        sleep 1
        count=$((count + 1))
    done
    
    if kill -0 "$pid" 2>/dev/null; then
        echo -e "${RED}⚠️  Force killing $service...${NC}"
        kill -9 "$pid" 2>/dev/null
    fi
    
    echo -e "${GREEN}✅ $service stopped${NC}"
}

# Function to cleanup ports
cleanup_ports() {
    # Kill processes on port 3001 (server)
    if lsof -Pi :3001 -sTCP:LISTEN -t >/dev/null 2>&1; then
        lsof -ti:3001 | xargs kill -9 2>/dev/null || true
    fi

    # Kill processes on port 5173 (client)
    if lsof -Pi :5173 -sTCP:LISTEN -t >/dev/null 2>&1; then
        lsof -ti:5173 | xargs kill -9 2>/dev/null || true
    fi

    # Clean up any node processes related to our project
    pkill -f "nodemon.*index.js" 2>/dev/null || true
    pkill -f "vite.*client" 2>/dev/null || true
}

# Function to show service status
show_status() {
    echo -e "${BLUE}📊 Auth Test Project Status${NC}"
    echo "================================"

    local overall_status=0
    
    # Check server
    printf "%-10s: " "Server"
    check_service "server" "3001"
    case $? in
        0) echo -e "${GREEN}✅ Running${NC} (PID: $(cat "$PID_DIR/server.pid"), Port: 3001)" ;;
        1) echo -e "${YELLOW}⚠️  Process running but port not listening${NC}" && overall_status=1 ;;
        2) echo -e "${RED}❌ Not running${NC}" && overall_status=1 ;;
        3) echo -e "${YELLOW}⚠️  Running without PID file${NC}" && overall_status=1 ;;
    esac

    # Check client
    printf "%-10s: " "Client"
    check_service "client" "5173"
    case $? in
        0) echo -e "${GREEN}✅ Running${NC} (PID: $(cat "$PID_DIR/client.pid"), Port: 5173)" ;;
        1) echo -e "${YELLOW}⚠️  Process running but port not listening${NC}" && overall_status=1 ;;
        2) echo -e "${RED}❌ Not running${NC}" && overall_status=1 ;;
        3) echo -e "${YELLOW}⚠️  Running without PID file${NC}" && overall_status=1 ;;
    esac

    echo ""

    if [ $overall_status -eq 0 ]; then
        echo -e "${GREEN}🎉 All services are running properly${NC}"
        show_urls
        show_recent_logs
    else
        echo -e "${YELLOW}⚠️  Some services need attention${NC}"
        echo -e "${BLUE}💡 Use './manage.sh start' to start missing services${NC}"
    fi
}

# Function to show URLs and credentials
show_urls() {
    echo -e "${BLUE}🔗 Available URLs:${NC}"
    echo -e "   Server: http://localhost:3001"
    echo -e "   Client: http://localhost:5173"
    echo ""
    echo -e "${BLUE}📝 Login credentials:${NC}"
    echo -e "   Username: admin"
    echo -e "   Password: SecurePass123!"
}

# Function to show recent log activity
show_recent_logs() {
    echo ""
    echo -e "${BLUE}📋 Recent log activity:${NC}"
    
    if [ -f "$LOGS_DIR/server-dev.log" ] || [ -f "$LOGS_DIR/server-prod.log" ]; then
        echo -e "${YELLOW}Server (last 2 lines):${NC}"
        if [ -f "$LOGS_DIR/server-dev.log" ]; then
            tail -n 2 "$LOGS_DIR/server-dev.log" 2>/dev/null | sed 's/^/   /' || echo "   (no recent activity)"
        elif [ -f "$LOGS_DIR/server-prod.log" ]; then
            tail -n 2 "$LOGS_DIR/server-prod.log" 2>/dev/null | sed 's/^/   /' || echo "   (no recent activity)"
        fi
    fi
    
    if [ -f "$LOGS_DIR/client-dev.log" ]; then
        echo -e "${YELLOW}Client (last 2 lines):${NC}"
        tail -n 2 "$LOGS_DIR/client-dev.log" 2>/dev/null | sed 's/^/   /' || echo "   (no recent activity)"
    fi
}

# Function to manage logs
manage_logs() {
    local action="${1:-view}"
    local service="${2:-all}"
    
    case "$action" in
        "list"|"ls")
            echo -e "${BLUE}📋 Available log files:${NC}"
            if [ -d "$LOGS_DIR" ]; then
                find "$LOGS_DIR" -name "*.log" -type f | while read -r logfile; do
                    local filename=$(basename "$logfile")
                    local size=$(du -h "$logfile" | cut -f1)
                    local modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$logfile" 2>/dev/null || stat -c "%y" "$logfile" | cut -d' ' -f1-2)
                    printf "  %-20s %8s  %s\n" "$filename" "$size" "$modified"
                done
            else
                echo -e "${YELLOW}  No logs directory found${NC}"
            fi
            ;;
        "view"|"show"|"cat")
            view_logs "$service"
            ;;
        "tail"|"follow"|"-f")
            follow_logs "$service"
            ;;
        "clear"|"clean"|"rm")
            clear_logs "$service"
            ;;
        *)
            echo -e "${RED}❌ Unknown log action: $action${NC}"
            echo -e "${BLUE}Available actions: view, tail, clear, list${NC}"
            exit 1
            ;;
    esac
}

# Function to view logs
view_logs() {
    local service="$1"
    
    case "$service" in
        "server")
            [ -f "$LOGS_DIR/server-dev.log" ] && echo -e "${BLUE}📡 Server Development Logs:${NC}" && cat "$LOGS_DIR/server-dev.log"
            [ -f "$LOGS_DIR/server-prod.log" ] && echo -e "${BLUE}📡 Server Production Logs:${NC}" && cat "$LOGS_DIR/server-prod.log"
            ;;
        "client")
            [ -f "$LOGS_DIR/client-dev.log" ] && echo -e "${BLUE}🌐 Client Development Logs:${NC}" && cat "$LOGS_DIR/client-dev.log"
            ;;
        "all"|*)
            [ -f "$LOGS_DIR/server-dev.log" ] && echo -e "${BLUE}📡 Server Development Logs:${NC}" && cat "$LOGS_DIR/server-dev.log" && echo ""
            [ -f "$LOGS_DIR/server-prod.log" ] && echo -e "${BLUE}📡 Server Production Logs:${NC}" && cat "$LOGS_DIR/server-prod.log" && echo ""
            [ -f "$LOGS_DIR/client-dev.log" ] && echo -e "${BLUE}🌐 Client Development Logs:${NC}" && cat "$LOGS_DIR/client-dev.log" && echo ""
            ;;
    esac
}

# Function to follow logs
follow_logs() {
    local service="$1"
    
    case "$service" in
        "server")
            if [ -f "$LOGS_DIR/server-dev.log" ]; then
                echo -e "${BLUE}📡 Following server logs (Ctrl+C to stop)...${NC}"
                tail -f "$LOGS_DIR/server-dev.log"
            else
                echo -e "${RED}❌ Server log file not found${NC}"
            fi
            ;;
        "client")
            if [ -f "$LOGS_DIR/client-dev.log" ]; then
                echo -e "${BLUE}🌐 Following client logs (Ctrl+C to stop)...${NC}"
                tail -f "$LOGS_DIR/client-dev.log"
            else
                echo -e "${RED}❌ Client log file not found${NC}"
            fi
            ;;
        "all"|*)
            echo -e "${BLUE}📋 Following all logs (Ctrl+C to stop)...${NC}"
            if [ -f "$LOGS_DIR/server-dev.log" ] && [ -f "$LOGS_DIR/client-dev.log" ]; then
                tail -f "$LOGS_DIR/server-dev.log" "$LOGS_DIR/client-dev.log"
            elif [ -f "$LOGS_DIR/server-dev.log" ]; then
                tail -f "$LOGS_DIR/server-dev.log"
            elif [ -f "$LOGS_DIR/client-dev.log" ]; then
                tail -f "$LOGS_DIR/client-dev.log"
            else
                echo -e "${RED}❌ No log files found${NC}"
            fi
            ;;
    esac
}

# Function to clear logs
clear_logs() {
    local service="$1"
    
    case "$service" in
        "server")
            rm -f "$LOGS_DIR/server-"*.log
            echo -e "${GREEN}✅ Server logs cleared${NC}"
            ;;
        "client")
            rm -f "$LOGS_DIR/client-"*.log
            echo -e "${GREEN}✅ Client logs cleared${NC}"
            ;;
        "all"|*)
            rm -f "$LOGS_DIR/"*.log
            echo -e "${GREEN}✅ All logs cleared${NC}"
            ;;
    esac
}

# Function to cleanup
cleanup() {
    local option="${1:-default}"
    
    echo -e "${BLUE}🧹 Cleaning up Auth Test Project...${NC}"
    
    case "$option" in
        "--all")
            clean_logs && clean_builds && clean_deps && clean_temp
            ;;
        "--logs")
            clean_logs
            ;;
        "--builds")
            clean_builds
            ;;
        "--deps")
            clean_deps
            ;;
        "--temp")
            clean_temp
            ;;
        "default"|"")
            clean_logs && clean_builds && clean_temp
            ;;
        *)
            echo -e "${RED}❌ Unknown cleanup option: $option${NC}"
            echo -e "${BLUE}Available options: --all, --logs, --builds, --deps, --temp${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}🎉 Cleanup completed!${NC}"
    command -v du >/dev/null 2>&1 && echo -e "${BLUE}💾 Current project size: $(du -sh "$SCRIPT_DIR" | cut -f1)${NC}"
}

# Cleanup helper functions
clean_logs() {
    echo -e "${YELLOW}🗑️  Cleaning logs...${NC}"
    rm -f "$LOGS_DIR/"*.log && echo -e "${GREEN}✅ Logs cleaned${NC}"
}

clean_builds() {
    echo -e "${YELLOW}🗑️  Cleaning build artifacts...${NC}"
    rm -rf "$SCRIPT_DIR/client/dist" "$SCRIPT_DIR/test/test-results" "$SCRIPT_DIR/test/playwright-report" "$SCRIPT_DIR/test/maestro-reports"
    echo -e "${GREEN}✅ Build artifacts cleaned${NC}"
}

clean_deps() {
    echo -e "${YELLOW}🗑️  Cleaning dependencies...${NC}"
    rm -rf "$SCRIPT_DIR/server/node_modules" "$SCRIPT_DIR/client/node_modules" "$SCRIPT_DIR/test/node_modules"
    echo -e "${GREEN}✅ Dependencies cleaned${NC}"
}

clean_temp() {
    echo -e "${YELLOW}🗑️  Cleaning temporary files...${NC}"
    rm -rf "$PID_DIR"
    find "$SCRIPT_DIR" -name "*.tmp" -o -name ".DS_Store" -o -name "Thumbs.db" | xargs rm -f 2>/dev/null || true
    rm -f "$SCRIPT_DIR/server/server.log" "$SCRIPT_DIR/client/client.log" 2>/dev/null || true
    echo -e "${GREEN}✅ Temporary files cleaned${NC}"
}

# Function to install dependencies
install_deps() {
    echo -e "${BLUE}📦 Installing all dependencies...${NC}"
    
    echo -e "${YELLOW}Installing server dependencies...${NC}"
    cd "$SCRIPT_DIR/server" && npm install
    
    echo -e "${YELLOW}Installing client dependencies...${NC}"
    cd "$SCRIPT_DIR/client" && npm install
    
    echo -e "${YELLOW}Installing test dependencies...${NC}"
    cd "$SCRIPT_DIR/test" && npm install
    
    echo -e "${GREEN}✅ All dependencies installed${NC}"
}

# Function to build client
build_client() {
    echo -e "${BLUE}🔨 Building client for production...${NC}"
    cd "$SCRIPT_DIR/client"
    npm run build
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Client build successful${NC}"
    else
        echo -e "${RED}❌ Client build failed${NC}"
        exit 1
    fi
}

# Function to run tests
run_tests() {
    local test_type="$1"
    
    cd "$SCRIPT_DIR/test"
    
    case "$test_type" in
        "web")
            echo -e "${BLUE}🧪 Running web tests (Playwright)...${NC}"
            npm run test:web
            ;;
        "mobile")
            echo -e "${BLUE}📱 Running mobile tests (Maestro)...${NC}"
            npm run test:mobile
            ;;
        "all"|*)
            echo -e "${BLUE}🧪 Running all tests...${NC}"
            npm test
            ;;
    esac
}

# Function to restart services
restart_services() {
    local mode="${1:-dev}"
    
    echo -e "${BLUE}🔄 Restarting Auth Test Project...${NC}"
    
    stop_services
    sleep 2
    
    if [ "$mode" = "prod" ] || [ "$mode" = "production" ]; then
        start_prod
    else
        start_dev
    fi
}

# Function to rebuild everything
rebuild_all() {
    echo -e "${BLUE}🔄 Complete rebuild of Auth Test Project...${NC}"
    echo ""
    
    echo -e "${YELLOW}Step 1: Stopping services...${NC}"
    stop_services
    echo ""
    
    echo -e "${YELLOW}Step 2: Cleaning everything...${NC}"
    cleanup "--all"
    echo ""
    
    echo -e "${YELLOW}Step 3: Installing dependencies...${NC}"
    install_deps
    echo ""
    
    echo -e "${YELLOW}Step 4: Building client...${NC}"
    build_client
    echo ""
    
    echo -e "${YELLOW}Step 5: Starting development environment...${NC}"
    start_dev
    echo ""
    
    echo -e "${GREEN}🎉 Complete rebuild finished!${NC}"
    echo -e "${BLUE}💡 Use './manage.sh status' to verify everything is working${NC}"
}

# Main command handling
case "${1:-help}" in
    "start-dev"|"dev"|"start")
        start_dev
        ;;
    "start-prod"|"prod"|"production")
        start_prod
        ;;
    "stop"|"shutdown"|"down")
        stop_services
        ;;
    "restart")
        restart_services "$2"
        ;;
    "status"|"ps"|"st")
        show_status
        ;;
    "logs")
        manage_logs "$2" "$3"
        ;;
    "logs-list")
        manage_logs "list"
        ;;
    "cleanup"|"clean")
        cleanup "$2"
        ;;
    "install")
        install_deps
        ;;
    "build")
        build_client
        ;;
    "rebuild"|"rebuild-all")
        rebuild_all
        ;;
    "test-web"|"test:web")
        run_tests "web"
        ;;
    "test-mobile"|"test:mobile")
        run_tests "mobile"
        ;;
    "test-all"|"test"|"test:all")
        run_tests "all"
        ;;
    "help"|"-h"|"--help"|*)
        show_usage
        ;;
esac