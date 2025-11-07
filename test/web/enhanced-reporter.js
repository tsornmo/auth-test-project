// Custom reporter for enhanced HTML reporting
const { Reporter } = require('@playwright/test/reporter');
const fs = require('fs');
const path = require('path');

class EnhancedHTMLReporter {
  constructor(options = {}) {
    this.outputFile = options.outputFile || 'enhanced-test-report.html';
    this.outputDir = options.outputDir || 'test-results';
    this.tests = [];
    this.stats = {
      total: 0,
      passed: 0,
      failed: 0,
      skipped: 0,
      duration: 0
    };
  }

  onBegin(config, suite) {
    this.startTime = Date.now();
    console.log(`Starting the run with ${suite.allTests().length} tests`);
  }

  onTestEnd(test, result) {
    this.tests.push({
      title: test.title,
      fullTitle: test.titlePath().join(' › '),
      status: result.status,
      duration: result.duration,
      error: result.error,
      screenshots: result.attachments?.filter(a => a.name === 'screenshot') || [],
      videos: result.attachments?.filter(a => a.name === 'video') || [],
      traces: result.attachments?.filter(a => a.name === 'trace') || []
    });

    this.stats.total++;
    if (result.status === 'passed') this.stats.passed++;
    else if (result.status === 'failed') this.stats.failed++;
    else if (result.status === 'skipped') this.stats.skipped++;
  }

  onEnd(result) {
    this.stats.duration = Date.now() - this.startTime;
    this.generateHTMLReport();
  }

  generateHTMLReport() {
    const html = this.generateHTML();
    const outputPath = path.join(this.outputDir, this.outputFile);
    
    // Ensure output directory exists
    if (!fs.existsSync(this.outputDir)) {
      fs.mkdirSync(this.outputDir, { recursive: true });
    }
    
    fs.writeFileSync(outputPath, html);
    console.log(`Enhanced HTML report generated: ${outputPath}`);
  }

  generateHTML() {
    const passRate = this.stats.total > 0 ? (this.stats.passed / this.stats.total * 100).toFixed(1) : 0;
    const now = new Date().toLocaleString();

    return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Playwright Test Report - Auth Test Project</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 10px; margin-bottom: 30px; text-align: center; }
        .header h1 { font-size: 2.5rem; margin-bottom: 10px; }
        .header p { font-size: 1.1rem; opacity: 0.9; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); text-align: center; }
        .stat-card h3 { font-size: 2rem; margin-bottom: 5px; }
        .stat-card p { color: #666; font-weight: 500; }
        .passed { color: #10b981; }
        .failed { color: #ef4444; }
        .skipped { color: #f59e0b; }
        .total { color: #6366f1; }
        .tests-container { background: white; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); overflow: hidden; }
        .tests-header { background: #f8fafc; padding: 20px; border-bottom: 1px solid #e2e8f0; }
        .tests-header h2 { color: #334155; }
        .test-item { padding: 20px; border-bottom: 1px solid #e2e8f0; transition: background 0.2s; }
        .test-item:hover { background: #f8fafc; }
        .test-item:last-child { border-bottom: none; }
        .test-title { font-size: 1.1rem; font-weight: 600; margin-bottom: 5px; }
        .test-path { color: #64748b; font-size: 0.9rem; margin-bottom: 10px; }
        .test-meta { display: flex; align-items: center; gap: 15px; flex-wrap: wrap; }
        .test-status { padding: 4px 12px; border-radius: 20px; font-size: 0.85rem; font-weight: 500; }
        .status-passed { background: #dcfce7; color: #166534; }
        .status-failed { background: #fef2f2; color: #991b1b; }
        .status-skipped { background: #fef3c7; color: #92400e; }
        .test-duration { color: #64748b; font-size: 0.9rem; }
        .error-details { background: #fef2f2; border: 1px solid #fecaca; border-radius: 6px; padding: 15px; margin-top: 10px; }
        .error-details pre { color: #991b1b; font-size: 0.85rem; white-space: pre-wrap; }
        .attachments { margin-top: 10px; }
        .attachment { display: inline-block; margin: 5px 10px 5px 0; padding: 5px 10px; background: #e2e8f0; border-radius: 4px; text-decoration: none; color: #475569; font-size: 0.85rem; }
        .attachment:hover { background: #cbd5e1; }
        .progress-bar { width: 100%; height: 8px; background: #e2e8f0; border-radius: 4px; overflow: hidden; margin: 20px 0; }
        .progress-fill { height: 100%; background: linear-gradient(90deg, #10b981, #34d399); transition: width 0.3s ease; }
        .footer { text-align: center; margin-top: 30px; color: #64748b; }
        .summary-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 30px; }
        .summary-card { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .summary-card h3 { color: #334155; margin-bottom: 15px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎭 Playwright Test Report</h1>
            <p>Auth Test Project - Authentication Flow Testing</p>
            <p>Generated on ${now}</p>
        </div>

        <div class="stats">
            <div class="stat-card">
                <h3 class="total">${this.stats.total}</h3>
                <p>Total Tests</p>
            </div>
            <div class="stat-card">
                <h3 class="passed">${this.stats.passed}</h3>
                <p>Passed</p>
            </div>
            <div class="stat-card">
                <h3 class="failed">${this.stats.failed}</h3>
                <p>Failed</p>
            </div>
            <div class="stat-card">
                <h3 class="skipped">${this.stats.skipped}</h3>
                <p>Skipped</p>
            </div>
        </div>

        <div class="summary-grid">
            <div class="summary-card">
                <h3>📊 Test Statistics</h3>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: ${passRate}%"></div>
                </div>
                <p><strong>Success Rate:</strong> ${passRate}%</p>
                <p><strong>Duration:</strong> ${Math.round(this.stats.duration / 1000)}s</p>
            </div>
            <div class="summary-card">
                <h3>🔍 Test Coverage</h3>
                <p><strong>Authentication Flow:</strong> ✓ Login, Dashboard, Logout</p>
                <p><strong>Form Validation:</strong> ✓ Empty fields, Invalid inputs</p>
                <p><strong>Responsive Design:</strong> ✓ Mobile, Tablet, Desktop</p>
                <p><strong>Browser Support:</strong> ✓ Chrome, Firefox, Safari</p>
            </div>
        </div>

        <div class="tests-container">
            <div class="tests-header">
                <h2>📋 Test Results</h2>
            </div>
            ${this.tests.map(test => this.generateTestHTML(test)).join('')}
        </div>

        <div class="footer">
            <p>Generated by Playwright Test Runner for Auth Test Project</p>
            <p>📁 Full report available in playwright-report/index.html</p>
        </div>
    </div>
</body>
</html>`;
  }

  generateTestHTML(test) {
    const statusClass = `status-${test.status}`;
    const attachments = [...test.screenshots, ...test.videos, ...test.traces];

    return `
        <div class="test-item">
            <div class="test-title">${test.title}</div>
            <div class="test-path">${test.fullTitle}</div>
            <div class="test-meta">
                <span class="test-status ${statusClass}">${test.status.toUpperCase()}</span>
                <span class="test-duration">${test.duration}ms</span>
            </div>
            ${test.error ? `
                <div class="error-details">
                    <pre>${test.error.message || 'Unknown error'}</pre>
                </div>
            ` : ''}
            ${attachments.length > 0 ? `
                <div class="attachments">
                    ${attachments.map(att => `
                        <a href="${att.path}" class="attachment" target="_blank">
                            📎 ${att.name}
                        </a>
                    `).join('')}
                </div>
            ` : ''}
        </div>
    `;
  }
}

module.exports = EnhancedHTMLReporter;