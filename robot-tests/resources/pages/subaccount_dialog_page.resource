*** Settings ***
Library     Browser
Resource    ../common/common_variables.resource
Resource    ../selectors/subaccount_dialog_selectors.resource

*** Keywords ***
Fill Subaccount Name
    [Arguments]    ${name}
    Wait For Elements State    ${SUBACCOUNT_NAME_INPUT}    visible    timeout=${DEFAULT_TIMEOUT}
    Fill Text                  ${SUBACCOUNT_NAME_INPUT}    ${name}

Fill Subaccount Description
    [Arguments]    ${description}
    Wait For Elements State    ${SUBACCOUNT_DESCRIPTION_INPUT}    visible    timeout=${DEFAULT_TIMEOUT}
    Fill Text                  ${SUBACCOUNT_DESCRIPTION_INPUT}    ${description}

Select Subaccount Region
    [Arguments]    ${region}
    Wait For Elements State    ${SUBACCOUNT_REGION_INPUT}    visible    timeout=${DEFAULT_TIMEOUT}
    Fill Text                  ${SUBACCOUNT_REGION_INPUT}    ${region}
    Sleep                      0.5s
    Keyboard Key               press    Enter
    Sleep                      1s

Click Create Subaccount Button
    Wait For Elements State    ${SUBACCOUNT_CREATE_BUTTON}    visible    timeout=${DEFAULT_TIMEOUT}
    Click                      ${SUBACCOUNT_CREATE_BUTTON}

Wait For Onboarding Completion
    Log                        Creation in progress, waiting for onboarding to complete...
    Sleep                      1s
    ${visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${ONBOARDING_TEXT}    visible    timeout=10s
    IF    ${visible}
        Wait For Elements State    ${ONBOARDING_TEXT}    detached    timeout=${EXTRA_LONG_TIMEOUT}
    ELSE
        Log    Onboarding status completed very quickly.
    END

Click Save Button
    Wait For Elements State    ${SUBACCOUNT_SAVE_BUTTON}    visible    timeout=${DEFAULT_TIMEOUT}
    Click                      ${SUBACCOUNT_SAVE_BUTTON}

Wait For Save Dialog To Close
    Wait For Elements State    ${SUBACCOUNT_SAVE_BUTTON}    detached    timeout=${LONG_TIMEOUT}

Verify Subaccount Field Values
    [Documentation]    Asserts the values currently stored in the edit dialog.
    [Arguments]    ${expected_name}    ${expected_description}
    ${name}           ${description}=    Read Subaccount Field Values
    Should Be Equal    ${name}           ${expected_name}
    Should Be Equal    ${description}    ${expected_description}

Read Subaccount Field Values
    [Documentation]    Returns the values currently stored in the edit dialog.
    ${name}=           Get Property    ${SUBACCOUNT_NAME_INPUT}           value
    ${description}=    Get Property    ${SUBACCOUNT_DESCRIPTION_INPUT}    value
    RETURN    ${name}    ${description}
