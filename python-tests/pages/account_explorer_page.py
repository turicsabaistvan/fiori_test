"""
Page Object for the Account Explorer page.
"""

from playwright.sync_api import Page

from locators.account_explorer_selectors import AccountExplorerSelectors
from pages.base_page import BasePage


class AccountExplorerPage(BasePage):
    # Subaccount deletion in BTP Cockpit is asynchronous and can take minutes.
    DELETION_TIMEOUT_MS = 600_000

    def __init__(self, page: Page) -> None:
        super().__init__(page)

    def delete_tester_subaccount_if_exists(self) -> None:
        """
        Deletes the "Tester" subaccount if present.
        Returns without error when the subaccount does not exist.
        """
        # A previous run may have left a deletion in progress. In that state
        # the tile is visible but the Delete menu item is not offered, so wait
        # for it to finish before trying to delete again.
        if self.is_visible(
            AccountExplorerSelectors.DELETION_IN_PROGRESS_TEXT, 1_000
        ):
            self._wait_for_deletion_to_finish()

        if not self.is_visible(
            AccountExplorerSelectors.TESTER_ACTIONS_BUTTON, 5_000
        ):
            return

        self.click(AccountExplorerSelectors.TESTER_ACTIONS_BUTTON)
        self.page.wait_for_timeout(500)

        self.click(AccountExplorerSelectors.DELETE_MENU_ITEM, 5_000)
        self.page.wait_for_timeout(500)

        self.click(AccountExplorerSelectors.DELETE_CONFIRM_BUTTON, 5_000)

        # Deletion is asynchronous: the tile stays visible with a
        # "Deletion in Progress" badge for minutes. Wait for the badge to
        # appear first, otherwise the "detached" wait resolves immediately
        # while the badge has not been rendered yet.
        if self.is_visible(
            AccountExplorerSelectors.DELETION_IN_PROGRESS_TEXT, 30_000
        ):
            self.wait_for_detached(
                AccountExplorerSelectors.DELETION_IN_PROGRESS_TEXT,
                self.DELETION_TIMEOUT_MS,
            )
        self.wait_for_detached(
            AccountExplorerSelectors.TESTER_ACTIONS_BUTTON,
            self.DELETION_TIMEOUT_MS,
        )

    def _wait_for_deletion_to_finish(self) -> None:
        self.wait_for_detached(
            AccountExplorerSelectors.DELETION_IN_PROGRESS_TEXT,
            self.DELETION_TIMEOUT_MS,
        )
        self.wait_for_detached(
            AccountExplorerSelectors.TESTER_ACTIONS_BUTTON,
            self.DELETION_TIMEOUT_MS,
        )

    def open_create_subaccount_dialog(self) -> None:
        self.click(AccountExplorerSelectors.CREATE_BUTTON, 10_000)
        if self.is_visible(
            AccountExplorerSelectors.CREATE_SUBACCOUNT_OPTION, 3_000
        ):
            self.click(AccountExplorerSelectors.CREATE_SUBACCOUNT_OPTION)

    def open_tester_actions_menu(self) -> None:
        self.click(AccountExplorerSelectors.TESTER_ACTIONS_BUTTON, 30_000)
        self.page.wait_for_timeout(500)

    def open_first_actions_menu(self) -> None:
        self.click(AccountExplorerSelectors.ANY_ACTIONS_BUTTON, 30_000)
        self.page.wait_for_timeout(500)

    def click_edit_menu_item(self) -> None:
        self.click(AccountExplorerSelectors.EDIT_MENU_ITEM, 10_000)

    def wait_for_subaccount_card_ready(self) -> None:
        self.wait_for_visible(
            AccountExplorerSelectors.TESTER_ACTIONS_BUTTON, 60_000
        )
        self.page.wait_for_timeout(2_000)