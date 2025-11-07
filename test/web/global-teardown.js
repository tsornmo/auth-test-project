// global-teardown.js
const fs = require('fs');
const path = require('path');

async function globalTeardown(config) {
  console.log('🧹 Starting global teardown...');
  
  // Calculate test duration
  const startTime = process.env.TEST_START_TIME;
  const endTime = new Date().toISOString();
  const duration = startTime ? new Date(endTime) - new Date(startTime) : 0;
  
  console.log(`⏱️  Test suite completed in ${Math.round(duration / 1000)}s`);
  
  // Create test summary
  const summary = {
    startTime,
    endTime,
    duration: `${Math.round(duration / 1000)}s`,
    timestamp: new Date().toLocaleString(),
    environment: {
      node: process.version,
      platform: process.platform,
      arch: process.arch
    }
  };
  
  // Write summary to file
  const summaryPath = path.join(__dirname, 'test-results', 'test-summary.json');
  fs.writeFileSync(summaryPath, JSON.stringify(summary, null, 2));
  
  console.log('📊 Test summary written to test-results/test-summary.json');
  console.log('📁 HTML report available in playwright-report/index.html');
  console.log('✅ Global teardown completed');
}

module.exports = globalTeardown;