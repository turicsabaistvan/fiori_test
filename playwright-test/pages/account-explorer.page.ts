import { Page } from '@playwright/test';
import { BasePage } from './base.page';
import { AccountExplorerSelectors } from '@selectors/account-explorer.selectors';

/**
 * Subaccount deletion in BTP Cockpit is asynchronous and can take minutes.
 */
const DELETION_TIMEOUT_MS = 600_000;

/**
 * Page Object for the Account Explorer page.
 */
export class AccountExplorerPage extends BasePage {
  constructor(page: Page) {
    super(page);
  }

  /**
   * Deletes the "Tester" subaccount if it exists.
   * Resolves without error when the subaccount is not present.
   */
  async deleteTesterSubaccountIfExists(): Promise<void> {
    // A previous run may have left a deletion in progress. In that state the
    // tile is visible but the Delete menu item is not offered, so wait for it
    // to finish before trying to delete again.
    if (
      await this.isVisible(
        AccountExplorerSelectors.deletionInProgressText,
        1_000
      )
    ) {
      await this.waitForDeletionToFinish();
    }

    const present = await this.isVisible(
      AccountExplorerSelectors.testerActionsButton,
      5_000
    );
    if (!present) return;

    await this.click(AccountExplorerSelectors.testerActionsButton);
    await this.page.waitForTimeout(500);

    await this.click(AccountExplorerSelectors.deleteMenuItem, 5_000);
    await this.page.waitForTimeout(500);

    await this.click(AccountExplorerSelectors.deleteConfirmButton, 5_000);

    // Deletion is asynchronous: the tile stays visible with a
    // "Deletion in Progress" badge for minutes. Wait for the badge to appear
    // first, otherwise the "detached" wait would resolve immediately while
    // the badge has not been rendered yet.
    if (
      await this.isVisible(
        AccountExplorerSelectors.deletionInProgressText,
        30_000
      )
    ) {
      await this.waitForDetached(
        AccountExplorerSelectors.deletionInProgressText,
        DELETION_TIMEOUT_MS
      );
    }
    await this.waitForDetached(
      AccountExplorerSelectors.testerActionsButton,
      DELETION_TIMEOUT_MS
    );
  }

  private async waitForDeletionToFinish(): Promise<void> {
    await this.waitForDetached(
      AccountExplorerSelectors.deletionInProgressText,
      DELETION_TIMEOUT_MS
    );
    await this.waitForDetached(
      AccountExplorerSelectors.testerActionsButton,
      DELETION_TIMEOUT_MS
    );
  }

  async openCreateSubaccountDialog(): Promise<void> {
    await this.click(AccountExplorerSelectors.createButton, 10_000);
    const subaccountOptionVisible = await this.isVisible(
      AccountExplorerSelectors.createSubaccountOption,
      3_000
    );
    if (subaccountOptionVisible) {
      await this.click(AccountExplorerSelectors.createSubaccountOption);
    }
  }

  async openTesterActionsMenu(): Promise<void> {
    await this.click(AccountExplorerSelectors.testerActionsButton, 30_000);
    await this.page.waitForTimeout(500);
  }

  async openFirstActionsMenu(): Promise<void> {
    await this.click(AccountExplorerSelectors.anyActionsButton, 30_000);
    await this.page.waitForTimeout(500);
  }

  async clickEditMenuItem(): Promise<void> {
    await this.click(AccountExplorerSelectors.editMenuItem, 10_000);
  }

  async waitForSubaccountCardReady(): Promise<void> {
    await this.waitForVisible(
      AccountExplorerSelectors.testerActionsButton,
      60_000
    );
    await this.page.waitForTimeout(2_000);
  }
}