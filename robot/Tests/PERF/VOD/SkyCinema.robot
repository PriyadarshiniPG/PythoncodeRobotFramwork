*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_SkyCinema    PROD-IE-EOS    PREPROD-IE-EOS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author             Shanu Mopila


*** Test Cases ***
Open OnDemand From MainMenu
    [Documentation]    Open and verifies On demand page
    [Setup]    Default First TestCase Setup
    set context     SkyCinemaVOD
    Run Keyword And Assert Failed Reason    I open On Demand through Main Menu    'Unable to open ondemand from main menu'

Navigate to predefined VOD asset
    [Documentation]    Navigate to the predefined VOD asset
    [Setup]    Skip If Last Fail
    Move Focus to Section    ${VOD_SKYCINEMA_LABEL}    textValue
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}
    ...    VOD Grid Screen for given section is shown    ${VOD_SKYCINEMA_LABEL}
    I wait for 2 seconds
    I press    OK
    I press    DOWN
    I press    DOWN
    I wait for 2 seconds
    Moved to Named VOD Collection     ${VOD_SKYCINEMA_COLLECTION}
    I press    OK
    log action     SkyCinemaSeeAll
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Second Level VOD Screen is Shown
    ...    ${VOD_SKYCINEMA_COLLECTION_HEADING}
    log action     SkyCinemaSeeAll_Done
    Move to Provider    ${VOD_SKYCINEMA_ASSET}


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
    Handle Popup And Play from Details Page
    log action    PlayerValidation
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Video playout is started
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify IP is Played via VLDMS
    log action    PlayerValidation_Done


Exit PlayBack and Return to Details Page
    [Documentation]    Navigate to the details page of VOD asset and verify the contents
    [Setup]    Skip If Last Fail
    set context    SkyCinemaVOD_Back
    I wait for 5 seconds
    I dismiss video player bar
    I Press     BACK
    log action    OpeningInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    log action  OpeningInfoPage_Done

Return Back to Sky Cinema See All Page
    [Documentation]    Return Back to Sky Cinema See All Page
    [Setup]    Skip If Last Fail
    I wait for 2 seconds
    I Press     BACK
    log action     SkyCinemaSeeAll
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Second Level VOD Screen is Shown
    ...    ${VOD_SKYCINEMA_COLLECTION_HEADING}
    log action     SkyCinemaSeeAll_Done

Return Back to Sky Cinema Main Page
    [Documentation]    Return Back to Sky Cinema Main Page
    [Setup]    Skip If Last Fail
    I Press    BACK
    log action    SkyCinemaMainPage
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}
    ...    VOD Grid Screen for given section is shown    ${VOD_SKYCINEMA_LABEL}    ${False}    ${False}
    log action  SkyCinemaMainPage_Done
