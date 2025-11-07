const { test, expect } = require('@playwright/test');

test.describe('Authentication Flow Tests', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the application before each test
    await page.goto('/');
  });

  test('complete authentication flow with dashboard validation', async ({ page }) => {
    // Take screenshot of initial state
    await page.screenshot({ path: 'test-results/01-initial-page.png', fullPage: true });

    // Verify we're on the login page (title is 'client')
    await expect(page).toHaveTitle('client');
    
    // Check that login form is visible
    await expect(page.locator('form')).toBeVisible();
    await expect(page.locator('#username')).toBeVisible();
    await expect(page.locator('#password')).toBeVisible();
    await expect(page.locator('button[type="submit"]')).toBeVisible();

    // Verify the login form header
    await expect(page.locator('h1:has-text("🔐 Secure Login")')).toBeVisible();

    // Fill in the login credentials
    await page.fill('#username', 'admin');
    await page.fill('#password', 'SecurePass123!');
    
    // Take screenshot before login
    await page.screenshot({ path: 'test-results/02-filled-form.png', fullPage: true });

    // Click login button (should be enabled now)
    await page.click('button[type="submit"]');

    // Wait for dashboard to appear
    await expect(page.locator('.dashboard-container')).toBeVisible({ timeout: 10000 });
    
    // Take screenshot after login
    await page.screenshot({ path: 'test-results/03-after-login.png', fullPage: true });

    // Verify we're on the dashboard by checking for dashboard-specific elements
    await expect(page.locator('h1:has-text("✅ Authentication Successful!")')).toBeVisible();
    await expect(page.locator('h2:has-text("Welcome to the Secure System")')).toBeVisible();
    
    // Verify the three info cards are present and visible
    const infoCards = page.locator('.info-card');
    await expect(infoCards).toHaveCount(3, { timeout: 5000 });
    
    // Validate each card individually with specific content
    await expect(page.locator('.info-card:has-text("🔒 Secure")')).toBeVisible();
    await expect(page.locator('.info-card:has-text("Stateless")')).toBeVisible();
    await expect(page.locator('.info-card:has-text("⚡ Fast")')).toBeVisible();

    // Verify token is displayed
    await expect(page.locator('.token-display')).toBeVisible();
    await expect(page.locator('code')).toBeVisible();

    // Verify logout button is present
    const logoutButton = page.locator('.logout-btn');
    await expect(logoutButton).toBeVisible();
    await expect(logoutButton).toHaveText('Logout');

    // Take screenshot of dashboard with cards
    await page.screenshot({ path: 'test-results/04-dashboard-cards.png', fullPage: true });

    // Click logout
    await logoutButton.click();

    // Wait for redirect back to login
    await expect(page.locator('.login-container')).toBeVisible({ timeout: 5000 });
    
    // Take screenshot after logout
    await page.screenshot({ path: 'test-results/05-after-logout.png', fullPage: true });

    // Verify we're back on login page
    await expect(page.locator('form')).toBeVisible();
    await expect(page.locator('#username')).toBeVisible();
    await expect(page.locator('#password')).toBeVisible();
    await expect(page.locator('h1:has-text("🔐 Secure Login")')).toBeVisible();
    
    // Verify we can't access dashboard after logout
    await expect(page.locator('.dashboard-container')).not.toBeVisible();
  });

  test('login form validation', async ({ page }) => {
    // Verify submit button is disabled when form is empty
    await expect(page.locator('button[type="submit"]')).toBeDisabled();
    
    // Fill only username
    await page.fill('#username', 'admin');
    await expect(page.locator('button[type="submit"]')).toBeDisabled();
    
    // Clear username and fill only password
    await page.fill('#username', '');
    await page.fill('#password', 'password123');
    await expect(page.locator('button[type="submit"]')).toBeDisabled();
    
    // Fill both fields - button should be enabled
    await page.fill('#username', 'admin');
    await page.fill('#password', 'password123');
    await expect(page.locator('button[type="submit"]')).toBeEnabled();
  });

  test('failed login attempt', async ({ page }) => {
    // Try wrong credentials
    await page.fill('#username', 'wronguser');
    await page.fill('#password', 'wrongpassword');
    await page.click('button[type="submit"]');
    
    // Should show error message
    await expect(page.locator('.error-message')).toBeVisible({ timeout: 5000 });
    await expect(page.locator('.error-message')).toContainText('Invalid username or password');
    
    // Should stay on login page
    await expect(page.locator('form')).toBeVisible();
    await expect(page.locator('.login-container')).toBeVisible();
  });

  test('dashboard accessibility and elements', async ({ page }) => {
    // Login first
    await page.fill('#username', 'admin');
    await page.fill('#password', 'SecurePass123!');
    await page.click('button[type="submit"]');
    
    // Wait for dashboard
    await expect(page.locator('.dashboard-container')).toBeVisible({ timeout: 10000 });
    
    // Check page title
    await expect(page).toHaveTitle('client');
    
    // Verify essential dashboard elements
    await expect(page.locator('.info-card')).toHaveCount(3);
    await expect(page.locator('.logout-btn')).toBeVisible();
    await expect(page.locator('.token-display')).toBeVisible();
    
    // Test keyboard navigation
    await page.keyboard.press('Tab');
    await page.keyboard.press('Tab');
    
    // Test that cards are accessible
    const firstCard = page.locator('.info-card').first();
    await firstCard.hover();
    
    // Verify logout button has proper text
    await expect(page.locator('.logout-btn')).toHaveText('Logout');
  });

  test('responsive design check', async ({ page }) => {
    // Test mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    
    // Login form should still be usable
    await expect(page.locator('form')).toBeVisible();
    await expect(page.locator('#username')).toBeVisible();
    await expect(page.locator('#password')).toBeVisible();
    
    // Login
    await page.fill('#username', 'admin');
    await page.fill('#password', 'SecurePass123!');
    await page.click('button[type="submit"]');
    
    // Dashboard should be responsive
    await expect(page.locator('.dashboard-container')).toBeVisible({ timeout: 10000 });
    
    // Cards should still be visible (might stack vertically)
    await expect(page.locator('.info-card')).toHaveCount(3);
    
    // Take mobile screenshot
    await page.screenshot({ path: 'test-results/06-mobile-dashboard.png', fullPage: true });
    
    // Test tablet viewport
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.screenshot({ path: 'test-results/07-tablet-dashboard.png', fullPage: true });
    
    // Verify logout still works on mobile
    await page.click('.logout-btn');
    await expect(page.locator('.login-container')).toBeVisible({ timeout: 5000 });
  });

  test('token display and security features', async ({ page }) => {
    // Login
    await page.fill('#username', 'admin');
    await page.fill('#password', 'SecurePass123!');
    await page.click('button[type="submit"]');
    
    // Wait for dashboard
    await expect(page.locator('.dashboard-container')).toBeVisible({ timeout: 10000 });
    
    // Verify token section
    await expect(page.locator('h3:has-text("🔑 Your Session Token:")')).toBeVisible();
    await expect(page.locator('.token-display code')).toBeVisible();
    await expect(page.locator('.token-note')).toContainText('JWT token');
    
    // Verify security feature descriptions
    await expect(page.locator('.info-card:has-text("Password encrypted with bcrypt")')).toBeVisible();
    await expect(page.locator('.info-card:has-text("JWT-based authentication")')).toBeVisible();
    await expect(page.locator('.info-card:has-text("React + Vite frontend")')).toBeVisible();
  });
});