*** Settings ***
Documentation     Stability Common keyword definitions

*** Variables ***
&{SPEED_DICTIONARY}    PAUSE=0.0    PLAY=1.0    FFWD=2.0    FFWDX6=6.0    FFWDX30=30.0    FFWDX64=64.0    FRWD=-2.0
...               FRWDX6=-6.0    FRWDX30=-30.0    FRWDX64=-64.0    SLOW_MOTION=0.5
${DURATION}       72h
${COREDUMPSDIR}    /mnt/logging/var-core-dumps/
@{ZAP_CHANNEL_LIST}    301    561    500    685    505    609    68
...               49    691    315
${ITERATIONS}     ${1000}
${STABILITY_FAIL_THRESHOLD}    2
@{STABILITY_SD_CHANNELS}    50    513    503    14    5
@{STABILITY_HD_CHANNELS}    36    67    206    11    43
@{ZAP_IP_CHANNEL_LIST}    502    506    308    684
@{STABILITY_UHD_CHANNELS}    956    957
@{TRICKPLAY_CHANNELS}    512    513
${RECORDING_TRICK_MODE_BUFFER_LENGTH}    6
${REVIEW_BUFFER_REWIND_BUFFER_WINDOW_IN_SECS}    10
${REVIEW_BUFFER_FAST_FORWARD_BUFFER_WINDOW_IN_SECS}    10
${REC_TYPE_NDVR}    nDVR
${REC_TYPE_LDVR}    lDVR
${MIN_RECORD_DURATION}    1
${RECORD_FAIL_WAIT_DURATION}    60
@{IP_LINEUP_CITY_IDS}    3002    2011
${STABILITY_DEFAULT_REPEAT_NUM}    30

*** Keywords ***
Repeat stability keyword until failure threshold is reached
    [Arguments]    ${keyword}    @{keyword_arguments}
    [Documentation]    Repeats the given stability keyword execution for a maximum of ${TEST_ITERATION_COUNT} iterations
    ...    or until the failure threshold is reached
    ...    Pre-reqs: ${TEST_ITERATION_COUNT}, ${TEST_PASS_COUNT} and ${TEST_ITERATOR} variables should exist.
    variable should exist    ${TEST_PASS_COUNT}    Suite variable TEST_PASS_COUNT has not been set.
    variable should exist    ${TEST_ITERATION_COUNT}    Suite variable TEST_ITERATION_COUNT has not been set.
    variable should exist    ${TEST_ITERATOR}    Suite variable TEST_ITERATOR has not been set.
    : FOR    ${_}    IN RANGE    ${TEST_ITERATION_COUNT}
    \    run keyword    ${keyword}    @{keyword_arguments}
    \    ${is_failure_threshold_reached}    Evaluate    ${TEST_ITERATOR}-${TEST_PASS_COUNT}>=${STABILITY_FAIL_THRESHOLD}
    \    exit for loop if    ${is_failure_threshold_reached}

Execute keyword to check if states are different
    [Arguments]    ${initial_result}    ${retrieve_keyword}    @{retrieve_keyword_arguments}
    [Documentation]    Generic keyword that executes the ${validation_keyword} and confirms if the returned state is different from the ${initial_result}
    ${current_result}    wait until keyword succeeds    3x    0ms    run keyword    ${retrieve_keyword}    @{retrieve_keyword_arguments}
    ${input_type}    Evaluate    type(${initial_result})
    ${output_type}    Evaluate    type(${current_result})
    should be equal    ${input_type}    ${output_type}    Data types for comparison dont match
    ${input_data}    convert to string    ${initial_result}
    ${output_data}    convert to string    ${current_result}
    should not match    ${input_data}    ${output_data}    State not different from previous one
    [Return]    ${current_result}

Wait until some change is detected after sending the specific key
    [Arguments]    ${key_to_send}    ${window_of_detection}    ${retrieve_keyword}    @{retrieve_keyword_arguments}
    [Documentation]    Sends the ${key_to_send} key(s) and attempts to detect whether the intended change was applied on the system, by
    ...    monitoring if the ${retrieve_keyword} returns the expected result
    ...    Input argument ${retrieve_keyword}) can be list type or string
    ${current_state}    wait until keyword succeeds    3x    0ms    run keyword    ${retrieve_keyword}    @{retrieve_keyword_arguments}
    wait until keyword succeeds    3x    100ms    I press    ${key_to_send}
    ${final_state}    wait until keyword succeeds    ${window_of_detection}    0ms    Execute keyword to check if states are different    ${current_state}    ${retrieve_keyword}
    ...    @{retrieve_keyword_arguments}
    [Return]    ${current_state}    ${final_state}

Initialize stability iteration test variables
    [Arguments]    ${iteration_count}
    [Documentation]    Initializes stability iteration test suite variables and '${TEST_ITERATION_COUNT}'
    ...    is set using argument '${iteration_count}'
    set suite variable    ${TEST_ITERATION_COUNT}    ${iteration_count}
    set suite variable    ${TEST_PASS_COUNT}    ${0}
    set suite variable    ${TEST_ITERATOR}    ${0}

Stability update current iteration report
    [Arguments]    ${is_current_iteration_passed}
    [Documentation]    Stability update current iteration report
    ...    Then sets ${TEST_ITERATOR} suite variable.
    ...    Pre-reqs: ${TEST_ITERATOR} and ${TEST_PASS_COUNT} variables should exist.
    variable should exist    ${TEST_ITERATOR}    Suite variable TEST_ITERATOR has not been set.
    variable should exist    ${TEST_PASS_COUNT}    Suite variable TEST_PASS_COUNT has not been set.
    run keyword unless    ${is_current_iteration_passed}    run keywords    Log    Iteration ${TEST_ITERATOR} failed    WARN
    ...    AND    embed screenshot in the robot framework report
    set suite variable    ${TEST_ITERATOR}    ${TEST_ITERATOR+1}
    run keyword if    ${is_current_iteration_passed}    set suite variable    ${TEST_PASS_COUNT}    ${TEST_PASS_COUNT+1}

