*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_Kids    PROD-CH-EOS    PREPROD-CH-EOS    PROD-UK-EOS  PREPROD-UK-EOS   PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    VIDEO_PLAYOUT    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2       UK_R4_31    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author             ShanmugaPriyan Mohan
#Last Modified  By  Shanu Mopila

*** Test Cases ***
Open OnDemand From MainMenu
    [Documentation]    Open and verifies On demand page
    [Setup]    Default First TestCase Setup
    set context     KIDS_VOD
    Run Keyword And Assert Failed Reason    I open On Demand through Main Menu    'Unable to open ondemand from main menu'

Navigate to predefined VOD asset
    [Documentation]    Navigate to the predefined VOD asset
    [Setup]    Skip If Last Fail
    Move Focus to Section    ${VOD_KIDS_LABEL}    textValue
    VOD Grid Screen for given section is shown    ${VOD_KIDS_LABEL}
     Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}
    ...    VOD Grid Screen for given section is shown    ${VOD_KIDS_LABEL}
    I Wait for 2 seconds
    I press    OK
    I press    DOWN
    I press    DOWN
    I Wait for 2 seconds
    Moved to Named VOD Collection     ${VOD_KIDS_COLLECTION}
    Moved to Named Tile in Collection    ${VOD_KIDS_ASSET}


Invoke and Validate the Details Page
    [Documentation]    Navigate to the details page of VOD asset and verify the contents
    [Setup]    Skip If Last Fail
    I Press    OK
    run keyword if   '${COUNTRY}' == 'gb' and '${VOD_KIDS_COLLECTION}' == 'Channels'
    ...    I Press    OK
    log action    OpeningInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    log action  OpeningInfoPage_Done
    Invoke the Episode Picker

Rent and validate the playback of selected TVOD asset
    [Documentation]    Start Playback of TVOD Asset
#    [Setup]    Skip If Last Fail
    Handle Popup And Play from Details Page
    log action    PlayerValidation
    #wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Video player bar is shown
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Video playout is started
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify IP is Played via VLDMS
    log action    PlayerValidation_Done
    I wait for 5 seconds
    I dismiss video player bar
    I Press    BACK
    I Press    MENU