*** Settings ***
Documentation     Local Recordings Implementation keywords
Resource          ../Common/Common.robot
Resource          ../CommonPages/Modal_Implementation.robot
Resource          ../CommonPages/ValuePicker_Implementation.robot
Resource          ../PA-19_Cloud_Recordings/PVR_Keywords.robot
Resource          ../PA-06_TV_Guide/TVGuide_Keywords.robot

*** Variables ***
${DISK_SPACE_UNCHANGED_TOLERANCE_VALUE}    25000
${WAIT_FOR_RB_TO_CLEAR_VALUE_MS}    500
@{SINGLE_EVENT_CHANNEL_LIST}    905    906    907    908    909    910    911
# When the requested series channels of the same event length are created, these channel numbers must be changed
@{SERIES_EVENT_CHANNEL_LIST}    999    999    999    999    999    999    999
${TIME_NEEDED_FOR_MAX_RECS_IN_SECONDS}    150
# Currently, the 7th concurrent recording will create a conflict
${CONFLICT_RECORDING_INDEX}    6

*** Keywords ***
Get recording count
    [Documentation]    Gets the number of recordings that are in-progress or already recorded
    ...    via Application Services and returns this value.
    ${recording_collection_details}    get recording collection via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    [Return]    ${recording_collection_details.recordings.totalRecordings}

Get planned recording count
    [Documentation]    Gets the number of planned recordings via Application Services and returns this value.
    ${recording_collection_details}    get recording collection via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
#    ${type_recording_collection_details}    Evaluate     type(${recording_collection_details})
#    ${total_bookings}    Set variable    ${recording_collection_details.bookings.totalBookings}
    ${total_bookings}    Set variable    ${recording_collection_details['bookings']['totalBookings']}
    [Return]    ${total_bookings}

Get disk storage information
    [Documentation]    Gets the total disk space, disk free space and space occupied by the review buffer, in Kb and
    ...    returns these values in a list.
    ${disk_storage_info}    get storage info via vldms    ${STB_IP}    ${CPE_ID}
    [Return]    ${disk_storage_info}

Get total disk space in Kb
    [Documentation]    Get the total disk space in Kb from the storage information data returned from vldms
    ...    and returns this value.
    ${disk_storage_info}    get storage info via vldms    ${STB_IP}    ${CPE_ID}
    [Return]    ${disk_storage_info['totalSpace']}

Get disk free space in Kb
    [Documentation]    Get the disk free space in Kb from the storage information data returned from vldms
    ...    and returns this value.
    ${disk_storage_info}    get storage info via vldms    ${STB_IP}    ${CPE_ID}
    [Return]    ${disk_storage_info['freeSpace']}

Get disk space occupied by review buffer in Kb
    [Documentation]    Get the disk space occupied by the review buffer in Kb from the
    ...    storage information data returned from vldms and returns this value.
    ${disk_storage_info}    get storage info via vldms    ${STB_IP}    ${CPE_ID}
    [Return]    ${disk_storage_info['spaceOccupiedByReviewBuffer']}

Get free disk space in Kb when Review Buffer occupies no space
    [Documentation]    This keyword exits to live then changes channels to kill the review buffer before
    ...    fetching the totalSpace in Kb using AS and returning this value.
    ...    NOTE: This keyword should not be called as part of suite setup as the tuning keyword sets test variables
    ...    when no test has started, which causes a failure.
    I tune to a linear channel
    video playing
    I press    CHANNELDOWN
    I wait for ${WAIT_FOR_RB_TO_CLEAR_VALUE_MS} ms
    ${disk_free_space}    Get disk free space in Kb
    [Return]    ${disk_free_space}

