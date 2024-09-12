*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_Rent    INTERIM    PROD-UK-EOS  PREPROD-UK-EOS    PROD-PL-APOLLO   VIDEO_PLAYOUT    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author             ShanmugaPriyan Mohan
#Last Modified  By  Shanu Mopila

*** Test Cases ***
Open OnDemand From MainMenu
    [Documentation]    Open and verifies On demand page
    [Tags]    TOOL_CPE
    [Setup]    Default First TestCase Setup
    set context     RentVOD
    Run Keyword And Assert Failed Reason    I open On Demand through Main Menu    'Unable to open ondemand from main menu'

Navigate to a purchasable VOD asset
    [Documentation]    Navigate to the purchasable VOD asset
    [Setup]    Skip If Last Fail
    Move Focus to Section    ${VOD_RENT_LABEL}    textValue
    Navigate to unentitled TVOD asset in Section    ${VOD_RENT_LABEL}

Invoke and Validate the Details Page
    [Documentation]    Navigate to the details page of VOD asset and verify the contents
    [Setup]    Skip If Last Fail
    I wait for 2 seconds
    I Press    OK
    log action    OpeningInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    log action  OpeningInfoPage_Done
    Invoke the Episode Picker

Purchase and validate the playback of selected TVOD asset
    [Documentation]    Start Playback of TVOD Asset
#    [Setup]    Skip If Last Fail
    #I focus Rent for
    #I Press    OK
    #Pin Entry popup is shown
    #I enter a valid pin
    Handle Popup And Play from Details Page
    log action    PlayerValidation
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Video playout is started
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify IP is Played via VLDMS
    log action    PlayerValidation_Done
    I wait for 5 seconds
    I dismiss video player bar
    I Press    BACK
    I Press    MENU
