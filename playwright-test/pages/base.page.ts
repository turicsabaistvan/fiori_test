import { Page } from '@playwright/test';

/**
 * Base class for all page objects.
 * Provides small, shared helpers around Playwright's Page API.
 */
export abstract class BasePage {
  constructor(protected readonly page: Page) {}

  /**
   * UI5 often renders duplicate elements (for example several "Decline"
   * buttons in the audit log popup, plus their destroyed clones). Restrict
   * to visible matches and use the first one like the Robot suite does
   * instead of failing Playwright's strict mode.
   */
  protected async waitForVisible(
    selector: string,
    timeout = 15_000
  ): Promise<void> {
    await this.page
      .locator(selector)
      .filter({ visible: true })
      .first()
      .waitFor({ state: 'visible', timeout });
  }

  protected async waitForDetached(
    selector: string,
    timeout = 30_000
  ): Promise<void> {
    await this.page
      .locator(selector)
      .first()
      .waitFor({ state: 'detached', timeout });
  }

  protected async click(selector: string, timeout = 15_000): Promise<void> {
    const locator = this.page
      .locator(selector)
      .filter({ visible: true })
      .first();
    await locator.waitFor({ state: 'visible', timeout });
    await locator.click();
  }

  protected async fill(selector: string, value: string): Promise<void> {
    const locator = this.page
      .locator(selector)
      .filter({ visible: true })
      .first();
    await locator.waitFor({ state: 'visible', timeout: 15_000 });
    await locator.fill(value);
  }

  /**
   * Reads the value of the first visible match, using the same visible-first
   * strategy as fill()/click() so duplicate UI5 clones cannot trigger
   * strict-mode violations (mirrors the Robot suite's "Get Property value").
   */
  protected async getValue(selector: string, timeout = 15_000): Promise<string> {
    const locator = this.page
      .locator(selector)
      .filter({ visible: true })
      .first();
    await locator.waitFor({ state: 'visible', timeout });
    return locator.inputValue();
  }

  protected async isVisible(selector: string, timeout = 3_000): Promise<boolean> {
    try {
      await this.page
        .locator(selector)
        .filter({ visible: true })
        .first()
        .waitFor({ state: 'visible', timeout });
      return true;
    } catch (error) {
      // Only a timeout means "not visible"; every other error must surface.
      if (error instanceof Error && error.name === 'TimeoutError') {
        return false;
      }
      throw error;
    }
  }
}