/**
 * Selectors for the Fiori trial landing page and Account Explorer entry point.
 */
export const TrialSelectors = {
  goToTrialAccountButton: 'text="Go To Your Trial Account"',
  accountExplorerLink: 'text="Account Explorer"',
  // UI5 keeps clones of closed popovers in a hidden "destroyed" area; they
  // still carry title="Decline" and Playwright treats them as visible, so a
  // .first() click would hit a dead clone and never dismiss the popup.
  // Exclude them to reach the real Audit Log Viewer popup button, like the
  // Robot suite intends with this selector.
  auditLogDeclineButton:
    "xpath=//button[not(contains(@id, 'sap-ui-destroyed')) and (@title='Decline' or .//span[contains(@class, 'sapUiInvisibleText') and text()='Decline'])]",
} as const;