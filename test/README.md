# Test Suite

This directory contains all testing infrastructure for the auth-test-project, organized by testing type.

## Structure

```
test/
├── web/                     # Web testing (Playwright)
│   ├── playwright.config.js
│   ├── tests/
│   │   └── auth.spec.js
│   └── README.md
├── mobile/                  # Mobile testing (Maestro)
│   ├── flows/
│   │   ├── login.yaml
│   │   ├── login-validation.yaml
│   │   ├── dashboard-navigation.yaml
│   │   └── user-journey.yaml
│   ├── maestro.config.yaml
│   └── README.md
├── package.json
└── .gitignore
```

## Quick Start

### Install Dependencies
```bash
npm install
```

### Run All Tests
```bash
npm test                    # Run both web and mobile tests
```

### Run Specific Test Types
```bash
npm run test:web           # Web tests only (Playwright)
npm run test:mobile        # Mobile tests only (Maestro)
```

## Testing Technologies

- **Web Testing**: Playwright for end-to-end browser testing
- **Mobile Testing**: Maestro for mobile UI automation testing

## Individual Test Commands

### Web Tests (Playwright)
- `npm run test:web` - Run web tests headlessly
- `npm run test:web:headed` - Run with browser UI visible
- `npm run test:web:ui` - Interactive test UI
- `npm run test:web:debug` - Debug mode
- `npm run test:web:report` - Show test reports

### Mobile Tests (Maestro)
- `npm run maestro:login` - Basic login flow
- `npm run maestro:validation` - Form validation
- `npm run maestro:dashboard` - Dashboard navigation
- `npm run maestro:journey` - Complete user journey
- `npm run maestro:studio` - Interactive test development

## Setup Requirements

### Web Testing
- Node.js and npm
- Playwright browsers (auto-installed)

### Mobile Testing
- Java Runtime (OpenJDK 17+)
- iOS Simulator or Android Emulator
- Maestro CLI (installed)

For detailed setup instructions, see the README files in each subfolder.