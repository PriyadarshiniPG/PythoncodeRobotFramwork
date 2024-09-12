*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        Test_2    JIRA_CatchupiTVHub    PROD-UK-EOS   PREPROD-UK-EOS  R4_25    PROD-UK-BENTO    PREPROD-UK-BENTO
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author             ShanmugaPriyan Mohan
#Last Modified  By  Shanu Mopila

*** Test Cases ***
Open CatchUP From MainMenu
    [Documentation]    Open and verifies Catchup page
    [Setup]    Default First TestCase Setup
    set context     CatchupiTVHub
    I open CatchUP through Main Menu
    I wait for 2 seconds
    I Press     RIGHT
    I wait for 2 seconds
    I Press     DOWN
    I wait for 2 seconds
    I Press     DOWN
    #Navigate To Filter     DIC_FILTER_ALL_CHANNELS
    #I Press     OK
    #Move Focus to Option in Value Picker    textValue:ITV Hub    DOWN
    #I Press     OK
    log action     CatchupiTVHub
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}
    ...    Catchup Catalog for ITV Hub is shown
    log action     CatchupiTVHub_Done

Navigate to predefined Asset from Catalog
    [Documentation]    Navigate to the predefined  asset
    [Setup]    Skip If Last Fail
    ${FourthAsset}    Get Title of Tile at Position in Grid    ${1}
    ${FifthAsset}    Get Title of Tile at Position in Grid    ${2}
    Move to Provider    ${FourthAsset}
    I Press     RIGHT
    I Press     DOWN
    I Press     OK
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
    [Setup]    Skip If Last Fail
    I Focus All Episode
    I Press    OK
    log action    OpenEpisodePicker
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Episode picker is shown
    log action    OpenEpisodePicker_Done

Invoke and Validate the Episode Details Page
    [Documentation]    Navigate to the details page of episode and verify the contents
    [Setup]    Skip If Last Fail
    I Press    OK
    log action    OpeningInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    log action  OpeningInfoPage_Done

Rent and validate the playback of selected TVOD asset
    [Documentation]    Start Playback of TVOD Asset
    [Setup]    Skip If Last Fail
    Handle Popup And Play from Details Page
    log action    PlayerValidation
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Video playout is started
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify IP is Played via VLDMS
    log action    PlayerValidation_Done

Stop Playback and Validate the Episode Details Page
    [Documentation]    Stop playpack and return to the details page of episode
    [Setup]    Skip If Last Fail
    I wait for 5 seconds
    I dismiss Video Player Bar
    set context     CatchupiTVHub_Back
    I Press    BACK
    log action    OpeningInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    log action  OpeningInfoPage_Done

Return to the Episode Picker
    [Documentation]    Return to the episode picker of VOD asset and verify the contents
    [Setup]    Skip If Last Fail
    I Press    BACK
    log action    OpenEpisodePicker
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Episode picker is shown
    log action    OpenEpisodePicker_Done

Return and Validate the Catchup Screen
    [Documentation]    Return to the Catchup screen
    [Setup]    Skip If Last Fail
    I Press    BACK
    I Press    BACK
    log action     CatchupScreen
    CatchUP is shown
    log action     CatchupScreen_Done
