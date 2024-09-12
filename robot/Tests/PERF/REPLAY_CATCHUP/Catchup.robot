*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        Test_3    JIRA_Catchup    PROD-CH-EOS    PREPROD-CH-EOS    PROD-UK-EOS   PREPROD-UK-EOS    PROD-IE-EOS    PREPROD-IE-EOS    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2 UK_R4_31    PROD-UK-BENTO    PREPROD-UK-BENTO    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author             ShanmugaPriyan Mohan
#Last Modified  By  Shanu Mopila

*** Test Cases ***
Open CatchUP From MainMenu
    [Documentation]    Open and verifies Catchup page
    [Setup]    Default First TestCase Setup
    set context     Catchup
    I open CatchUP through Main Menu
    log action     CatchupScreen
    CatchUP is shown
    log action     CatchupScreen_Done


Navigate to predefined Asset from Catalog
    [Documentation]    Navigate to the predefined  asset
    [Setup]    Skip If Last Fail
    I wait for 1 seconds
    I Press     DOWN
    ${json_object}    Get Ui Focused Elements
    @{section_json}    Extract Value For Key    ${json_object}    id:shared-CollectionsBrowser    items    ${TRUE}
    ${collection_data}    set variable    @{section_json}[-2]
    ${collection_title}   set variable    &{collection_data}[title]
    Moved to Named VOD Collection     ${collection_title}


Invoke and Validate the Details Page
    [Documentation]    Navigate to the details page of VOD asset and verify the contents
    [Setup]    Skip If Last Fail
    I wait for 1 seconds
    I Press     RIGHT
    I Press     RIGHT
    I Press     OK
    log action    OpeningSeriesInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    log action  OpeningSeriesInfoPage_Done

#Invoke the Episode Picker
#    [Documentation]    Navigate to the episode picker of VOD asset and verify the contents
#    #[Setup]    Skip If Last Fail
#    I Focus All Episode
#    I Press    OK
#    log action    OpenEpisodePicker
#    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Episode picker is shown
#    log action    OpenEpisodePicker_Done
#
#Invoke and Validate the Episode Details Page
#    [Documentation]    Navigate to the details page of episode and verify the contents
#    #[Setup]    Skip If Last Fail
#    I Press    OK
#    log action    OpeningInfoPage
#    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
#    log action  OpeningInfoPage_Done

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
    I dismiss video player bar
    set context     Catchup_Back
    I Press    BACK
    log action    OpeningInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    log action  OpeningInfoPage_Done

#Return to the Episode Picker
#    [Documentation]    Return to the episode picker of VOD asset and verify the contents
#    #[Setup]    Skip If Last Fail
#    I Press    BACK
#    log action    OpenEpisodePicker
#    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Episode picker is shown
#    log action    OpenEpisodePicker_Done

Return and Validate the Catchup Screen
    [Documentation]    Return to the Catchup screen
    #[Setup]    Skip If Last Fail
#    I Press    BACK
    I Press    BACK
    log action     CatchupScreen
    CatchUP is shown
    log action     CatchupScreen_Done