Clear journalctl logs then remove core dump files from STB
    [Documentation]    Clears all data(logs and corefiles) from STB via serial.
    Clear all logs on STB via Serial
    Clear all core files on STB via Serial

Clear all core files on STB via Serial
    [Documentation]    Clear all corefiles from STB via serial
    Drop input buffer and verify response
    Send command and verify response    find ${COREDUMPSDIR} -type f -exec rm -f {} \\;

Get list of core files from the STB
    [Documentation]    Get the list of the core files from the STB
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}
    ${files}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    find ${COREDUMPSDIR} -name 'core.*[^(attempts)]' -type f
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    @{core_files}    Split To Lines    ${files}
    [Return]    @{core_files}

Retrieve module log from STB
    [Arguments]    ${ssh_handle}    ${module_name}
    [Documentation]    Retrieve module log from STB
    ...    Pre-reqs: ${STORAGE_PARTITION} variable should exist.
    variable should exist    ${STORAGE_PARTITION}    STORAGE_PARTITION variable was not saved.
    ${timestr}    robot.libraries.DateTime.get current date    result_format=%d%m%Y%H%M%S
    ${remote_file}    Set Variable    ${STORAGE_PARTITION}${module_name}_${timestr}.log
    ${local_file}    Set Variable    ${VALUESETNAME}_${timestr}_${module_name}.log
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    journalctl -b -u ${module_name} > ${remote_file}
    ${file_rcvd}    run keyword and return status    Remote.get    ${STB_IP}    ${ssh_handle}    ${remote_file}    ${local_file}
    Run Keyword If    ${file_rcvd} == ${False}    Log    Lgias logfile still on STB:${STB_IP}: ${remote_file}    WARN
    ...    ELSE    Run Keywords    Log    Lgias logfile on RemoteLibrary Location:${ADDRESS}: ${remote_file}    WARN
    ...    AND    Remote.execute_command    ${STB_IP}    ${ssh_handle}    rm -f ${remote_file}

Upload coredumps collected to S3
    [Arguments]    ${cpe_id}    ${build_name}    ${core_file_collection}
    [Documentation]    Upload corefiles collected to S3 bucket
    : FOR    ${core_file_details}    IN    @{core_file_collection}
    \    ${core_dir}    ${core_file}    split string from right    ${core_file_details.corefile}    /    1
    \    upload file to s3bucket    ${core_file_details.corefile}    ${build_name}/${cpe_id}/${core_file_details.app}/${core_file}

Collect and upload coredumps to S3
    [Documentation]    Collect and upload coredumps to S3 bucket
    ${cpe_id}    ${build}    ${core_files_copied}    Collect coredumps from STB
    Upload coredumps collected to S3    ${cpe_id}    ${build}    ${core_files_copied}

Check for kernel crash and upload to S3
    [Documentation]    Check for kernel crash and upload it to S3 after compressing it
    line will not match until timeout    ${SERIAL_PORT}    .*(Call Trace:|Kernel panic -|Modules linked in:).*    ${90}
    ${status}    run keyword and return status    verify serial response
    return from keyword if    ${status}    ${False}
    ${serial_log_file}    get serial log file path    ${SERIAL_PORT}
    run keyword if    "${serial_log_file}" == "${None}"    fail test    Serial logging not enabled
    ${log_file_name}    ${ext}    split string from right    ${serial_log_file}    .    1
    ${compressed_log_file}    set variable    ${log_file_name}.tar.gz
    ${files_to_compress}    create list    ${serial_log_file}
    compress file into gz    ${compressed_log_file}    ${files_to_compress}
    ${log_dir}    ${file_name}    split string from right    ${compressed_log_file}    /    1
    upload file to s3bucket    ${compressed_log_file}    ${VERSION}/${CPE_ID}/kernel_crash/${file_name}
    [Return]    ${True}

Restart UI by rebooting the STB for Stability
    [Documentation]    Restart the UI by rebooting STB for stability
    I reboot the STB
    I wait for 2 minutes
    Try to verify that FTI state is completed
    verify content is valid on the stb with all possible means

Press '${remote_key}' for '${repeat_num}' times then tune to '${channel_name}'
    [Documentation]    This Keyword presses ${remote_key} button for ${repeat_num} times, then returns to ${channel_name} and gets screenshot.
    : FOR    ${_}    IN RANGE    ${repeat_num}
    \    I Press    ${remote_key}
    \    I wait for 2 seconds
    I tune to stability test channel    ${channel_name}
    I wait for 2 seconds
    ${path}    get screenshot    ${STB_SLOT}

Make sure all recordings are eventually deleted
    [Documentation]    This keyword make sure that the recording are deleted successfully
    ...    Pre-reqs: ${TEST_ITERATOR} variable should exist.
    ${delete_api_status}    run keyword and return status    Reset All Recordings
    return from keyword if    ${delete_api_status}
    ${record_deletion_status}    run keyword and return status    There are no partial, completed, planned or current recordings on disk
    ${exists}    run keyword and return status    variable should exist    ${TEST_ITERATOR}
    ${log_msg}    set variable if    ${exists}    Reset All Recordings failed in ${TEST_ITERATOR}, but recordings were deleted from CPE    Reset All Recordings failed
    run keyword if    ${record_deletion_status}    Log    ${log_msg}    WARN
    should be true    ${record_deletion_status}    Reset All Recordings failed
