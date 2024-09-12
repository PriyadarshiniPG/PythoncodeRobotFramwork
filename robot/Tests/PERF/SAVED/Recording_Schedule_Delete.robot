*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_REC_Schedule_Delete    PROD-NL-SELENE    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-UK-EOS  PREPROD-UK-EOS   PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author              ShanmugaPriyan Mohan
#Last Modified By    Shanu Mopila

*** Test Cases ***
From Channel Bar Schedule Ongoing Series Recording
    [Documentation]    Go to Current event on Channel Bar push REC button and record the event
    [Setup]    Default First TestCase Setup
    Run Keyword And Assert Failed Reason    tune to channel ${SAVED_SERIES_CHANNEL}
    ...   'Unable to Tune to replay channel with series'
    set context     RecordingSeriesSchedule
    Run Keyword And Assert Failed Reason    I verify that metadata is present on channel bar   Channel Don't have metadata
    I press    REC
    I wait for 2 seconds
    I focus 'Record this episode'
    I press    OK
    log action    Recording_Scheduled
    run keyword if     '${LDVR_ENABLED}' == 'True'    wait until keyword succeeds   ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Recording Scheduled toast message is shown(LDVR)
    ...    ELSE    wait until keyword succeeds   ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Recording Scheduled toast message is shown(NDVR)
    log action    Recording_Scheduled_Done

    ${live_event_id}    I retrieve value for key 'id' in element 'textKey:DIC_GENERIC_AIRING_TIME_NOW'
    ${index}    Get Regexp Matches    ${live_event_id}    ([\\d]+)$    0
    ${index}    set variable    @{index}[0]
    ${title_text_id}    set variable    id:titleText${index}
    ${program_name}    I retrieve value for key 'textValue' in element '${title_text_id}'
    log to console    program_name: ${program_name}
    Set suite variable    ${SAVED_RECORDINGS_DELETE_SERIES_ASSET}    ${program_name}

Delete the ongoing Recorded Series
    [Documentation]    Recordings Screen
    [Setup]    Skip If Last Fail
    I open Recordings through Saved
    I Press    OK
    ${action_found}    Run Keyword And Return Status   Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:RecordingList.View'
    Should Be True    ${action_found}    Unable to open Recording list
    I wait for 5 seconds
#    Move To Element Assert Provided Element Is Highlighted    textValue:${SAVED_RECORDINGS_DELETE_SERIES_ASSET}
#    ...   ${10}   DOWN
#    Move To Element Assert Provided Element Is Highlighted    ${SAVED_RECORDINGS_DELETE_SERIES_ASSET}     ${100}
    ${SAVED_RECORDINGS_DELETE_SERIES_ASSET}    run keyword if   '${COUNTRY}' == 'pl'
    ...    Extract Episode name from Recording    ${SAVED_RECORDINGS_DELETE_SERIES_ASSET}
    ...    ELSE    Set Variable    ${SAVED_RECORDINGS_DELETE_SERIES_ASSET}
    Move To Element Assert Provided Element Is Highlighted    ${SAVED_RECORDINGS_DELETE_SERIES_ASSET}     ${100}

    I focus the delete icon for the recording
    I Press    OK
    I wait for 2 seconds
    I focus 'Stop & Delete Recording' option
    I Press    OK
    log action   Recording_Deleted
    wait until keyword succeeds   ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}
    ...   Episode Recording Deleted toast message is shown
    log action   Recording_Deleted_Done

From Channel Bar Schedule Ongoing Single Event Recording
    [Documentation]    Go to Current event on Channel Bar push REC button and record the event
    Run Keyword And Assert Failed Reason    tune to channel ${SAVED_SINGLE_EVENT_CHANNEL}
    ...   'Unable to Tune to replay channel with single event.'
    set context     RecordingSingleSchedule
    Run Keyword And Assert Failed Reason    I verify that metadata is present on channel bar   Channel Don't have metadata
    I press    REC
    run keyword if     '${LDVR_ENABLED}' == 'True' or '${COUNTRY}' == 'ch'   run keywords
    ...   I wait for 2 seconds
    ...   AND   I Press    OK
    log action    Recording_Scheduled
    run keyword if     '${LDVR_ENABLED}' == 'True'    wait until keyword succeeds   ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Recording Scheduled toast message is shown(LDVR)
    ...    ELSE    wait until keyword succeeds   ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Recording Scheduled toast message is shown(NDVR)
    log action    Recording_Scheduled_Done
    ${channel_id}    Get channel ID using channel number    ${SAVED_SINGLE_EVENT_CHANNEL}
    @{current_event}    Get current channel event via as    ${channel_id}
    Set Test variable    ${LAST_REC_ID}    @{current_event}[0]
    set suite variable     ${RECORDED_EVENT_CRID}   ${LAST_REC_ID}
    ${response}    Get Details Of Single Recording    ${LAST_REC_ID}
    log to console    program_title: &{response}[title]
    Set suite variable    ${SAVED_RECORDINGS_DELETE_SINGLE_ASSET}    &{response}[title]


Delete the ongoing Recorded Single Event
    [Documentation]    Recordings Screen
    [Setup]    Skip If Last Fail
    I open Recordings through Saved
    I Press    OK
    ${action_found}    Run Keyword And Return Status   Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:RecordingList.View'
    Should Be True    ${action_found}    Unable to open Recording list
    I wait for 5 seconds
#    Move To Element Assert Provided Element Is Highlighted    textValue:${SAVED_RECORDINGS_DELETE_SINGLE_ASSET}
#    ...   ${10}   DOWN
    Move To Element Assert Provided Element Is Highlighted    ${SAVED_RECORDINGS_DELETE_SINGLE_ASSET}     ${100}
    I focus the delete icon for the recording
    I Press    OK
    I wait for 2 seconds
    I focus 'Stop & Delete Recording' option
    I Press    OK
    log action   Recording_Deleted
    wait until keyword succeeds   ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}
    ...   Recording Deleted toast message is shown
    log action   Recording_Deleted_Done