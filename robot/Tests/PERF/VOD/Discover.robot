*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_Discover    INTERIM   PROD-CH-EOS    PREPROD-CH-EOS    PROD-UK-EOS  PREPROD-UK-EOS   PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    VIDEO_PLAYOUT    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2       UK_R4_31    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    UK_33    UK_BUG    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author             ShanmugaPriyan Mohan
#Last Modified  By  Shanu Mopila

*** Test Cases ***
Open OnDemand From MainMenu
    [Documentation]    Open and verifies On demand page
    [Setup]    Default First TestCase Setup
    set context     DiscoverVOD
    Run Keyword And Assert Failed Reason    I open On Demand through Main Menu    'Unable to open ondemand from main menu'

Navigate to predefined VOD asset
    [Documentation]    Navigate to the predefined VOD asset
    [Setup]    Skip If Last Fail
    Move Focus to Section    ${VOD_DISCOVER_LABEL}    textValue
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}
    ...    VOD Grid Screen for given section is shown    ${VOD_DISCOVER_LABEL}
    I wait for 2 seconds
    I press    OK
    I press    DOWN
    I press    DOWN
    I wait for 2 seconds
    Moved to Named VOD Collection     ${VOD_DISCOVER_COLLECTION}
    Moved to Named Tile in Collection    ${VOD_DISCOVER_ASSET}


Invoke and Validate the Details Page
    [Documentation]    Navigate to the details page of VOD asset and verify the contents
    [Setup]    Skip If Last Fail
    I Press    OK
    log action    OpeningInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    log action  OpeningInfoPage_Done
    Invoke the Episode Picker

Rent and validate the playback of selected TVOD asset
    [Documentation]    Start Playback of TVOD Asset
    #[Setup]    Skip If Last Fail
    Handle Popup And Play from Details Page
    log action    PlayerValidation
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Video playout is started
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify IP is Played via VLDMS
    log action    PlayerValidation_Done

Tune To Live TV from VOD
    [Documentation]    This Keyword opens the Channel Bar
    set context     VODToLiveTV
    ${converted_channel}    Convert To String    ${CHANNEL_ZAP_SD_CHANNEL}
    ${channel_id}    I Fetch All Channel ID for given Logical Channel Number    ${converted_channel}
    I press     ${converted_channel}
    I wait for 2 seconds
    I press     OK
    log action    LiveTVStarted
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Channel Bar for live event is Shown    ${converted_channel}
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify Linear TV is Tuned via VLDMS     ${channel_id}
    log action  LiveTVStarted_Done