const { test, expect } = require('@playwright/test');

test('homepage has title and login form', async ({ page }) => {
  await page.goto('/');

  // Expect a title "to contain" a substring.
  await expect(page).toHaveTitle(/Auth Test/);

  // Expect login form to be visible
  await expect(page.locator('form')).toBeVisible();
  await expect(page.locator('input[type="email"]')).toBeVisible();
  await expect(page.locator('input[type="password"]')).toBeVisible();
  await expect(page.locator('button[type="submit"]')).toBeVisible();
});

test('login form validation', async ({ page }) => {
  await page.goto('/');

  // Try to submit empty form
  await page.click('button[type="submit"]');
  
  // Check for validation messages or behavior
  // This will depend on your actual implementation
  await expect(page.locator('input[type="email"]')).toBeFocused();
});

test('successful login flow', async ({ page }) => {
  await page.goto('/');

  // Fill in login form
  await page.fill('input[type="email"]', 'test@example.com');
  await page.fill('input[type="password"]', 'password123');
  
  // Submit form
  await page.click('button[type="submit"]');

  // Wait for navigation or dashboard to appear
  // This will depend on your actual implementation
  await page.waitForSelector('[data-testid="dashboard"], .dashboard', { timeout: 5000 });
  
  // Verify we're on the dashboard
  await expect(page.locator('[data-testid="dashboard"], .dashboard')).toBeVisible();
});