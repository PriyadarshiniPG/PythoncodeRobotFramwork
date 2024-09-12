*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_CatchupSRFzweiHD
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author             Rajaram Suyamboo

*** Test Cases ***
Open CatchUP From MainMenu
    [Documentation]    Open and verifies Catchup page
    [Tags]    TOOL_CPE
    [Setup]    Default First TestCase Setup
    set context     CatchupSRFzweiHD
    I open CatchUP through Main Menu
    I wait for 2 seconds
    Move Focus to Section    CHANNELS    textValue
    I Press     DOWN
    I Press     OK
    I wait for 2 seconds
    I Press     UP
    I wait for 1 seconds
    Navigate To Filter     DIC_FILTER_ALL_CHANNELS
    I Press     OK
    Move Focus to Option in Value Picker    textValue:SRF zwei HD    DOWN
    I Press     OK
    log action     CatchupSRFzweiHD
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}
    ...    Catchup Catalog for SRF zwei HD is shown
    log action     CatchupSRFzweiHD_Done

Navigate to predefined Asset from Catalog
    [Documentation]    Navigate to the predefined  asset
    [Setup]    Skip If Last Fail
    ${FourthAsset}    Get Title of Tile at Position in Grid    ${3}
    ${FifthAsset}    Get Title of Tile at Position in Grid    ${4}
    Move to Provider     ${FourthAsset}
    I Press     RIGHT
    log action     FifthAsset
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Tile is Focused
    ...    ${FifthAsset}    title
    log action     FifthAsset_Done

Invoke and Validate the Details Page
    [Documentation]    Navigate to the details page of VOD asset and verify the contents
    [Setup]    Skip If Last Fail
    I Press    OK
    log action    OpeningSeriesInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    log action  OpeningSeriesInfoPage_Done

Invoke the Episode Picker
    [Documentation]    Navigate to the episode picker of VOD asset and verify the contents
#    [Setup]    Skip If Last Fail
    I Focus All Episode
    I Press    OK
    log action    OpenEpisodePicker
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Episode picker is shown
    log action    OpenEpisodePicker_Done

Invoke and Validate the Episode Details Page
    [Documentation]    Navigate to the details page of episode and verify the contents
#    [Setup]    Skip If Last Fail
    I Press    OK
    log action    OpeningInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    log action  OpeningInfoPage_Done

Rent and validate the playback of selected TVOD asset
    [Documentation]    Start Playback of TVOD Asset
#    [Setup]    Skip If Last Fail
    Handle Popup And Play from Details Page
    log action    PlayerValidation
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Video playout is started
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify IP is Played via VLDMS
    log action    PlayerValidation_Done

Stop Playback and Validate the Episode Details Page
    [Documentation]    Stop playpack and return to the details page of episode
#    [Setup]    Skip If Last Fail
    I wait for 5 seconds
    I dismiss Video Player Bar
    set context     CatchupSRFzweiHD_Back
    I Press    BACK
    log action    OpeningInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    log action  OpeningInfoPage_Done

Return to the Episode Picker
    [Documentation]    Return to the episode picker of VOD asset and verify the contents
#    [Setup]    Skip If Last Fail
    I Press    BACK
    log action    OpenEpisodePicker
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Episode picker is shown
    log action    OpenEpisodePicker_Done

Return and Validate the Catchup Screen
    [Documentation]    Return to the Catchup screen
#    [Setup]    Skip If Last Fail
    I Press    BACK
    log action     CatchupScreen
    CatchUP is shown
    log action     CatchupScreen_Done
