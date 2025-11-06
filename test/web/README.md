# Web Testing (Playwright)

This folder contains Playwright end-to-end tests for the web application.

## Running Tests

From the main test directory:

```bash
# Run web tests only
npm run test:web

# Run with browser UI visible
npm run test:web:headed

# Run with interactive UI
npm run test:web:ui

# Run in debug mode
npm run test:web:debug

# Show test reports
npm run test:web:report
```

## Configuration

- **playwright.config.js**: Main Playwright configuration
- **tests/**: Test files directory
- **Base URL**: http://localhost:5173 (Vite dev server)

## Test Files

- `auth.spec.js`: Authentication flow tests including login form validation and user flows