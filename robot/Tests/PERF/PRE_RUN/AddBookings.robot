*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        AddBookings
Resource          ./Settings.robot


#Author              Khsuahl M Jain

*** Test Cases ***

ADD Required number of planned recordings
    [Documentation]    Add the required number of planned recordings
    ${channel_lineup_response}    get all channels via linearservice
    @{blacklisted_channels}    get all recording blacklisted channels via linear service    ${channel_lineup_response}
    ${unsubscribed_channel_list}    Get List Of Linear Channel Key Via Linear Service With Filters   'id'    radio=False    4k=False    adult=False    app=False
    ...    resolution=Any    is_subscribed=False

    ${SETUP_MIN_BOOKINGS_SINGLE}    get environment variable    SETUP_MIN_BOOKINGS_SINGLE
    :FOR    ${index}    in RANGE    0    ${SETUP_MIN_BOOKINGS_SINGLE}
    \   ${event_data}   ${channel_id}    ${max_actions}    I Select Event From BO    single    ${unsubscribed_channel_list}    ${blacklisted_channels}
    \   Create Single Event Recording via AS    ${channel_id}   &{event_data}[id]   &{event_data}[startTime]
    \   log to console     book single event: ${index}

    ${SETUP_MIN_BOOKINGS_SERIES}    get environment variable    SETUP_MIN_BOOKINGS_SERIES
    ${BOOKINGS_SERIES_COUNT}    set variable   0
    :FOR    ${index}    in RANGE    0    ${SETUP_MIN_BOOKINGS_SERIES}
    \   ${event_data}   ${channel_id}    ${max_actions}    I Select Event From BO    series    ${unsubscribed_channel_list}    ${blacklisted_channels}
    \   Log    ${event_data}
    \   ${status}    run keyword and return status     Create Series Event Recording via AS    ${channel_id}   &{event_data}[id]   &{event_data}[seriesId]
    \   ...   &{event_data}[startTime]
    \   ${BOOKINGS_SERIES_COUNT}    set variable if  ${status}    ${BOOKINGS_SERIES_COUNT}+1    ${BOOKINGS_SERIES_COUNT}
    \   log to console     book series event: ${index}
    \   exit for loop if    ${BOOKINGS_SERIES_COUNT} == ${SETUP_MIN_BOOKINGS_SERIES}


*** Keywords ***
I Select Event From BO
    [Documentation]    This keyword finds a '${event_type}' Event From BO
    [Arguments]    ${event_type}    ${unsubscribed_channel_list}    ${blacklisted_channels}
    ${http_response}    Get Index Of Event Metadata Segments
    ${epg_index_json}    Set Variable    ${http_response.json()}
    @{entries}    Create List    @{epg_index_json['entries']}
    ${length}    Get Length    ${entries}
    ${is_history_present}    run keyword and return status    variable should exist  ${event_history}
    @{empty_list}    Create List
    run keyword if   not ${is_history_present}    set suite variable  ${event_history}    ${empty_list}
    Log    ${event_history}
    :FOR     ${index}    IN RANGE    ${length}
    \    ${channel_id}    Set Variable    ${entries[${index}]['channelIds'][0]}
    \    Continue For Loop If    '${channel_id}' in ${blacklisted_channels}
    \    Continue For Loop If    '${channel_id}' in ${unsubscribed_channel_list}
    \    ${channel_number}    Get Channel Number By Id    ${CITY_ID}    ${channel_id}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    \    Continue For Loop If    ${channel_number}==None
    \    Log    ${entries[${index}]['segments'][8]}
    \    ${event_hash}    Set Variable    ${entries[${index}]['segments'][8]}
    \    ${epg_segment}    Get Event Metadata For A Particular Segment    ${event_hash}
    \    ${event_list}    Set Variable    ${epg_segment.json()['entries'][0]['events']}
    \    ${event}    Get A Next Day Event Of Given Type From All Events Of The Hash    ${event_type}   ${event_list}
    \    ${event_availability}    Run Keyword And Return Status    Should Not Be Equal As Strings    '${event}'    '${None}'
    \    Continue For Loop If    ${event_availability}==${False}
    \    Log   ${event}
    \    ${is_series}    evaluate   'seriesId' in ${event}
    \    ${recording_status}    run keyword if  ${is_series}   Check If Series Recording Exist  ${channel_id}   ${event}
    \    ...   ELSE   Check If Single Recording Exist   ${event}
    \    ${history_check}    evaluate    '&{event}[id]' in ${event_history}
    \    continue for loop if    ${history_check}
    \    Exit For Loop If    not ${recording_status}
    Append To List    ${event_history}    &{event}[id]
    Set Suite Variable  ${event_history}    ${event_history}
    [Return]     ${event}    ${channel_id}    len(${event_list})
