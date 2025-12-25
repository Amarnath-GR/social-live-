import { test, expect } from '@playwright/test';

test.describe('Admin Functionality', () => {
  test.beforeEach(async ({ page }) => {
    // Login as admin
    await page.goto('/login');
    await page.fill('input[name="email"]', 'admin@sociallive.com');
    await page.fill('input[name="password"]', 'admin123');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL('/dashboard');
  });

  test('should access admin users page', async ({ page }) => {
    // Navigate to admin users
    await page.click('text=Users');
    await expect(page).toHaveURL('/admin/users');
    
    // Check page content
    await expect(page.locator('h1')).toContainText('User Management');
    await expect(page.locator('text=Manage platform users')).toBeVisible();
  });

  test('should display users list', async ({ page }) => {
    await page.goto('/admin/users');
    
    // Wait for users to load
    await page.waitForSelector('[data-testid="user-list"]', { timeout: 10000 });
    
    // Check if users are displayed
    const userItems = page.locator('[data-testid="user-item"]');
    await expect(userItems.first()).toBeVisible();
  });

  test('should block/unblock users', async ({ page }) => {
    await page.goto('/admin/users');
    
    // Wait for users to load
    await page.waitForSelector('[data-testid="user-list"]', { timeout: 10000 });
    
    // Find first user and block/unblock button
    const firstUser = page.locator('[data-testid="user-item"]').first();
    const blockButton = firstUser.locator('button').filter({ hasText: /Block|Unblock/ });
    
    if (await blockButton.isVisible()) {
      const initialText = await blockButton.textContent();
      
      // Click block/unblock button
      await blockButton.click();
      
      // Wait for status change
      await page.waitForTimeout(1000);
      
      // Check if button text changed
      const newText = await blockButton.textContent();
      expect(newText).not.toBe(initialText);
    }
  });

  test('should access admin system page', async ({ page }) => {
    // Navigate to admin system
    await page.click('text=System');
    await expect(page).toHaveURL('/admin/system');
    
    // Check page content
    await expect(page.locator('h1')).toContainText('System Monitoring');
    await expect(page.locator('text=Monitor system health')).toBeVisible();
  });

  test('should display system monitoring data', async ({ page }) => {
    await page.goto('/admin/system');
    
    // Check for system status cards
    await expect(page.locator('text=System Status')).toBeVisible();
    await expect(page.locator('text=Uptime')).toBeVisible();
    await expect(page.locator('text=Memory Usage')).toBeVisible();
    
    // Check for error statistics
    await expect(page.locator('text=Error Breakdown')).toBeVisible();
    
    // Check for performance charts
    await expect(page.locator('text=Response Times')).toBeVisible();
    await expect(page.locator('text=System Resources')).toBeVisible();
  });

  test('should restrict access for non-admin users', async ({ page }) => {
    // Logout and login as regular user
    await page.click('[data-testid="logout-button"]');
    await page.fill('input[name="email"]', 'user@sociallive.com');
    await page.fill('input[name="password"]', 'user123');
    await page.click('button[type="submit"]');
    
    // Try to access admin pages directly
    await page.goto('/admin/users');
    
    // Should redirect to dashboard
    await expect(page).toHaveURL('/dashboard');
    
    // Admin navigation should not be visible
    await expect(page.locator('text=Users')).not.toBeVisible();
    await expect(page.locator('text=System')).not.toBeVisible();
  });
});