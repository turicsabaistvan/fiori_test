"""
Page Object for the subaccount create/edit dialog.
"""

from playwright.sync_api import Page

from locators.account_explorer_selectors import AccountExplorerSelectors
from locators.subaccount_dialog_selectors import SubaccountDialogSelectors
from pages.base_page import BasePage


class SubaccountDialogPage(BasePage):
    def __init__(self, page: Page) -> None:
        super().__init__(page)

    def fill_name(self, name: str) -> None:
        self.fill(SubaccountDialogSelectors.NAME_INPUT, name)

    def fill_description(self, description: str) -> None:
        self.fill(SubaccountDialogSelectors.DESCRIPTION_INPUT, description)

    def select_region(self, region: str) -> None:
        self.fill(SubaccountDialogSelectors.REGION_INPUT, region)
        self.page.wait_for_timeout(500)
        self.page.keyboard.press("Enter")
        self.page.wait_for_timeout(1_000)

    def click_create_button(self) -> None:
        self.click(SubaccountDialogSelectors.CREATE_BUTTON, 10_000)

    def click_save_button(self) -> None:
        self.click(SubaccountDialogSelectors.SAVE_BUTTON, 10_000)

    def wait_for_save_button_hidden(self, timeout_ms: int = 30_000) -> None:
        self.wait_for_detached(SubaccountDialogSelectors.SAVE_BUTTON, timeout_ms)

    def get_name_value(self) -> str:
        return self.page.locator(
            SubaccountDialogSelectors.NAME_INPUT
        ).input_value()

    def get_description_value(self) -> str:
        return self.page.locator(
            SubaccountDialogSelectors.DESCRIPTION_INPUT
        ).input_value()

    def wait_for_onboarding_completion(self) -> None:
        self.page.wait_for_timeout(1_000)
        if self.is_visible(AccountExplorerSelectors.ONBOARDING_TEXT, 10_000):
            self.wait_for_detached(
                AccountExplorerSelectors.ONBOARDING_TEXT, 180_000
            )