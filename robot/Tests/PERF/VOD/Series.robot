*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_Series    PROD-CH-EOS    PREPROD-CH-EOS    PROD-UK-EOS  PREPROD-UK-EOS  PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    VIDEO_PLAYOUT    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2     TV_APPS    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author             ShanmugaPriyan Mohan
#Last Modified  By  Shanu Mopila

*** Test Cases ***
Open OnDemand From MainMenu
    [Documentation]    Open and verifies On demand page
    [Setup]    Default First TestCase Setup
    set context     SeriesVOD
    Run Keyword And Assert Failed Reason    I open On Demand through Main Menu    'Unable to open ondemand from main menu'

Navigate to predefined VOD asset
    [Documentation]    Navigate to the predefined VOD asset
    [Setup]    Skip If Last Fail
    Move Focus to Section    ${VOD_SERIES_LABEL}    textValue
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}
    ...    VOD Grid Screen for given section is shown    ${VOD_SERIES_LABEL}
    I wait for 2 seconds
    I press    OK
    I press    DOWN
    I press    DOWN
    I wait for 2 seconds
    Moved to Named VOD Collection     ${VOD_SERIES_COLLECTION}
    Moved to Named Tile in Collection    ${VOD_SERIES_ASSET}


Invoke and Validate the Details Page
    [Documentation]    Navigate to the details page of VOD asset and verify the contents
    [Setup]    Skip If Last Fail
    I Press    OK
    log action    OpeningSeriesInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown    ${True}
    log action  OpeningSeriesInfoPage_Done

Invoke the Episode Picker
    [Documentation]    Navigate to the episode picker of VOD asset and verify the contents
    #[Setup]    Skip If Last Fail
    I Focus All Episode
    I Press    OK
    log action    OpenEpisodePicker
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Episode picker is shown
    log action    OpenEpisodePicker_Done

Invoke and Validate the Episode Details Page
    [Documentation]    Navigate to the details page of episode and verify the contents
    #[Setup]    Skip If Last Fail
    I Press    OK
    log action    OpeningInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    log action  OpeningInfoPage_Done

Rent and validate the playback of selected TVOD asset
    [Documentation]    Start Playback of TVOD Asset
    #[Setup]    Skip If Last Fail
    Handle Popup And Play from Details Page
    log action    PlayerValidation
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Video playout is started
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify IP is Played via VLDMS
    log action    PlayerValidation_Done

Stop Playback and Validate the Episode Details Page
    [Documentation]    Stop playpack and return to the details page of episode
    #[Setup]    Skip If Last Fail
    I wait for 5 seconds
    set context     SeriesVOD_Back
    I dismiss video player bar
    I Press    BACK
    log action    OpeningInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    log action  OpeningInfoPage_Done

Return to the Episode Picker
    [Documentation]    Return to the episode picker of VOD asset and verify the contents
    #[Setup]    Skip If Last Fail
    I Press    BACK
    log action    OpenEpisodePicker
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Episode picker is shown
    log action    OpenEpisodePicker_Done

Return and Validate the Series Section
    [Documentation]    Return to the Series section of  VOD Main Menu and verify the contents
    #[Setup]    Skip If Last Fail
    I Press    BACK
	I Press    BACK
    log action    SERIES
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}
    ...    VOD Grid Screen for given section is shown    ${VOD_SERIES_LABEL}    ${False}    ${False}
    log action  SERIES_Done