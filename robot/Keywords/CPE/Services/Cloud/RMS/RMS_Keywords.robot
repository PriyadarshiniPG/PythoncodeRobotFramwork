*** Settings ***
Documentation     Recording Management Service - Cloud Services - Keywords
Library           robot.libraries.DateTime
Library           Libraries.MicroServices.RecordingManagementService.RecordingManagementService

*** Variables ***
${ACTUAL_REC_LENGTH_TOLERANCE_VALUE_SECONDS}    2

*** Keywords ***
Get recording data via CS RMS recordings
    [Documentation]    This keyword gets the recording data returned using
    ...    Cloud Services Recording Manager Services by making a call to recordings
    ${customer_id}    Get application service setting    customer.customerId
    ${recordings}    get rms recordings via cs    ${customer_id}
    [Return]    ${recordings}

Get first recording data via CS RMS recordings
    [Documentation]    This keyword gets the first recording data returned using
    ...    Cloud Services Recording Manager Services by making a call to recordings
    ${recordings}    Get recording data via CS RMS recordings
    [Return]    @{recordings.data}[0]

Verify the only Event has Recording status '${status}' via CS RMS recordings
    [Documentation]    This keyword checks that the only recording we have is of status ${status} using
    ...    Cloud Services Recording Manager Services by making a call to recordings
    ${first_rec}    Get first recording data via CS RMS recordings
    Should be true    '${status}' == '${first_rec['recordingState']}'    Status retrieved from CS is not:${status}

Verify there are no recordings via CS RMS recordings
    [Documentation]    This keyword checks that there are no recordings using Cloud Services Recording Manager Services
    ...    by making a call to recordings
    ${customer_id}    Get application service setting    customer.customerId
    ${recordings}    get rms recordings via cs    ${customer_id}
    Should be true    ${recordings.total} == 0    One or more recording is present

Verify the duration of the recording is '${time_in_seconds}' seconds via CS RMS recordings
    [Documentation]    This keyword calculates the duration of a recording that is no longer ongoing, using
    ...    Cloud Services Recording Manager Services and the values recStartTime and recEndTime, which are
    ...    obtained from a call to recordings
    ${first_rec}    Get first recording data via CS RMS recordings
    ${rec_start_time}    Set Variable    ${first_rec['recStartTime']}
    ${start_time}    Convert Traxis date '${first_rec['recStartTime']}' to datetime date
    ${end_time}    Convert Traxis date '${first_rec['recEndTime']}' to datetime date
    ${rec_duration_seconds}    robot.libraries.DateTime.Subtract Date From Date    ${end_time}    ${start_time}    exclude_millis=True
    ${time_diff_seconds}    Evaluate    ${rec_duration_seconds} - ${time_in_seconds}
    ${time_diff_seconds_abs}    Evaluate    abs(${time_diff_seconds})
    Should Be True    ${time_diff_seconds_abs} < ${ACTUAL_REC_LENGTH_TOLERANCE_VALUE_SECONDS}    Expected recording duration and actual recording duration do not match
