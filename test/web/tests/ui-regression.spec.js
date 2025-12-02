const { test, expect } = require('@playwright/test');

// UI Regression: Visual snapshot tests for Login and Main Content (Dashboard) pages

test.describe('UI Regression Snapshots', () => {
  test('login page visual snapshot', async ({ page }) => {
    await page.goto('/');
    // Wait for login form to be visible
    await expect(page.locator('form')).toBeVisible();
    // Take a full-page screenshot for visual regression
    expect(await page.screenshot({ fullPage: true })).toMatchSnapshot('login-page.png');
  });

  test('dashboard page visual snapshot', async ({ page }) => {
    await page.goto('/');
    // Login with valid credentials
    await page.fill('#username', 'admin');
    await page.fill('#password', 'SecurePass123!');
    await page.click('button[type="submit"]');
    // Wait for dashboard to be visible
    await expect(page.locator('.dashboard-container')).toBeVisible({ timeout: 10000 });
    // Take a full-page screenshot for visual regression
    expect(await page.screenshot({ fullPage: true })).toMatchSnapshot('dashboard-page.png');
  });
});
