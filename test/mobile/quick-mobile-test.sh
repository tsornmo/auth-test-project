#!/bin/bash

# Quick Mobile Safari Authentication Test
echo "📱 Running Quick Mobile Safari Authentication Test..."

cd "$(dirname "$0")"

# Check if Maestro is installed
if ! command -v maestro &> /dev/null; then
    echo "❌ Maestro is not installed"
    echo "💡 Install with: curl -Ls 'https://get.maestro.mobile.dev' | bash"
    exit 1
fi

echo "✅ Maestro is available"

# Check if we can detect iOS simulators
echo "🔍 Checking for iOS Simulator..."

if command -v xcrun &> /dev/null; then
    # Xcode command line tools available
    DEVICE_ID=$(xcrun simctl list devices 2>/dev/null | grep "Booted" | head -1 | grep -o -E '\([A-F0-9-]+\)' | tr -d '()')
    
    if [ -z "$DEVICE_ID" ]; then
        echo "⚠️  No booted simulator found."
        echo "📱 Available simulators:"
        xcrun simctl list devices 2>/dev/null | grep -E "(iPhone|iPad)" | head -5
        echo ""
        echo "💡 To start a simulator:"
        echo "   - Open Xcode → Window → Devices and Simulators"
        echo "   - Or run: xcrun simctl boot 'iPhone 15'"
        exit 1
    fi
    
    echo "✅ Found booted simulator: $DEVICE_ID"
    DEVICE_ARG="--device-id $DEVICE_ID"
else
    # No Xcode command line tools - try without device specification
    echo "⚠️  Xcode command line tools not found"
    echo "💡 Install with: xcode-select --install"
    echo "📱 Attempting to run test without device specification..."
    DEVICE_ARG=""
fi

# Check if servers are running
echo "🌐 Checking servers..."
if ! curl -s http://localhost:5173 > /dev/null 2>&1; then
    echo "❌ Client server not running on :5173"
    echo "💡 Please start the client server with:"
    echo "   cd ../../client && npm run dev"
    echo "   Or use: ../../manage.sh start"
    exit 1
fi

echo "✅ Client server is running"

# Check for API server (optional)
if curl -s http://localhost:3001 > /dev/null 2>&1; then
    echo "✅ API server is running"
else
    echo "⚠️  API server not detected (may still work for demo)"
fi

# Run the main authentication test
echo ""
echo "🚀 Running complete authentication flow test..."
if [ -n "$DEVICE_ARG" ]; then
    echo "📱 Device: $DEVICE_ID"
else
    echo "📱 Device: Auto-detect"
fi

echo ""
echo "🎬 Test will perform the following steps:"
echo "   1. 🚀 Launch Safari"
echo "   2. 🌐 Navigate to localhost:5173"
echo "   3. 📝 Fill username: admin"
echo "   4. 🔑 Fill password: SecurePass123!"
echo "   5. 🔐 Click Login button"
echo "   6. ✅ Verify dashboard loaded"
echo "   7. 🃏 Validate three info cards"
echo "   8. 🔍 Check JWT token display"
echo "   9. 👋 Click Logout"
echo "  10. 🔄 Verify return to login"
echo ""

if maestro test flows/safari-auth-complete.yaml $DEVICE_ARG; then
    echo ""
    echo "🎉 Mobile Safari authentication test completed successfully!"
    echo ""
    echo "📊 Test Results:"
    echo "   ✅ Safari navigation to localhost:5173"
    echo "   ✅ Login form interaction with touch"
    echo "   ✅ Authentication with admin/SecurePass123!"
    echo "   ✅ Dashboard loading verification"
    echo "   ✅ Three card validation (Secure, Stateless, Fast)"
    echo "   ✅ JWT token display confirmation"
    echo "   ✅ Logout functionality"
    echo "   ✅ Session cleanup verification"
    echo ""
    echo "📸 Screenshots captured at each step"
    echo "📱 Mobile-specific validations completed"
    echo "🎯 All authentication flow requirements verified"
else
    echo ""
    echo "❌ Mobile Safari authentication test failed"
    echo "🔍 Common troubleshooting steps:"
    echo "   1. Ensure iOS Simulator is running"
    echo "   2. Verify Safari is accessible"
    echo "   3. Check that localhost:5173 is reachable"
    echo "   4. Confirm Maestro has proper permissions"
    echo ""
    echo "💡 For detailed debugging, run:"
    echo "   maestro test flows/safari-auth-complete.yaml --verbose"
    exit 1
fi