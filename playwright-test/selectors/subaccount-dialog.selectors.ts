/**
 * Selectors for the subaccount create/edit dialog.
 */
export const SubaccountDialogSelectors = {
  nameInput: 'input[placeholder="Enter a name"]',
  descriptionInput: 'textarea',
  regionInput: 'input[placeholder="Select a region"]',
  createButton: '#__xmlview11--createNewSubaccountButton',
  saveButton: 'text="Save"',
} as const;