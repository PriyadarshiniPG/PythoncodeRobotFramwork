*** Settings ***
Documentation     Keywords supporting debugging process
Library           robot.libraries.DateTime

*** Keywords ***
capture open files list for investigation
    [Arguments]    ${output_file}
    [Documentation]    Capture open files list for debugging purposes
    ${files}    get open file names
    ${files_str}    set variable    ${EMPTY}
    : FOR    ${file_name}    IN    @{files}
    \    ${files_str}    Catenate    SEPARATOR=\n    ${files_str}    ${file_name}
    Create File    ${OUTPUT_DIR}\\${output_file}    ${files_str}
    should not be empty    ${OUTPUT_DIR}\\${output_file}    Open files list not saved

Embed json state in the robot framework report
    [Arguments]    ${log_url}
    [Documentation]    This keyword adds json state from the STB to the RF report.
    Log    <a href="${log_url}">Click here for json state</a>    HTML

Embed screenshot in the robot framework report
    [Arguments]    ${log_url}
    [Documentation]    This keyword adds screenshot from the STB to the RF report.
    Log    <a href="${log_url}">Click here for screenshot</a>    HTML

Embed channel lineup in the robot framework report
    [Arguments]    ${log_url}
    [Documentation]    This keyword adds channel lineup from the STB to the RF report
    Log    <a href="${log_url}">Click here for Channel lineup</a>    HTML

Embed Test variables in the robot framework report
    [Arguments]    ${log_url}
    [Documentation]    This keyword adds test variables to the RF report.
    Log    <a href="${log_url}">Click here for Test Variables file</a>    HTML

Retrieve log archive from remote library
    [Documentation]    Retrieve log archive from remote library location and return log path
    # For Stability tests, the file is ${VALUESETNAME}/log.zip, and for others, the file is existing on a remote server.
    ${report_location}    join path    ${OUTPUT_DIR}    ..    ..
    ${local_current_path}    join path    ${VALUESETNAME}    log.zip
    ${time_str}    robot.libraries.DateTime.get current date    result_format=%d%m%Y%H%M%S
    ${local_path}    join path    ${report_location}    ${VALUESETNAME}_${time_str}.zip
    run keyword if    ${IS_STABILITY_TEST}    move file    ${local_current_path}    ${local_path}
    ...    ELSE    Get and save file from remote library    ${VALUESETNAME}/log.zip    ${local_path}
    [Return]    ${VALUESETNAME}_${time_str}.zip

Retrieve all journal logs from STB
    [Documentation]    Retrieve all journal logs, including state information from STB
    Run Keyword If    ${COLLECT_LOGS}    Collect all journal logs from STB

Collect all journal logs from STB
    [Documentation]    Retrieve all journal logs, including state information from STB
    ${stdout}    ${stderror}    ${log_name}    extract logs from stb to remote library location    ${VALUESETNAME}    ${STB_IP}
    should match    ${log_name}    log.zip    Extracted zip file is not matching expected name
    ${log_path}    Retrieve log archive from remote library
    log    <a href="${log_path}">Click here for logs</a>    HTML

wait until remote files remain unchanged
    [Arguments]    ${ssh_handle}    @{files_to_monitor}
    [Documentation]    Wait until all file sizes remain constant upto a decent time limit of ${REMOTE_FILES_MONITOR_WINDOW} seconds.
    ...    Any change will be detected upto ${REMOTE_FILES_CHANGE_DETECT_WINDOW} seconds
    ${files_str}    Catenate    SEPARATOR=    @{files_to_monitor}
    ${initial_sizes}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    ls -l ${files_str} | awk '{print $9" "$5}'| sort -u
    ${initial_size_str}    Replace String Using Regexp    ${initial_sizes}    (\n|\r|\t)    ${SPACE}
    ${fixed_time_counter}    set variable    ${0}
    : FOR    ${count}    IN RANGE    ${REMOTE_FILES_MONITOR_WINDOW}
    \    sleep    1s
    \    ${file_sizes}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    ls -l ${files_str} | awk '{print $9" "$5}'| sort -u
    \    ${file_sizes_str}    Replace String Using Regexp    ${file_sizes}    (\n|\r|\t)    ${SPACE}
    \    ${initial_file_size}    set variable if    '${file_sizes_str}'!='${initial_size_str}'    ${file_sizes_str}    ${initial_size_str}
    \    ${fixed_time_counter}    set variable if    '${file_sizes_str}'!='${initial_size_str}'    ${0}    ${fixed_time_counter+1}
    \    return from keyword if    ${REMOTE_FILES_CHANGE_DETECT_WINDOW}==${fixed_time_counter}    ${fixed_time_counter}
    fail test    Maximum wait time reached and files are still being updated

Get and save file from remote library
    [Arguments]    ${remote_file_path}    ${destination_path}
    [Documentation]    Get and save file from remote library to the pabot client machine
    get and save encoded binary file from remote library    ${remote_file_path}    ${destination_path}
    [Return]    ${destination_path}

