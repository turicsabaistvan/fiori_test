/**
 * Selectors for the Account Explorer page (subaccount cards and actions).
 */
export const AccountExplorerSelectors = {
  testerActionsButton: '[aria-label="Tester Actions"]',
  anyActionsButton: 'xpath=(//button[contains(@aria-label, "Actions")])[1]',
  createButton: 'text="Create"',
  createSubaccountOption: 'text="Subaccount"',
  editMenuItem: 'text="Edit"',
  deleteMenuItem:
    "xpath=//button[@title='Delete' and not(contains(@id, 'sap-ui-destroyed'))]",
  deleteConfirmButton: '#__mbox-btn-0',
  deletionInProgressText: 'text="Deletion in Progress"',
  onboardingText: 'text="Onboarding"',
} as const;