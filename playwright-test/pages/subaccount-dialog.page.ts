import { Page } from '@playwright/test';
import { BasePage } from './base.page';
import { SubaccountDialogSelectors } from '@selectors/subaccount-dialog.selectors';
import { AccountExplorerSelectors } from '@selectors/account-explorer.selectors';

/**
 * Page Object for the subaccount create/edit dialog.
 */
export class SubaccountDialogPage extends BasePage {
  constructor(page: Page) {
    super(page);
  }

  async fillName(name: string): Promise<void> {
    await this.fill(SubaccountDialogSelectors.nameInput, name);
  }

  async fillDescription(description: string): Promise<void> {
    await this.fill(SubaccountDialogSelectors.descriptionInput, description);
  }

  async selectRegion(region: string): Promise<void> {
    await this.fill(SubaccountDialogSelectors.regionInput, region);
    await this.page.waitForTimeout(500);
    await this.page.keyboard.press('Enter');
    await this.page.waitForTimeout(1_000);
  }

  async clickCreateButton(): Promise<void> {
    await this.click(SubaccountDialogSelectors.createButton, 10_000);
  }

  async clickSaveButton(): Promise<void> {
    await this.click(SubaccountDialogSelectors.saveButton, 10_000);
  }

  async waitUntilClosed(timeout = 30_000): Promise<void> {
    await this.waitForDetached(SubaccountDialogSelectors.saveButton, timeout);
  }

  async getNameValue(): Promise<string> {
    return this.getValue(SubaccountDialogSelectors.nameInput);
  }

  async getDescriptionValue(): Promise<string> {
    return this.getValue(SubaccountDialogSelectors.descriptionInput);
  }

  async waitForOnboardingCompletion(): Promise<void> {
    await this.page.waitForTimeout(1_000);
    const visible = await this.isVisible(
      AccountExplorerSelectors.onboardingText,
      10_000
    );
    if (visible) {
      await this.waitForDetached(
        AccountExplorerSelectors.onboardingText,
        180_000
      );
    }
  }
}