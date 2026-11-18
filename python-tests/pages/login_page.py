"""
Page Object for the SAP IDP login flow.
"""

from playwright.sync_api import Page

from locators.login_selectors import LoginSelectors
from pages.base_page import BasePage


class LoginPage(BasePage):
    def __init__(self, page: Page) -> None:
        super().__init__(page)

    def open(self, url: str) -> None:
        self.page.goto(url, wait_until="domcontentloaded")

    def fill_username(self, username: str) -> None:
        self.fill(LoginSelectors.USERNAME_INPUT, username)

    def submit_username_step(self) -> None:
        self.click(LoginSelectors.SUBMIT_BUTTON)
        self.wait_for_visible(LoginSelectors.PASSWORD_INPUT, 30_000)

    def verify_empty_password_error_is_shown(self) -> None:
        # Submit the password step with an empty password and expect the error.
        self.click(LoginSelectors.SUBMIT_BUTTON)
        self.wait_for_visible(LoginSelectors.ERROR_MESSAGE, 10_000)

    def fill_password(self, password: str) -> None:
        self.fill(LoginSelectors.PASSWORD_INPUT, password)

    def submit_login(self) -> None:
        self.click(LoginSelectors.SUBMIT_BUTTON)

    def accept_cookie_banner_if_present(self) -> None:
        if not self.is_visible(LoginSelectors.COOKIE_BANNER_BUTTON, 3_000):
            return
        self.click(LoginSelectors.COOKIE_BANNER_BUTTON)
