*** Settings ***
Library     Browser
Resource    common_variables.resource

*** Keywords ***
Open Browser To Fiori Url
    [Documentation]    Opens a fresh browser context and navigates to the Fiori trial URL.
    [Arguments]    ${url}=${BASE_URL}
    Validate Credentials
    New Browser    ${BROWSER_TYPE}    headless=${HEADLESS_MODE}
    New Context    viewport={'width': ${VIEWPORT_WIDTH}, 'height': ${VIEWPORT_HEIGHT}}    locale=hu-HU
    New Page       ${url}

Close Browser Session
    [Documentation]    Closes the browser session cleanly.
    Close Browser    ALL

Validate Credentials
    [Documentation]    Fails fast with a clear message when credentials are missing.
    IF    '${USERNAME}' == ''
        Fail    FIORI_USERNAME environment variable is not set.
    END
    IF    '${PASSWORD}' == ''
        Fail    FIORI_PASSWORD environment variable is not set.
    END
