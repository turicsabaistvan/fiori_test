"""
Selectors for the Account Explorer page (subaccount cards and actions).
"""


class AccountExplorerSelectors:
    TESTER_ACTIONS_BUTTON = '[aria-label="Tester Actions"]'
    ANY_ACTIONS_BUTTON = 'xpath=(//button[contains(@aria-label, "Actions")])[1]'
    CREATE_BUTTON = 'text="Create"'
    CREATE_SUBACCOUNT_OPTION = 'text="Subaccount"'
    EDIT_MENU_ITEM = 'text="Edit"'
    DELETE_MENU_ITEM = "xpath=//button[@title='Delete']"
    DELETE_CONFIRM_BUTTON = "#__mbox-btn-0"
    DELETION_IN_PROGRESS_TEXT = 'text="Deletion in Progress"'
    ONBOARDING_TEXT = 'text="Onboarding"'