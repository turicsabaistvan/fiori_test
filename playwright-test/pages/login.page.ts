import { Page } from '@playwright/test';
import { BasePage } from './base.page';
import { LoginSelectors } from '@selectors/login.selectors';

/**
 * Page Object for the SAP IDP login flow.
 */
export class LoginPage extends BasePage {
  constructor(page: Page) {
    super(page);
  }

  async open(url: string): Promise<void> {
    await this.page.goto(url, { waitUntil: 'domcontentloaded' });
  }

  async fillUsername(username: string): Promise<void> {
    await this.fill(LoginSelectors.usernameInput, username);
  }

  async submitUsernameStep(): Promise<void> {
    await this.click(LoginSelectors.submitButton);
    await this.waitForVisible(LoginSelectors.passwordInput, 30_000);
  }

  async verifyEmptyPasswordErrorIsShown(): Promise<void> {
    // Submit the password step with an empty password and expect the error.
    await this.click(LoginSelectors.submitButton);
    await this.waitForVisible(LoginSelectors.errorMessage, 10_000);
  }

  async fillPassword(password: string): Promise<void> {
    await this.fill(LoginSelectors.passwordInput, password);
  }

  async submitLogin(): Promise<void> {
    await this.click(LoginSelectors.submitButton);
  }

  async acceptCookieBannerIfPresent(): Promise<void> {
    const visible = await this.isVisible(LoginSelectors.cookieBannerButton, 3_000);
    if (!visible) return;
    await this.click(LoginSelectors.cookieBannerButton);
  }
}