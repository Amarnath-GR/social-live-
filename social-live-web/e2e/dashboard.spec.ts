import { test, expect } from '@playwright/test';

test.describe('Dashboard Functionality', () => {
  test.beforeEach(async ({ page }) => {
    // Login before each test
    await page.goto('/login');
    await page.fill('input[name="email"]', 'admin@sociallive.com');
    await page.fill('input[name="password"]', 'admin123');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL('/dashboard');
  });

  test('should display dashboard stats', async ({ page }) => {
    // Check for stats cards
    await expect(page.locator('text=Total Users')).toBeVisible();
    await expect(page.locator('text=Total Posts')).toBeVisible();
    await expect(page.locator('text=Engagements')).toBeVisible();
    await expect(page.locator('text=System Health')).toBeVisible();
  });

  test('should display charts', async ({ page }) => {
    // Wait for charts to load
    await page.waitForSelector('.recharts-wrapper', { timeout: 10000 });
    
    // Check for chart containers
    const charts = page.locator('.recharts-wrapper');
    await expect(charts).toHaveCount(2);
  });

  test('should display system status', async ({ page }) => {
    // Check for system status section
    await expect(page.locator('text=System Status')).toBeVisible();
    await expect(page.locator('text=Uptime')).toBeVisible();
    await expect(page.locator('text=Memory Usage')).toBeVisible();
    await expect(page.locator('text=Active Requests')).toBeVisible();
  });

  test('should navigate to different sections', async ({ page }) => {
    // Test navigation to Analytics
    await page.click('text=Analytics');
    await expect(page).toHaveURL('/analytics');
    
    // Navigate back to Dashboard
    await page.click('text=Dashboard');
    await expect(page).toHaveURL('/dashboard');
  });

  test('should be responsive on mobile', async ({ page }) => {
    // Set mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    
    // Check if mobile menu button is visible
    await expect(page.locator('[data-testid="mobile-menu-button"]')).toBeVisible();
    
    // Open mobile menu
    await page.click('[data-testid="mobile-menu-button"]');
    
    // Check if navigation is visible
    await expect(page.locator('text=Dashboard')).toBeVisible();
    await expect(page.locator('text=Analytics')).toBeVisible();
  });
});