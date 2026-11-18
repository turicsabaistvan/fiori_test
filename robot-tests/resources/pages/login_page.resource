*** Settings ***
Library     Browser
Resource    ../common/common_variables.resource
Resource    ../selectors/login_page_selectors.resource

*** Keywords ***
Fill Username Field
    [Arguments]    ${username}
    Wait For Elements State    ${LOGIN_USERNAME_INPUT}    visible    timeout=${DEFAULT_TIMEOUT}
    Fill Text                  ${LOGIN_USERNAME_INPUT}    ${username}

Submit Username Step
    Wait For Elements State    ${LOGIN_SUBMIT_BUTTON}    visible    timeout=${DEFAULT_TIMEOUT}
    Click                      ${LOGIN_SUBMIT_BUTTON}
    Wait For Elements State    ${LOGIN_PASSWORD_INPUT}    visible    timeout=${LONG_TIMEOUT}

Verify Empty Password Error Is Shown
    Wait For Elements State    ${LOGIN_SUBMIT_BUTTON}    visible    timeout=${DEFAULT_TIMEOUT}
    Click                      ${LOGIN_SUBMIT_BUTTON}
    Wait For Elements State    ${LOGIN_ERROR_MESSAGE}    visible    timeout=${DEFAULT_TIMEOUT}
    Log                        Negative login test passed: error message is visible.

Fill Password Field
    [Documentation]    Fills the password from the FIORI_PASSWORD environment variable.
    Wait For Elements State    ${LOGIN_PASSWORD_INPUT}    visible    timeout=${DEFAULT_TIMEOUT}
    Fill Secret                ${LOGIN_PASSWORD_INPUT}    %FIORI_PASSWORD

Submit Login
    Wait For Elements State    ${LOGIN_SUBMIT_BUTTON}    visible    timeout=${DEFAULT_TIMEOUT}
    Click                      ${LOGIN_SUBMIT_BUTTON}

Accept Cookie Banner If Present
    ${visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${COOKIE_BANNER_BUTTON}    visible    timeout=3s
    IF    ${visible}
        Click    ${COOKIE_BANNER_BUTTON}
        Log      Cookie banner accepted.
    ELSE
        Log      No cookie banner displayed, continuing.
    END
