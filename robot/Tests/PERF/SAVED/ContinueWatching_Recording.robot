*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_ContinueWatchingRecording    PROD-NL-SELENE    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-UK-EOS   PREPROD-UK-EOS   PROD-IE-EOS    UK_RERUN    PREPROD-IE-EOS    PROD-PL-APOLLO    VIDEO_PLAYOUT    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2     TV_APPS    PROD-BE-EOSV2    UK_33    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author             ShanmugaPriyan Mohan
#Last Modified  By  Shanu Mopila

*** Test Cases ***
Invoke Main Menu
    [Documentation]    Invokes Main Menu.
    [Setup]    Default First TestCase Setup
    set context    ContinueWatchingPlayoutFromStart(Recording)
    Run Keyword And Assert Failed Reason    I open Main Menu    'Unable to open main menu'
    wait until keyword succeeds    10 times    0    Main Menu is shown

Navigate to predefined VOD asset
    [Documentation]    Navigate to the predefined VOD asset
    [Setup]    Skip If Last Fail
    I wait for 2 seconds
    I press    DOWN
    I press    DOWN
    Moved to Named Collection     ${PHS_RAIL_CONTINUE_WATCHING_ID}
    Moved to Named Tile in Collection    ${SAVED_CONTINUE_WATCHING_RECORDING_ASSET}

Invoke and Validate the Details Page
    [Documentation]    Navigate to the details page of VOD asset and verify the contents
    [Setup]    Skip If Last Fail
    I Press    INFO
    I wait for 2 seconds
    I Press    OK
    log action    OpeningInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    log action  OpeningInfoPage_Done

Validate Playback with Play From Start
    [Documentation]    Start Playback of Recording Asset from beginning
    #[Setup]    Skip If Last Fail
    Handle Popup And Play from Details Page
    log action    PlayerValidation
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Video playout is started
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify IP is Played via VLDMS
    log action    PlayerValidation_Done

Exit PlayBack and Return to Details Page
    [Documentation]    Navigate to the details page of VOD asset and verify the contents
    #[Setup]    Skip If Last Fail
    set context    ContinueWatchingPlayoutFromStart_Back(Recording)
    I wait for 5 seconds
    I dismiss video player bar
    I Press     BACK
    log action    OpeningInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    log action  OpeningInfoPage_Done

Return Back to Continue Watching
    [Documentation]    Navigate to the details page of VOD asset and verify the contents
    #[Setup]    Skip If Last Fail
    I wait for 2 seconds
    Run Keyword And Assert Failed Reason    I open Main Menu    'Unable to open main menu'
    log action    ContinueWatchingDisplayed
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Main Menu is shown
    log action  ContinueWatchingDisplayed_Done

Navigate to predefined VOD asset for Continue Watching
    [Documentation]    Navigate to the predefined VOD asset
    [Setup]    Skip If Last Fail
    I wait for 2 seconds
    I press    DOWN
    I press    DOWN
    Moved to Named Collection     ${PHS_RAIL_CONTINUE_WATCHING_ID}
    Moved to Named Tile in Collection    ${SAVED_CONTINUE_WATCHING_RECORDING_ASSET}

Invoke and Validate the Details Page for Continue Watching
    [Documentation]    Navigate to the details page of VOD asset and verify the contents
    #[Setup]    Skip If Last Fail
    set context    ContinueWatching(Recording)
    I Press    INFO
    I wait for 2 seconds
    I Press    OK
    log action    OpeningInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    log action  OpeningInfoPage_Done

Validate Playback with Continue Watching
    [Documentation]    Resume Playback of Recording Asset
    #[Setup]    Skip If Last Fail
    Handle Popup And Play from Details Page    ${False}
    log action    PlayerValidation
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Video playout is started
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify IP is Played via VLDMS
    log action    PlayerValidation_Done
    I wait for 5 seconds
    I dismiss video player bar
    I Press    BACK
    I Press    MENU