*** Settings ***
Documentation     This file holds PA-02 Reliability keywords which uses JSON(test tools)
Resource          ./Reliability_Implementation.robot

*** Keywords ***
Reliability Suite Setup
    [Documentation]    This keyword contains the reliability test setup steps
    ...    Pre-reqs: ${PREVIOUS_VERSION} variable should exist.
    [Timeout]    ${DEFAULT_SUITE_SETUP_TIMEOUT}
    Minimal Suite Setup
    run keyword if    '${SERIALCOM}' == 'True'    start serial logging    ${SERIAL_PORT}
    should not be equal    ${VERSION}    DoNotUpgrade    VERSION should have valid build name
    variable should exist    ${PREVIOUS_VERSION}    PREVIOUS_VERSION variable should be passed from command line
    Functional Specific Suite Setup
    STB Under Test Software Version
    Run Keyword If    '${PLATFORM}'!='SMT-G7400' and '${PLATFORM}'!='SMT-G7401'    Disable Pairing Device popup by spoofing paired device status

Reliability Suite Teardown
    [Documentation]    This keyword contains the reliability test teardown steps
    [Timeout]    ${TIMEOUT_20_MINUTES}
    Reset All Continue Watching Events
    Reset Watchlist
    Reset All Recordings
    Reset profiles
    run keyword if    '${SERIALCOM}' == 'True'    stop serial logging    ${SERIAL_PORT}
    Default Suite Teardown

I perform software downgrade and upgrade via ACS
    [Documentation]    This keyword performs software downgrade with ${PREVIOUS_VERSION} and upgrade with ${VERSION} via ACS with critical functional validation
    ...    Pre-reqs: ${PREVIOUS_VERSION} variable should exist.
    variable should exist    ${PREVIOUS_VERSION}    PREVIOUS_VERSION variable should be passed from command line
    I perform critical functional validation after software upgrade with    ${PREVIOUS_VERSION}
    I perform critical functional validation after software upgrade with    ${VERSION}
