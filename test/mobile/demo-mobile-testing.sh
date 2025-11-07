#!/bin/bash

# Demo Mobile Test Runner (No Simulator Required)
echo "📱 Maestro Mobile Testing Demo"
echo "============================="

# Set Java path
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"

cd "$(dirname "$0")"

echo "☕ Java Version:"
java -version 2>&1 | head -1

echo ""
echo "🎭 Maestro Version:"
~/.maestro/bin/maestro --version

echo ""
echo "📋 Available Mobile Test Flows:"
echo "1. safari-auth-complete.yaml    - Complete authentication flow"
echo "2. safari-form-validation.yaml  - Form validation testing"
echo "3. safari-failed-login.yaml     - Failed login testing"
echo "4. safari-responsive.yaml       - Responsive design testing"

echo ""
echo "🧪 Test Flow Preview (safari-auth-complete.yaml):"
echo "================================"
head -20 flows/safari-auth-complete.yaml

echo ""
echo "📱 To run mobile tests:"
echo "1. Start iOS Simulator:"
echo "   - Open Simulator app"
echo "   - Or run: xcrun simctl boot 'iPhone 15'"
echo ""
echo "2. Run the quick test:"
echo "   ./quick-mobile-test.sh"
echo ""
echo "3. Or run comprehensive tests:"
echo "   ./run-mobile-tests.sh"
echo ""
echo "4. Validate servers are running:"
echo "   - Client: http://localhost:5173 ✅"
echo "   - Server: http://localhost:3001 ⚠️ (optional)"

# Check servers
echo ""
echo "🌐 Server Status:"
if curl -s http://localhost:5173 > /dev/null 2>&1; then
    echo "   ✅ Client server (localhost:5173) is running"
else
    echo "   ❌ Client server (localhost:5173) is not running"
    echo "      Start with: cd ../../client && npm run dev"
fi

if curl -s http://localhost:3001 > /dev/null 2>&1; then
    echo "   ✅ API server (localhost:3001) is running"
else
    echo "   ⚠️  API server (localhost:3001) is not running (optional)"
fi

echo ""
echo "🎯 Mobile Test Capabilities:"
echo "   ✅ Safari navigation and URL entry"
echo "   ✅ Touch-based form interaction"
echo "   ✅ Mobile keyboard integration"
echo "   ✅ Responsive layout validation"
echo "   ✅ Authentication flow verification"
echo "   ✅ Card validation with scrolling"
echo "   ✅ Screenshot capture at each step"
echo "   ✅ Error handling and recovery"

echo ""
echo "💡 When you have a simulator running, the tests will:"
echo "   1. Launch Safari automatically"
echo "   2. Navigate to your localhost app"
echo "   3. Perform touch interactions"
echo "   4. Validate the complete auth flow"
echo "   5. Generate screenshots and reports"

echo ""
echo "🎭 Maestro Mobile Testing is ready!"