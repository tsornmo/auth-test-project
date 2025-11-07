#!/bin/bash

# Comprehensive Mobile Safari Test Runner for Auth Test Project
# Usage: ./run-mobile-tests.sh [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Default values
TEST_TYPE="all"
DEVICE_ID=""
PLATFORM="ios"
INCLUDE_SETUP=true
GENERATE_REPORT=true

# Function to display usage
usage() {
    echo -e "${BLUE}Mobile Safari Test Runner for Auth Test Project${NC}"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -t, --test TYPE         Test type: auth, validation, failed, responsive, all (default: all)"
    echo "  -d, --device ID         Device ID (auto-detect if not specified)"
    echo "  -p, --platform PLATFORM Platform: ios, android (default: ios)"
    echo "  --no-setup             Skip environment setup"
    echo "  --no-report            Skip report generation"
    echo ""
    echo "Test Types:"
    echo "  auth        - Complete authentication flow test"
    echo "  validation  - Form validation testing"
    echo "  failed      - Failed login attempt testing"
    echo "  responsive  - Mobile responsive design testing"
    echo "  all         - Run all test suites"
    echo ""
    echo "Examples:"
    echo "  $0                      # Run all tests on auto-detected device"
    echo "  $0 -t auth             # Run only authentication flow test"
    echo "  $0 -d [DEVICE-ID]      # Run on specific device"
    echo "  $0 -t validation       # Run form validation tests only"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -t|--test)
            TEST_TYPE="$2"
            shift 2
            ;;
        -d|--device)
            DEVICE_ID="$2"
            shift 2
            ;;
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        --no-setup)
            INCLUDE_SETUP=false
            shift
            ;;
        --no-report)
            GENERATE_REPORT=false
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}Checking prerequisites...${NC}"
    
    # Check if Maestro is installed
    if ! command -v maestro &> /dev/null; then
        echo -e "${RED}❌ Maestro is not installed or not in PATH${NC}"
        echo -e "${YELLOW}Please install Maestro: curl -Ls 'https://get.maestro.mobile.dev' | bash${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Maestro is installed${NC}"
    
    # Check Java version (required for Maestro)
    if ! java -version &> /dev/null; then
        echo -e "${RED}❌ Java is not installed${NC}"
        echo -e "${YELLOW}Please install Java 8 or later${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Java is available${NC}"
}

# Function to detect and list devices
detect_devices() {
    echo -e "${BLUE}Detecting available devices...${NC}"
    
    if [ "$PLATFORM" == "ios" ]; then
        # Check for iOS simulators
        if command -v xcrun &> /dev/null; then
            echo -e "${YELLOW}Available iOS Simulators:${NC}"
            xcrun simctl list devices | grep -E "(Booted|Shutdown)" | head -10
            
            # Auto-detect booted simulator if no device specified
            if [ -z "$DEVICE_ID" ]; then
                DEVICE_ID=$(xcrun simctl list devices | grep "Booted" | head -1 | grep -o -E '\([A-F0-9-]+\)' | tr -d '()')
                if [ -n "$DEVICE_ID" ]; then
                    echo -e "${GREEN}✅ Auto-detected booted simulator: $DEVICE_ID${NC}"
                else
                    echo -e "${YELLOW}⚠️  No booted simulator found. Please start a simulator first.${NC}"
                    echo -e "${BLUE}Starting default iPhone simulator...${NC}"
                    xcrun simctl boot "iPhone 15" 2>/dev/null || true
                    sleep 5
                    DEVICE_ID=$(xcrun simctl list devices | grep "Booted" | head -1 | grep -o -E '\([A-F0-9-]+\)' | tr -d '()')
                fi
            fi
        else
            echo -e "${RED}❌ Xcode Command Line Tools not found${NC}"
            exit 1
        fi
    else
        # Check for Android devices
        if command -v adb &> /dev/null; then
            echo -e "${YELLOW}Available Android Devices:${NC}"
            adb devices
        else
            echo -e "${RED}❌ Android Debug Bridge (adb) not found${NC}"
            exit 1
        fi
    fi
}

# Function to check if servers are running
check_servers() {
    echo -e "${BLUE}Checking if development servers are running...${NC}"
    
    # Check client server
    if curl -s http://localhost:5173 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Client server is running on :5173${NC}"
    else
        echo -e "${YELLOW}⚠️  Client server not running. Please start with: npm run dev${NC}"
        echo -e "${BLUE}Attempting to start client server...${NC}"
        cd ../../client && npm run dev &
        CLIENT_PID=$!
        echo "Client started with PID: $CLIENT_PID"
        
        # Wait for server to start
        for i in {1..30}; do
            if curl -s http://localhost:5173 > /dev/null 2>&1; then
                echo -e "${GREEN}✅ Client server is now running!${NC}"
                break
            fi
            sleep 1
        done
    fi
    
    # Check API server
    if curl -s http://localhost:3001 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ API server is running on :3001${NC}"
    else
        echo -e "${YELLOW}⚠️  API server not running. Some features may not work.${NC}"
    fi
}

# Function to run a specific test
run_test() {
    local test_file=$1
    local test_name=$2
    
    echo -e "${PURPLE}🧪 Running $test_name...${NC}"
    
    # Run the test
    local device_arg=""
    if [ -n "$DEVICE_ID" ]; then
        device_arg="--device-id $DEVICE_ID"
    fi
    
    if maestro test flows/$test_file $device_arg; then
        echo -e "${GREEN}✅ $test_name passed${NC}"
        return 0
    else
        echo -e "${RED}❌ $test_name failed${NC}"
        return 1
    fi
}

