import { Page } from '@playwright/test';
import { BasePage } from './base.page';
import { TrialSelectors } from '@selectors/trial.selectors';

/**
 * Page Object for the Fiori trial landing page.
 */
export class TrialPage extends BasePage {
  constructor(page: Page) {
    super(page);
  }

  async openTrialAccount(): Promise<void> {
    await this.click(TrialSelectors.goToTrialAccountButton, 30_000);
  }

  async navigateToAccountExplorer(): Promise<void> {
    await this.click(TrialSelectors.accountExplorerLink, 30_000);
  }

  async dismissAuditLogPopupIfPresent(): Promise<void> {
    const visible = await this.isVisible(TrialSelectors.auditLogDeclineButton, 3_000);
    if (!visible) return;
    await this.click(TrialSelectors.auditLogDeclineButton);
  }
}