Get padding picker current and desired positions as index values
    [Arguments]    ${padding_text_value}
    [Documentation]    This keyword works out the index positions of the padding picker current position,
    ...    (argument ${padding_text_value}) and desired position and returns them.
    @{picker_text_values}    Create List
    ${current_picker_highlight_position}    Set variable    ${None}
    ${json_object}    Get Ui Json
    ${json_string}    Read Json As String    ${json_object}
    @{collection}    get regexp matches    ${json_string}    picker-item-text-(\\d+)
    ${count}    Get Length    ${collection}
    : FOR    ${_}    IN RANGE    ${count}
    \    ${int_val}    Convert to Integer    ${_}
    \    ${picker_text_value}    Extract Value For Key    ${json_object}    id:picker-item-text-${int_val}    textValue
    \    append to list    ${picker_text_values}    ${picker_text_value}
    \    ${status}    Run Keyword and Return Status    I expect page element 'id:picker-item-text-${int_val}' contains 'color:${HIGHLIGHTED_OPTION_COLOUR}'
    \    ${current_picker_highlight_position}    Set Variable if    ${status}    ${int_val}    ${current_picker_highlight_position}
    ${desired_picker_highight_position}    Get Index From List    ${picker_text_values}    ${padding_text_value}
    [Return]    ${current_picker_highlight_position}    ${desired_picker_highight_position}

Get data for all bookings
    [Documentation]    Gets the number of planned recordings via Application Services and returns this value.
    ${recording_collection_details}    get recording collection via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    @{bookings_list}    Create List
    : FOR    ${_}    IN    @{recording_collection_details.bookings.bookingsData}
    \    Append to List    ${bookings_list}    ${_}
    [Return]    @{bookings_list}

Get item at index '${index}' in the list of all bookings
    [Documentation]    Gets the item at index ${index} from the list of all bookings
    ${bookings_list}    Get data for all bookings
    [Return]    @{bookings_list}[${index}]

Set '${event_type}' event to record
    [Documentation]    This keyword sets a single event or series episode to record. It performs no checks as
    ...    the attempt may result in failures, conflicts or success, which is up to the calling keyword to deal with.
    ...    Valid values for ${event_type} are 'single' and 'episode'
    ...    Pre-reqs: The user is on part of the UI or tuned to channel etc. where a recording modal will
    ...    appear when the REC button is pressed.
    I press    REC
    Run keyword if    '${event_type}' == 'single'    Run keywords    Interactive modal with options 'Record' and 'Close' is shown
    ...    AND    I press OK on 'Record' option
    ...    ELSE    Run keywords    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    ...    AND    I press OK on 'Record this episode' option

Get recording records using filter status and status list
    [Arguments]    ${status_list}
    [Documentation]    This keyword gets all recordings that match the status or statuses in argument ${status_list}
    ${rec_records}    get recordings filter status via as    ${STB_IP}    ${CPE_ID}    ${status_list}    xap=${XAP}
    [Return]    ${rec_records}

Get highlighted future event date and time as an epoch time
    [Documentation]    This keyword calculates the epoch time of a currently highlighted future event using a
    ...    combination of the date and the event start time, as displayed in the guide, and returns this value.
    ...    It takes into account that the future event may now be on the next day.
    ${timestamp_y_m_d}    robot.libraries.DateTime.get current date    result_format=%Y-%m-%d 12:00:00
    ${part_of_day}    ${start_time}    ${end_time}    Get highlighted event time data
    ${timestamp_y_m_d}    run keyword if    """${part_of_day}""" == "Tomorrow"    add time to date    ${timestamp_y_m_d}    1 day
    ...    ELSE    set variable    ${timestamp_y_m_d}
    ${timestamp_y_m_d}    Convert date    ${timestamp_y_m_d}    datetime
    ${padded_month}    run keyword if    ${timestamp_y_m_d.month} < 10    catenate    SEPARATOR=    0    ${timestamp_y_m_d.month}
    ...    ELSE    set variable    ${timestamp_y_m_d.month}
    ${padded_day}    run keyword if    ${timestamp_y_m_d.day} < 10    catenate    SEPARATOR=    0    ${timestamp_y_m_d.day}
    ...    ELSE    set variable    ${timestamp_y_m_d.day}
    ${final_date_timestamp}    catenate    SEPARATOR=    ${timestamp_y_m_d.year}    -    ${padded_month}    -
    ...    ${padded_day}    ${SPACE}    ${start_time}    :00
    ${final_date_timestamp_epoch}    convert date    ${final_date_timestamp}    epoch
    ${final_date_timestamp_epoch}    convert to integer    ${final_date_timestamp_epoch}
    [Return]    ${final_date_timestamp_epoch}

Get quota usage
    [Documentation]    Gets the quota or disk space used in percentage
    ${disk_storage_info}    get recordings quota status via as    ${STB_IP}    ${CPE_ID}
    [Return]    ${disk_storage_info}
