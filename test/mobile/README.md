# Mobile Testing (Maestro)

This folder contains Maestro mobile UI automation tests for the auth-test-project.

## Prerequisites

1. **Java Runtime**: OpenJDK 17 or later (installed via `brew install openjdk@17`)
2. **Mobile Device/Emulator**: 
   - iOS: Xcode Simulator or physical iOS device
   - Android: Android Emulator or physical Android device with USB debugging enabled
3. **Maestro CLI**: Installed via the mobile.dev installer

## Test Flows

### Available Test Files:
- `flows/login.yaml` - Basic login functionality test
- `flows/login-validation.yaml` - Form validation testing (empty fields, invalid email)
- `flows/dashboard-navigation.yaml` - Dashboard navigation and logout flow
- `flows/user-journey.yaml` - Complete user journey from login to logout

## Running Tests

From the main test directory:

### Individual Tests:
```bash
npm run maestro:login          # Test basic login flow
npm run maestro:validation     # Test form validation
npm run maestro:dashboard      # Test dashboard navigation
npm run maestro:journey        # Test complete user journey
```

### All Tests:
```bash
npm run test:mobile           # Run all mobile test flows
# or
npm run maestro:all           # Run all test flows
```

### Interactive Development:
```bash
npm run maestro:studio        # Launch Maestro Studio for interactive testing
```

## Configuration

The test flows are configured for an app with the bundle ID `com.yourcompany.authapp`. 
Update the `appId` in each YAML file to match your actual mobile app's bundle identifier.

## Mobile App Setup

To test your React app on mobile:

1. **For React Native**: Use your existing React Native setup
2. **For Web App on Mobile**: 
   - Use Capacitor or Cordova to wrap your web app
   - Test in mobile Safari/Chrome browsers
   - Use responsive design testing

## Tips

- Use `maestro studio` to record interactions and generate test flows
- Add `optional: true` to assertions that might not always be present
- Use descriptive text selectors that match your UI elements
- Test on both iOS and Android devices for comprehensive coverage