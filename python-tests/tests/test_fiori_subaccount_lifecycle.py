"""
End-to-end test for the Fiori trial subaccount lifecycle.

Covers:
  - Login with negative empty-password check
  - Cookie banner handling
  - Conditional deletion of the "Tester" subaccount
  - Subaccount creation with region selection
  - Long-text edit/save and restore to defaults
"""

import pytest

from data import FioriTestData
from pages.account_explorer_page import AccountExplorerPage
from pages.login_page import LoginPage
from pages.subaccount_dialog_page import SubaccountDialogPage
from pages.trial_page import TrialPage


@pytest.mark.fiori
@pytest.mark.e2e
def test_full_subaccount_lifecycle(
    login_page: LoginPage,
    trial_page: TrialPage,
    account_explorer_page: AccountExplorerPage,
    subaccount_dialog_page: SubaccountDialogPage,
    base_url: str,
    credentials: dict[str, str],
    test_data: FioriTestData,
) -> None:
    # 0. Open the Fiori trial landing page
    login_page.open(base_url)

    # 1. Login flow with negative empty-password check
    login_page.fill_username(credentials["username"])
    login_page.submit_username_step()
    login_page.verify_empty_password_error_is_shown()
    login_page.fill_password(credentials["password"])
    login_page.submit_login()
    login_page.accept_cookie_banner_if_present()

    # 2. Navigate to the Account Explorer
    trial_page.open_trial_account()
    trial_page.navigate_to_account_explorer()
    trial_page.dismiss_audit_log_popup_if_present()

    # 3. Delete existing Tester subaccount (if any)
    account_explorer_page.delete_tester_subaccount_if_exists()

    # 4. Create a new Tester subaccount
    account_explorer_page.open_create_subaccount_dialog()
    subaccount_dialog_page.fill_name(test_data.subaccount_name)
    subaccount_dialog_page.fill_description(test_data.subaccount_description)
    subaccount_dialog_page.select_region(test_data.subaccount_region)
    subaccount_dialog_page.click_create_button()
    subaccount_dialog_page.wait_for_onboarding_completion()
    account_explorer_page.wait_for_subaccount_card_ready()

    # 5. Long-text edit and save
    account_explorer_page.open_tester_actions_menu()
    account_explorer_page.click_edit_menu_item()

    display_text = (
        "Sample display text repeated. " * test_data.display_text_repeat
    )
    description_text = (
        "Sample description text repeated. "
        * test_data.description_text_repeat
    )

    subaccount_dialog_page.fill_name(display_text)
    subaccount_dialog_page.fill_description(description_text)

    # Capture what the fields actually accepted (UI5 may enforce a maxlength)
    saved_name = subaccount_dialog_page.get_name_value()
    saved_description = subaccount_dialog_page.get_description_value()

    subaccount_dialog_page.click_save_button()
    subaccount_dialog_page.wait_for_save_button_hidden()

    # 6. Restore default values
    account_explorer_page.open_first_actions_menu()
    account_explorer_page.click_edit_menu_item()

    # Verify that the long values were actually persisted. UI5 may trim
    # trailing whitespace when saving, so compare the content only.
    assert subaccount_dialog_page.get_name_value().strip() == saved_name.strip()
    assert (
        subaccount_dialog_page.get_description_value().strip()
        == saved_description.strip()
    )

    subaccount_dialog_page.fill_name(test_data.subaccount_name)
    subaccount_dialog_page.fill_description(test_data.subaccount_description)
    subaccount_dialog_page.click_save_button()
    subaccount_dialog_page.wait_for_save_button_hidden()
