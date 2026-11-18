import { test as base } from '@playwright/test';
import { LoginPage } from '@pages/login.page';
import { TrialPage } from '@pages/trial.page';
import { AccountExplorerPage } from '@pages/account-explorer.page';
import { SubaccountDialogPage } from '@pages/subaccount-dialog.page';

/**
 * Custom fixtures that expose page objects to the tests.
 * Tests receive typed page objects instead of raw selectors.
 */
type FioriFixtures = {
  loginPage: LoginPage;
  trialPage: TrialPage;
  accountExplorerPage: AccountExplorerPage;
  subaccountDialogPage: SubaccountDialogPage;
};

export const test = base.extend<FioriFixtures>({
  loginPage: async ({ page }, use) => {
    await use(new LoginPage(page));
  },
  trialPage: async ({ page }, use) => {
    await use(new TrialPage(page));
  },
  accountExplorerPage: async ({ page }, use) => {
    await use(new AccountExplorerPage(page));
  },
  subaccountDialogPage: async ({ page }, use) => {
    await use(new SubaccountDialogPage(page));
  },
});

export { expect } from '@playwright/test';