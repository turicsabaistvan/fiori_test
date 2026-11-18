*** Settings ***
Library     Browser
Resource    ../common/common_variables.resource
Resource    ../selectors/trial_page_selectors.resource

*** Keywords ***
Open Trial Account
    Wait For Elements State    ${TRIAL_GO_TO_ACCOUNT_BUTTON}    visible    timeout=${LONG_TIMEOUT}
    Click                      ${TRIAL_GO_TO_ACCOUNT_BUTTON}

Navigate To Account Explorer
    Wait For Elements State    ${ACCOUNT_EXPLORER_LINK}    visible    timeout=${LONG_TIMEOUT}
    Click                      ${ACCOUNT_EXPLORER_LINK}

Dismiss Audit Log Popup If Present
    ${visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${AUDIT_LOG_DECLINE_BUTTON}    visible    timeout=3s
    IF    ${visible}
        Click    ${AUDIT_LOG_DECLINE_BUTTON}
        Log      Audit Log Viewer popup dismissed.
    ELSE
        Log      No Audit Log Viewer popup displayed, continuing.
    END
