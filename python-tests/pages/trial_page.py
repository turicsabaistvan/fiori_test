"""
Page Object for the Fiori trial landing page.
"""

from playwright.sync_api import Page

from locators.trial_selectors import TrialSelectors
from pages.base_page import BasePage


class TrialPage(BasePage):
    def __init__(self, page: Page) -> None:
        super().__init__(page)

    def open_trial_account(self) -> None:
        self.click(TrialSelectors.GO_TO_TRIAL_ACCOUNT_BUTTON, 30_000)

    def navigate_to_account_explorer(self) -> None:
        self.click(TrialSelectors.ACCOUNT_EXPLORER_LINK, 30_000)

    def dismiss_audit_log_popup_if_present(self) -> None:
        if not self.is_visible(TrialSelectors.AUDIT_LOG_DECLINE_BUTTON, 3_000):
            return
        self.click(TrialSelectors.AUDIT_LOG_DECLINE_BUTTON)