get and save encoded binary file from remote library
    [Arguments]    ${remote_file_path}    ${destination_file_path}
    [Documentation]    Get and save base64 encoded file from remote library to the pabot client machine
    ${returned_file_contents}    get file from remote library    ${remote_file_path}
    ${decoded_file_contents}    evaluate    base64.b64decode('${returned_file_contents}')    Keywords=base64
    create binary file    ${destination_file_path}    ${decoded_file_contents}

I query screenshot from stb via as
    [Documentation]    Take screenshot and set LAST_SCREESHOT_PATH variable
    ${LAST_SCREENSHOT_PATH}    Get screenshot by debug tools    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    Set Global Variable    ${LAST_SCREENSHOT_PATH}

I query screenshot from stb via Obelix
    [Documentation]    Take screenshot from Obelix and set LAST_SCREESHOT_PATH variable
    ${LAST_SCREENSHOT_PATH}    get screenshot    ${STB_SLOT}
    Set Global Variable    ${LAST_SCREENSHOT_PATH}

Capture screenshot and json
    [Documentation]    This keyword captures both json and screenshot from the box
    I query screenshot from stb via Obelix
    ${json}    Get Ui Json
    ${json}    convert to string    ${json}
    Create File    ${OUTPUT_DIR}\\teardown_dump.json    ${json}
    should not be empty    ${LAST_SCREENSHOT_PATH}    Screenshot not saved

Mount branch
    [Documentation]    Mounts the UI code into a stb in a local environment
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}    ${username}    ${password}
    ${lan_pc_ip}    get lan pc ip    ${RACK_SLOT_ID}
    ${nfs_used_ip}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    mount | grep -Eo "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:.*$" | awk -F ":" ' {print $1}'
    ${mount_branch}    Evaluate    True if "${nfs_used_ip}" == "" else False
    run keyword if    ${mount_branch} == ${True}    Run keywords    Remote.execute_command    ${STB_IP}    ${ssh_handle}    /usr/sbin/iptables -P INPUT ACCEPT && /usr/sbin/iptables -P OUTPUT ACCEPT && /usr/sbin/iptables -P FORWARD ACCEPT && /usr/sbin/iptables -F
    ...    AND    Remote.execute_command    ${STB_IP}    ${ssh_handle}    mounted=`/usr/sbin/showmount -e ${lan_pc_ip} | grep "/" | awk 'NR==1{print $1}'` && systemctl stop jsapp && mount -o nolock ${lan_pc_ip}:$mounted /usr/share/lgioui && chmod +x /usr/share/lgioui/run.sh && systemctl start jsapp
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    Sleep    45 sec
    Wait Until Keyword Succeeds    6 min    10 s    Get Ui Json

Embed configuration file in the robot framework report
    [Arguments]    ${log_url}
    [Documentation]    This keyword adds configuration file from the STB to the RF report.
    Log    <a href="${log_url}">Click here for STB configuration</a>    HTML

Capture test variables for investigation
    [Arguments]    ${destination_path}    ${is_functional_rack}
    [Documentation]    This keyword captures test variables for investigation
    ${variables_dict}    Get Variables
    ${variables_file}    Set variable    ${EMPTY}
    : FOR    ${variable_key}    IN    @{variables_dict}
    \    ${variable_value}    Get from dictionary    ${variables_dict}    ${variable_key}
    \    ${variables_file}    Catenate    ${variables_file}    ${variable_key}    ${variable_value}    ${\n}
    run keyword if     ${is_functional_rack} == ${False}    create binary file    ${destination_path}    ${variables_file}
    ...    ELSE    create file in rl    ${destination_path}    ${variables_file}

Capture json state for investigation
    [Arguments]    ${destination_path}    ${is_functional_rack}
    [Documentation]    Capture json state to see the state of the box when test is failed
    ${json}    Get Ui Json
    ${json}    evaluate    json.dumps(${json}, indent=${4})    Keywords=json
    run keyword if     ${is_functional_rack} == ${False}    create binary file    ${destination_path}    ${json}
    ...    ELSE    create file in rl    ${destination_path}    ${json}

Capture channel lineup for investigation
    [Arguments]    ${destination_path}    ${is_functional_rack}
    [Documentation]    Capture channel lineup from STB for investigation
    ${channels}    get channel lineup via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${channels}    evaluate    json.dumps(${channels}, indent=${4})    Keywords=json
    run keyword if     ${is_functional_rack} == ${False}    create binary file    ${destination_path}    ${channels}
    ...    ELSE    create file in rl    ${destination_path}    ${channels}

Capture configuration data for investigation
    [Arguments]    ${destination_path}    ${is_functional_rack}
    [Documentation]    Capture configuration data from STB for investigation
    ${config_data}    get configuration via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${config_data}    evaluate    json.dumps(${config_data}, indent=${4})    Keywords=json
    run keyword if     ${is_functional_rack} == ${False}    create binary file    ${destination_path}    ${config_data}
    ...    ELSE    create file in rl    ${destination_path}    ${config_data}
