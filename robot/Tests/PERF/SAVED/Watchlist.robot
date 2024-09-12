*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_Watchlist    INTERIM    PROD-NL-SELENE    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PROD-CH-APOLLO    PREPROD-CH-EOS    PROD-CH-EOSV2    PROD-UK-EOS    PREPROD-UK-EOS    PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    VIDEO_PLAYOUT    UK_RERUN    PROD-PL-APOLLO-RERUN     TV_APPS    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author             ShanmugaPriyan Mohan
#Last Modified  By  Shanu Mopila

*** Test Cases ***
Invoke Main Menu
    [Documentation]    Invokes Main Menu.
    [Setup]    Default First TestCase Setup
    set context    Watchlist
    Run Keyword And Assert Failed Reason    I open Main Menu    'Unable to open main menu'
    wait until keyword succeeds    10 times    0    Main Menu is shown

#Navigate to predefined Watchlist asset
#    [Documentation]    Navigate to the predefined VOD asset
#    [Setup]    Skip If Last Fail
#    Move Focus to Section    ${SAVED_WATCHLIST_LABEL}    textValue
#    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}
#    ...    SAVED Grid Screen for given section is shown    ${SAVED_WATCHLIST_LABEL}
#    I wait for 2 seconds
#    I press    OK
#    I wait for 2 seconds
#    Move to Provider    ${SAVED_WATCHLIST_ASSET}

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
    log action    OpeningInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    log action  OpeningInfoPage_Done

Validate the playback of selected asset
    [Documentation]    Start Playback of TVOD Asset
    [Setup]    Skip If Last Fail
    Handle Popup And Play from Details Page
    log action    PlayerValidation
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Video playout is started
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify IP is Played via VLDMS
    log action    PlayerValidation_Done
    I wait for 5 seconds
    I dismiss video player bar
    I Press    BACK
    I Press    MENU
