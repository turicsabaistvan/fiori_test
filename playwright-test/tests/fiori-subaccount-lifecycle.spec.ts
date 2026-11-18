import { test, expect } from '@fixtures/fiori.fixture';
import { requireEnv, testData } from '../utils/env';

/**
 * End-to-end test for the Fiori trial subaccount lifecycle.
 *
 * Covers:
 *  - Login with negative empty-password check
 *  - Cookie banner handling
 *  - Conditional deletion of the "Tester" subaccount
 *  - Subaccount creation with region selection
 *  - Long-text edit/save and restore to defaults
 */
test.describe('Fiori Subaccount Lifecycle', () => {
  test.beforeEach(async ({ loginPage }) => {
    const url = process.env.BASE_URL ?? 'https://account.hanatrial.ondemand.com/';
    await loginPage.open(url);
  });

  test('full subaccount lifecycle', async ({
    loginPage,
    trialPage,
    accountExplorerPage,
    subaccountDialogPage,
  }) => {
    const username = requireEnv('FIORI_USERNAME');
    const password = requireEnv('FIORI_PASSWORD');

    // 1. Login flow with negative empty-password check
    await loginPage.fillUsername(username);
    await loginPage.submitUsernameStep();
    await loginPage.verifyEmptyPasswordErrorIsShown();
    await loginPage.fillPassword(password);
    await loginPage.submitLogin();
    await loginPage.acceptCookieBannerIfPresent();

    // 2. Navigate to the Account Explorer
    await trialPage.openTrialAccount();
    await trialPage.navigateToAccountExplorer();
    await trialPage.dismissAuditLogPopupIfPresent();

    // 3. Delete existing Tester subaccount (if any)
    await accountExplorerPage.deleteTesterSubaccountIfExists();

    // 4. Create a new Tester subaccount
    await accountExplorerPage.openCreateSubaccountDialog();
    await subaccountDialogPage.fillName(testData.subaccountName);
    await subaccountDialogPage.fillDescription(
      testData.subaccountDescription
    );
    await subaccountDialogPage.selectRegion(testData.subaccountRegion);
    await subaccountDialogPage.clickCreateButton();
    await subaccountDialogPage.waitForOnboardingCompletion();
    await accountExplorerPage.waitForSubaccountCardReady();

    // 5. Long-text edit and save
    await accountExplorerPage.openTesterActionsMenu();
    await accountExplorerPage.clickEditMenuItem();

    const displayText = 'Sample display text repeated. '.repeat(
      testData.displayTextRepeat
    );
    const descriptionText = 'Sample description text repeated. '.repeat(
      testData.descriptionTextRepeat
    );

    await subaccountDialogPage.fillName(displayText);
    await subaccountDialogPage.fillDescription(descriptionText);

    // Capture what the fields actually accepted (UI5 may enforce a maxlength)
    const savedName = await subaccountDialogPage.getNameValue();
    const savedDescription = await subaccountDialogPage.getDescriptionValue();

    await subaccountDialogPage.clickSaveButton();
    await subaccountDialogPage.waitUntilClosed();

    // 6. Restore default values
    await accountExplorerPage.openFirstActionsMenu();
    await accountExplorerPage.clickEditMenuItem();

    // Verify that the long values were actually persisted. UI5 may trim
    // trailing whitespace when saving, so compare the content only.
    expect((await subaccountDialogPage.getNameValue()).trim()).toBe(
      savedName.trim()
    );
    expect((await subaccountDialogPage.getDescriptionValue()).trim()).toBe(
      savedDescription.trim()
    );

    await subaccountDialogPage.fillName(testData.subaccountName);
    await subaccountDialogPage.fillDescription(
      testData.subaccountDescription
    );
    await subaccountDialogPage.clickSaveButton();
    await subaccountDialogPage.waitUntilClosed();
  });
});
