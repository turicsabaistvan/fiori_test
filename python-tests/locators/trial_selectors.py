"""
Selectors for the Fiori trial landing page and Account Explorer entry point.
"""


class TrialSelectors:
    GO_TO_TRIAL_ACCOUNT_BUTTON = 'text="Go To Your Trial Account"'
    ACCOUNT_EXPLORER_LINK = 'text="Account Explorer"'
    AUDIT_LOG_DECLINE_BUTTON = (
        "xpath=//button[@title='Decline' or "
        ".//span[contains(@class, 'sapUiInvisibleText') and text()='Decline']]"
    )