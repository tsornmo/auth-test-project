// global-setup.js
const { chromium } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

async function globalSetup(config) {
  console.log('🚀 Starting global setup...');
  
  // Create test-results directory if it doesn't exist
  const testResultsDir = path.join(__dirname, 'test-results');
  if (!fs.existsSync(testResultsDir)) {
    fs.mkdirSync(testResultsDir, { recursive: true });
  }
  
  // Create playwright-report directory if it doesn't exist
  const reportDir = path.join(__dirname, 'playwright-report');
  if (!fs.existsSync(reportDir)) {
    fs.mkdirSync(reportDir, { recursive: true });
  }
  
  // Wait for server to be ready (if needed)
  const browser = await chromium.launch();
  const page = await browser.newPage();
  
  try {
    // Wait for the application to be ready
    await page.goto('http://localhost:5173', { waitUntil: 'networkidle' });
    console.log('✅ Application is ready for testing');
  } catch (error) {
    console.log('⚠️  Application might not be ready yet, tests will wait for webServer');
  }
  
  await browser.close();
  
  // Set test start time
  process.env.TEST_START_TIME = new Date().toISOString();
  
  console.log('✅ Global setup completed');
}

module.exports = globalSetup;