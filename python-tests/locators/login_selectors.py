"""
Selectors for the SAP IDP login page.
"""


class LoginSelectors:
    USERNAME_INPUT = 'input[placeholder="E-mail vagy felhasználónév"]'
    PASSWORD_INPUT = 'input[placeholder="Jelszó"]'
    SUBMIT_BUTTON = "#logOnFormSubmit"
    ERROR_MESSAGE = 'text="Nem tudtuk hitelesíteni Önt."'
    COOKIE_BANNER_BUTTON = (
        "div#truste-consent-buttons button#truste-consent-required"
    )