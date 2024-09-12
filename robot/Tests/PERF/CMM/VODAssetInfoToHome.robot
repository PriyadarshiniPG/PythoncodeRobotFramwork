*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        VOD_AssetinfoToHome    INTERIM    BENTO    PREPROD-UK-BENTO    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-NL-SELENE    PROD-UK-EOS   PREPROD-UK-EOS    PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PREPROD-CH-EOS    PROD-CH-EOS    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    UK_BUG    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author             ShanmugaPriyan Mohan
#Last Modified  By  Shanu Mopila

*** Test Cases ***
Invoke Main Menu
    [Documentation]    Invokes Main Menu.
    [Setup]    Default First TestCase Setup
    set context     AssetinfoToHomeVOD
    Run Keyword And Assert Failed Reason    I open Main Menu    'Unable to open main menu'
    wait until keyword succeeds    10 times    0    Main Menu is shown

Navigate to predefined VOD asset
    [Documentation]    Navigate to the predefined VOD asset
    [Setup]    Skip If Last Fail
    I wait for 2 seconds
    I press    DOWN
    I press    DOWN
    Moved to Named Collection     ${PHS_RAIL_WATCHLIST_ID}
    Moved to Named Tile in Collection    ${SAVED_WATCHLIST_ASSET}


Invoke and Validate the Details Page
    [Documentation]    Navigate to the details page of VOD asset and verify the contents
    [Setup]    Skip If Last Fail
    I Press    OK

Navigate to Home
    [Documentation]    This Keyword navigates to home
    [Setup]    Skip If Last Fail
    I wait for 2 seconds
    I Press    MENU
    log action    OpenMainMenu
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Home is shown
    log action    OpenMainMenu_Done


