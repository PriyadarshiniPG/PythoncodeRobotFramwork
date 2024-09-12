*** Settings ***
Documentation     Keywords for EPG Service
Library           Libraries.MicroServices.EpgService.keywords


*** Keywords ***
Get Index Of Event Metadata Segments    #USED
    [Documentation]    This keyword gets the index of event metadata segments.
    ${epg_index}    Get Epg Index    ${LAB_CONF}    ${COUNTRY}    ${OSD_LANGUAGE}
    ${failedReason}    Set Variable If    ${epg_index}    ${EMPTY}    Unable to get epg index
    Should Be Empty    ${failedReason}
    [Return]    ${epg_index}

Get Event Metadata For A Particular Segment    #USED
    [Documentation]    This keyword gets the event metadata for a particular segment. Each metadata segment resource
    ...   is effectively immutable. Will never be updated while available. All the modifications of segment
    ...   data requires generation of a new index (with a new hash).
    [Arguments]    ${hash}
    ${epg_segment}    Get Epg Segment    ${ LAB_CONF}    ${COUNTRY}    ${OSD_LANGUAGE}    ${hash}
    ${failedReason}    Set Variable If    ${epg_segment}    ${EMPTY}    Unable to get epg segment for the given hash
    Should Be Empty    ${failedReason}
    [Return]    ${epg_segment}

Get Available Future EPG Index Days    #USED
    [Documentation]    This Keyword Returns The Number Of Days For Which EPG Data Is Available 
    ${epg_index}    Get Index Of Event Metadata Segments
    @{segments_data}    Set Variable    ${epg_index.json()['entries']}
    ${random_channel_segments}    Evaluate    random.choice($segments_data)    modules=random
    ${length_of_segments}    Get Length    ${random_channel_segments["segments"]}
    Set Suite Variable    ${DAYS_OF_FUTURE_EPG_AVAILABLE}    ${length_of_segments - 8}
    [Return]    ${DAYS_OF_FUTURE_EPG_AVAILABLE}