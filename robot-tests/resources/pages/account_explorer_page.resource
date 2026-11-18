*** Settings ***
Library     Browser
Resource    ../common/common_variables.resource
Resource    ../selectors/account_explorer_selectors.resource

*** Keywords ***
Delete Tester Subaccount If Exists
    [Documentation]    Deletes the existing "Tester" subaccount if it is present.
    # A previous run may have left a deletion in progress. In that state the
    # tile is visible but the Delete menu item is not offered, so wait for it
    # to finish before trying to delete again.
    ${already_deleting}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${DELETION_IN_PROGRESS_TEXT}    visible    timeout=1s
    IF    ${already_deleting}
        Log    A Tester subaccount deletion is already in progress, waiting for it to finish.
        Wait For Elements State    ${DELETION_IN_PROGRESS_TEXT}    detached    timeout=${DELETION_TIMEOUT}
        Wait For Elements State    ${TESTER_ACTIONS_BUTTON}        detached    timeout=${DELETION_TIMEOUT}
    END

    ${present}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${TESTER_ACTIONS_BUTTON}    visible    timeout=5s

    IF    not ${present}
        Log    No Tester subaccount found, will create one.
        RETURN
    END

    Click                      ${TESTER_ACTIONS_BUTTON}
    Wait For Elements State    ${DELETE_MENU_ITEM}    visible    timeout=5s
    Click                      ${DELETE_MENU_ITEM}
    Wait For Elements State    ${DELETE_CONFIRM_BUTTON}    visible    timeout=5s
    Click                      ${DELETE_CONFIRM_BUTTON}

    Log                        Deletion in progress, waiting for completion...
    # Deletion is asynchronous: the tile stays visible with a
    # "Deletion in Progress" badge for minutes. Wait for the badge to appear
    # first, otherwise the "detached" wait below would pass immediately while
    # the badge has not been rendered yet.
    ${deletion_started}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${DELETION_IN_PROGRESS_TEXT}    visible    timeout=${LONG_TIMEOUT}
    IF    ${deletion_started}
        Wait For Elements State    ${DELETION_IN_PROGRESS_TEXT}    detached    timeout=${DELETION_TIMEOUT}
    END
    Wait For Elements State    ${TESTER_ACTIONS_BUTTON}        detached    timeout=${DELETION_TIMEOUT}
    Log                        Existing Tester subaccount successfully deleted.

Open Create Subaccount Dialog
    Wait For Elements State    ${CREATE_BUTTON}    visible    timeout=${DEFAULT_TIMEOUT}
    Click                      ${CREATE_BUTTON}

    ${option_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${CREATE_SUBACCOUNT_OPTION}    visible    timeout=3s
    IF    ${option_visible}
        Click    ${CREATE_SUBACCOUNT_OPTION}
    ELSE
        Log      Create button opened the dialog directly.
    END

Open Tester Actions Menu
    Wait For Elements State    ${TESTER_ACTIONS_BUTTON}    visible    timeout=${LONG_TIMEOUT}
    Click                      ${TESTER_ACTIONS_BUTTON}

Open First Actions Menu
    Wait For Elements State    ${ANY_ACTIONS_BUTTON}    visible    timeout=${LONG_TIMEOUT}
    Click                      ${ANY_ACTIONS_BUTTON}

Click Edit Menu Item
    Wait For Elements State    ${EDIT_MENU_ITEM}    visible    timeout=${DEFAULT_TIMEOUT}
    Click                      ${EDIT_MENU_ITEM}

Wait For Subaccount Card Ready
    Wait For Elements State    ${TESTER_ACTIONS_BUTTON}    visible    timeout=60s
