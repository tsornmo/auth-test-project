#!/bin/bash

# Quick Test Runner for Authentication Flow
echo "🚀 Running Authentication Flow Tests..."

cd "$(dirname "$0")"

# Run the specific authentication test
echo "📝 Running comprehensive authentication tests..."
npx playwright test tests/auth.spec.js --project=chromium --headed

echo ""
echo "✨ Test completed! Check the reports:"
echo "📊 HTML Report: playwright-report/index.html"
echo "📋 Test Results: test-results/"
echo "📱 Screenshots: test-results/*.png"

# Open report if available
if command -v open &> /dev/null; then
    echo "🌐 Opening HTML report..."
    open playwright-report/index.html
fi