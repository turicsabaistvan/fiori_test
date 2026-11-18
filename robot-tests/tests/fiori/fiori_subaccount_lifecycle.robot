*** Settings ***
Documentation       End-to-end test for Fiori trial subaccount lifecycle.
...
...                 Covers: login, cookie handling, conditional deletion of the
...                 Tester subaccount, creation with region selection,
...                 long-text edit/save and restore to default values.
Library             Browser
Resource            ../../resources/common/common_variables.resource
Resource            ../../resources/common/browser_setup.resource
Resource            ../../resources/pages/login_page.resource
Resource            ../../resources/pages/trial_page.resource
Resource            ../../resources/pages/account_explorer_page.resource
Resource            ../../resources/pages/subaccount_dialog_page.resource

Suite Setup         Open Browser To Fiori Url
Suite Teardown      Close Browser Session
Test Teardown       Run Keyword If Test Failed    Take Screenshot    fullPage=True

*** Test Cases ***
Fiori Subaccount Lifecycle
    [Documentation]    Full lifecycle test for the Fiori trial subaccount.
    [Tags]             fiori    e2e    regression

    # 1. Login flow with negative empty-password check
    Fill Username Field              ${USERNAME}
    Submit Username Step
    Verify Empty Password Error Is Shown
    Fill Password Field
    Submit Login
    Accept Cookie Banner If Present

    # 2. Navigate to the Account Explorer
    Open Trial Account
    Navigate To Account Explorer
    Dismiss Audit Log Popup If Present

    # 3. Delete existing Tester subaccount (if any)
    Delete Tester Subaccount If Exists

    # 4. Create a new Tester subaccount
    Open Create Subaccount Dialog
    Fill Subaccount Name             ${SUBACCOUNT_NAME}
    Fill Subaccount Description      ${SUBACCOUNT_DESCRIPTION}
    Select Subaccount Region         ${SUBACCOUNT_REGION}
    Click Create Subaccount Button
    Wait For Onboarding Completion
    Wait For Subaccount Card Ready

    # 5. Long-text edit and save
    Open Tester Actions Menu
    Click Edit Menu Item

    ${display_text}=    Evaluate    "Display teszt szöveg ismétlődik. " * ${DISPLAY_TEXT_REPEAT}
    ${desc_text}=       Evaluate    "Itt a leírás szöveg ismétlődik. " * ${DESC_TEXT_REPEAT}

    Fill Subaccount Name             ${display_text}
    Fill Subaccount Description      ${desc_text}

    # Capture what the fields actually accepted (UI5 may enforce a maxlength)
    ${saved_name}    ${saved_desc}=  Read Subaccount Field Values

    Click Save Button
    Wait For Save Dialog To Close

    # 6. Restore default values
    Open First Actions Menu
    Click Edit Menu Item

    # Verify that the long values were actually persisted
    Verify Subaccount Field Values   ${saved_name}    ${saved_desc}

    Fill Subaccount Name             ${SUBACCOUNT_NAME}
    Fill Subaccount Description      ${SUBACCOUNT_DESCRIPTION}
    Click Save Button
    Wait For Save Dialog To Close
