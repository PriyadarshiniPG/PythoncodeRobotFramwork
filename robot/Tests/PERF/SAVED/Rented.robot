*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_Rented
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author             ShanmugaPriyan Mohan
#Last Modified  By  Shanu Mopila

*** Test Cases ***
Open SAVED From MainMenu
    [Documentation]    Open and verifies On demand page
    [Setup]    Default First TestCase Setup
    set context    Rented
    Run Keyword And Assert Failed Reason    I open Saved through Main Menu    'Unable to open recording page from main menu.'
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}
    ...    Saved is shown

Navigate to predefined VOD asset
    [Documentation]    Navigate to the predefined VOD asset
    [Setup]    Skip If Last Fail
    Move Focus to Section    ${SAVED_RENTED_LABEL}    textValue
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}
    ...    SAVED Grid Screen for given section is shown    ${SAVED_RENTED_LABEL}
    I press    OK
    I wait for 2 seconds
    Move to Provider     ${SAVED_RENTED_ASSET}


Invoke and Validate the Details Page
    [Documentation]    Navigate to the details page of VOD asset and verify the contents
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
    I wait for 5 seconds
    I dismiss video player bar
    I Press    BACK
    I Press    MENU
