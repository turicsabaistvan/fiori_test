*** Variables ***
# Environment variables with sensible defaults.
# Credentials must be provided via FIORI_USERNAME / FIORI_PASSWORD.
${BASE_URL}                  %{BASE_URL=https://account.hanatrial.ondemand.com/}
${BROWSER_TYPE}              %{BROWSER=chromium}
${HEADLESS_MODE}             %{HEADLESS=true}
${VIEWPORT_WIDTH}            1920
${VIEWPORT_HEIGHT}           1080
${DEFAULT_TIMEOUT}           10s
${LONG_TIMEOUT}              30s
${EXTRA_LONG_TIMEOUT}        180s
# Subaccount deletion in BTP Cockpit is asynchronous and can take minutes.
${DELETION_TIMEOUT}          %{DELETION_TIMEOUT=600s}

# Test data (override via environment variables if needed)
${SUBACCOUNT_NAME}           %{SUBACCOUNT_NAME=Tester}
${SUBACCOUNT_DESCRIPTION}    %{SUBACCOUNT_DESCRIPTION=Test}
${SUBACCOUNT_REGION}         %{SUBACCOUNT_REGION=US East (VA) - AWS}
${DISPLAY_TEXT_REPEAT}       %{DISPLAY_TEXT_REPEAT=15}
${DESC_TEXT_REPEAT}          %{DESC_TEXT_REPEAT=10}

# Credentials (never commit real values)
${USERNAME}                  %{FIORI_USERNAME=}
${PASSWORD}                  %{FIORI_PASSWORD=}
