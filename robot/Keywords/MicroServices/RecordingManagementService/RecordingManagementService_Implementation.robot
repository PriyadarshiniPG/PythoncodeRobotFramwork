*** Settings ***
Documentation     Recording Management Service - Implementation
Library           Libraries.MicroServices.RecordingManagementService.RecordingManagementService

*** Keywords ***
Get LDVR Recording Data With Filters Via RMS
    [Documentation]    This keyword gets the LDVR recording based on the filters given as arguments
    [Arguments]     ${show_id}=${EMPTY}   ${channel_id}=${EMPTY}     ${recording_state}=${EMPTY}
    ...    ${season_id}=${EMPTY}    ${most_relevant_episode_for}=recordings
    ${recordings}     Get Recordings With Filters Via Rms    ${customer_id}    ${OSD_LANGUAGE}    ${CPE_ID}
    ...    ${show_id}    ${season_id}    ${channel_id}    ${recording_state}    ${most_relevant_episode_for}
    [Return]    ${recordings}

Get nDVR Recording Data With Filters Via RMS
    [Documentation]    This keyword gets the nDVR recording based on the filters given as arguments
    [Arguments]     ${show_id}=${EMPTY}   ${channel_id}=${EMPTY}     ${recording_state}=${EMPTY}
    ...    ${season_id}=${EMPTY}    ${most_relevant_episode_for}=recordings    ${CPE_ID}=${EMPTY}
    ${recordings}     Get Recordings With Filters Via Rms    ${customer_id}    ${OSD_LANGUAGE}    ${CPE_ID}
    ...    ${show_id}    ${season_id}    ${channel_id}    ${recording_state}    ${most_relevant_episode_for}
    [Return]    ${recordings}

Delete A Recording From CPE Via RMS
    [Documentation]    This keyword deletes the given recording from the given cpe
    [Arguments]     ${event_id}
    ${http_response}    Delete Single Local Recording    ${customer_id}    ${CPE_ID}    ${event_id}
    Check Respond Status And failedReason    ${http_response}    204

Schedule A Single NDVR Recording Via RMS
    [Documentation]    This keyword schedules the nDVR recording for the given event
    [Arguments]     ${event_id}
    ${http_response}    Schedule Single Ndvr Recording Via Rms    ${customer_id}    ${event_id}
    Check Respond Status And failedReason    ${http_response}    201

Delete A Single nDVR Recording Via RMS
    [Documentation]    This keyword deletes the given nDVR recording
    [Arguments]     ${event_id}
    ${http_response}    Delete Single Ndvr Recording    ${customer_id}    ${event_id}
    Check Respond Status And failedReason    ${http_response}    204

Schedule nDVR Show Via RMS
    [Documentation]    This keyword schedules the nDVR show
    [Arguments]     ${event_id}
    ${http_response}    Schedule Ndvr Show Recording Via Rms    ${customer_id}    ${event_id}
    Check Respond Status And failedReason    ${http_response}    201

Get Details Of A Recording Via RMS
    [Documentation]    This keyword gets the details of the recording for the given event id
    [Arguments]     ${event_id}
    ${recording_details}     Get Recording Details Via Rms    ${customer_id}    ${event_id}
    Should Not Be Empty    ${recording_details}    Recording details is empty for the event with id '${event_id}'
    [Return]    ${recording_details}

Get All Channels Detail Via RMS
    [Documentation]    This keyword gets the details of all the channels
    ${channels}     Get All Channels Via Rms
    Should Not Be Empty    ${channels}    All channels response via RMS is empty
    [Return]    ${channels}

Get Details Of A Channel Via RMS
    [Documentation]    This keyword gets the details of the given channel
    [Arguments]     ${channel_id}
    ${channel_details}     Get Details Of Given Channel Via Rms    ${channel_id}
    Should Not Be Empty    ${channel_details}    Channel details of channel id '${channel_id}' is empty
    [Return]    ${channel_details}

Delete Season Recordings Or Bookings via RMS
    [Documentation]    This keyword deletes a season in recordings/bookings
    ...    param: recordings_kind -> takes values as 'recordings' or 'bookings'
    [Arguments]    ${season_id}    ${channel_id}    ${recordings_kind}
    ${http_response}     Delete Season Recordings Or Bookings    ${customer_id}    ${season_id}    ${channel_id}    ${recordings_kind}
    Check Respond Status And failedReason    ${http_response}    204

Delete Show Recordings Or Bookings via RMS
    [Documentation]    This keyword deletes a show in recordings/bookings
    ...    param: recordings_kind -> takes values as 'recordings' or 'bookings'
    [Arguments]    ${show_id}    ${channel_id}    ${recordings_kind}
    ${http_response}     Delete Show Recordings Or Bookings    ${customer_id}    ${show_id}    ${channel_id}    ${recordings_kind}
    Check Respond Status And failedReason    ${http_response}    204