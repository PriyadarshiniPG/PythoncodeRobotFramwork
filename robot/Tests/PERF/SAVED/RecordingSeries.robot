*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_RecordingSeries
                  ...   PROD-NL-SELENE    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO
                  ...   PROD-UK-EOS  PREPROD-UK-EOS
                  ...   PROD-IE-EOS    PREPROD-IE-EOS
                  ...   PROD-PL-APOLLO
                  ...   PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PROD-CH-EOS    PREPROD-CH-EOS
                  ...   VIDEO_PLAYOUT     TV_APPS    PROD-BE-EOSV2    UK_33    INTERIM    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author             ShanmugaPriyan Mohan
#Last Modified  By  Shanu Mopila

*** Test Cases ***
Open SAVED From MainMenu
    [Documentation]    Open and verifies On demand page
    [Setup]    Default First TestCase Setup
    set context    RecordingSeries
    Run Keyword And Assert Failed Reason    I open Saved through Main Menu    'Unable to open recording page from main menu.'
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}
    ...    Saved is shown

Navigate to predefined Recording from Recording List
    [Documentation]    Navigate to the predefined VOD asset
    [Setup]    Skip If Last Fail
#    Move Focus to Section    ${SAVED_RECORDINGS_LABEL}    textValue
#    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}
#    ...    SAVED Grid Screen for given section is shown    ${SAVED_RECORDINGS_LABEL}
#    I wait for 2 seconds
#    I press    OK
    I wait for 2 seconds
#    Move Focus to Collection named    DIC_RECORDING_LABEL_RECORDED
    I press    OK
    log action      RecordingListDisplayed
    Recording List screen is Displayed
    log action      RecordingListDisplayed_Done
    ${SAVED_RECORDINGS_SERIES_ASSET}    run keyword if   '${COUNTRY}' == 'pl'
    ...    Extract Episode name from Recording    ${SAVED_RECORDINGS_SERIES_ASSET}
    ...    ELSE    Set Variable    ${SAVED_RECORDINGS_SERIES_ASSET}
    Move To Element Assert Provided Element Is Highlighted    ${SAVED_RECORDINGS_SERIES_ASSET}     ${10}

Invoke and Validate the Details Page
    [Documentation]    Navigate to the details page of VOD asset and verify the contents
    [Setup]    Skip If Last Fail
    I Press    OK
    log action    OpeningSeriesInfoPage
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
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
    I dismiss video player bar
    set context     RecordingSeries_Back
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

Return and Validate the Recording List Screen
    [Documentation]    Return to the Recording List Screen
    #[Setup]    Skip If Last Fail
    I Press    BACK
    log action    RecordingListDisplayed
    Recording List screen is Displayed
    log action  RecordingListDisplayed_Done

Return and Validate the Recording Collection Screen
    [Documentation]    Return to the Recording Collection
    #[Setup]    Skip If Last Fail
    I Press    BACK
    log action    RECORDINGS
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}
    ...    Saved is shown
    log action  RECORDINGS_Done