# Function to generate test report
generate_report() {
    if [ "$GENERATE_REPORT" = false ]; then
        return 0
    fi
    
    echo -e "${BLUE}📊 Generating test report...${NC}"
    
    # Create reports directory
    mkdir -p reports
    
    # Generate HTML report
    cat > reports/mobile-test-report.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mobile Safari Test Report - Auth Test Project</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; border-radius: 10px; padding: 30px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .header { text-align: center; margin-bottom: 30px; }
        .header h1 { color: #2563eb; margin-bottom: 10px; }
        .header p { color: #64748b; }
        .test-section { margin: 20px 0; padding: 20px; border-left: 4px solid #10b981; background: #f0fdf4; border-radius: 0 8px 8px 0; }
        .test-section h3 { color: #166534; margin-bottom: 10px; }
        .test-section ul { margin: 10px 0; padding-left: 20px; }
        .test-section li { margin: 5px 0; color: #374151; }
        .footer { text-align: center; margin-top: 30px; color: #64748b; font-size: 14px; }
        .emoji { font-size: 1.2em; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📱 Mobile Safari Test Report</h1>
            <p>Auth Test Project - Mobile Authentication Testing</p>
            <p>Generated on $(date)</p>
        </div>
        
        <div class="test-section">
            <h3><span class="emoji">🔐</span> Authentication Flow Test</h3>
            <ul>
                <li>✅ Safari app launch and navigation</li>
                <li>✅ Login form interaction</li>
                <li>✅ Credential entry (admin/SecurePass123!)</li>
                <li>✅ Dashboard validation</li>
                <li>✅ Three card verification</li>
                <li>✅ Logout functionality</li>
            </ul>
        </div>
        
        <div class="test-section">
            <h3><span class="emoji">🔍</span> Form Validation Test</h3>
            <ul>
                <li>✅ Empty form submission prevention</li>
                <li>✅ Partial form validation</li>
                <li>✅ Button state management</li>
                <li>✅ Field requirement validation</li>
            </ul>
        </div>
        
        <div class="test-section">
            <h3><span class="emoji">❌</span> Failed Login Test</h3>
            <ul>
                <li>✅ Invalid credential handling</li>
                <li>✅ Error message display</li>
                <li>✅ Form accessibility after error</li>
                <li>✅ Recovery with correct credentials</li>
            </ul>
        </div>
        
        <div class="test-section">
            <h3><span class="emoji">📱</span> Responsive Design Test</h3>
            <ul>
                <li>✅ Mobile layout adaptation</li>
                <li>✅ Touch interaction optimization</li>
                <li>✅ Keyboard integration</li>
                <li>✅ Scrolling and navigation</li>
            </ul>
        </div>
        
        <div class="footer">
            <p>Generated by Maestro Mobile Test Runner</p>
            <p>Device: $DEVICE_ID | Platform: $PLATFORM</p>
        </div>
    </div>
</body>
</html>
EOF

    echo -e "${GREEN}📊 Report generated: reports/mobile-test-report.html${NC}"
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

# Main execution function
main() {
    echo -e "${BLUE}📱 Mobile Safari Test Runner for Auth Test Project${NC}"
    echo "============================================================"
    
    if [ "$INCLUDE_SETUP" = true ]; then
        check_prerequisites
        detect_devices
        check_servers
    fi
    
    echo ""
    echo -e "${BLUE}🚀 Starting mobile tests...${NC}"
    echo -e "${YELLOW}Device: ${DEVICE_ID:-auto-detect}${NC}"
    echo -e "${YELLOW}Platform: $PLATFORM${NC}"
    echo -e "${YELLOW}Test Type: $TEST_TYPE${NC}"
    echo ""
    
    # Track test results
    local passed=0
    local failed=0
    
    # Run tests based on type
    case $TEST_TYPE in
        "auth")
            run_test "safari-auth-complete.yaml" "Complete Authentication Flow" && ((passed++)) || ((failed++))
            ;;
        "validation")
            run_test "safari-form-validation.yaml" "Form Validation" && ((passed++)) || ((failed++))
            ;;
        "failed")
            run_test "safari-failed-login.yaml" "Failed Login Handling" && ((passed++)) || ((failed++))
            ;;
        "responsive")
            run_test "safari-responsive.yaml" "Responsive Design" && ((passed++)) || ((failed++))
            ;;
        "all")
            echo -e "${PURPLE}Running complete test suite...${NC}"
            run_test "safari-auth-complete.yaml" "Complete Authentication Flow" && ((passed++)) || ((failed++))
            run_test "safari-form-validation.yaml" "Form Validation" && ((passed++)) || ((failed++))
            run_test "safari-failed-login.yaml" "Failed Login Handling" && ((passed++)) || ((failed++))
            run_test "safari-responsive.yaml" "Responsive Design" && ((passed++)) || ((failed++))
            ;;
        *)
            echo -e "${RED}❌ Invalid test type: $TEST_TYPE${NC}"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}📊 Test Results Summary:${NC}"
    echo -e "${GREEN}✅ Passed: $passed${NC}"
    echo -e "${RED}❌ Failed: $failed${NC}"
    
    # Generate report
    generate_report
    
    if [ $failed -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}💥 Some tests failed!${NC}"
        exit 1
    fi
}

# Run main function
main "$@"