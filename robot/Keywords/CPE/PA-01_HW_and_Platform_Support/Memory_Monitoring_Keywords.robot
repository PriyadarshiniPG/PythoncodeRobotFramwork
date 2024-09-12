*** Settings ***
Documentation     Contains STB memory usage monitoring keywords
Resource          ../Common/Common.robot
Library           robot.libraries.DateTime

*** Variables ***
${MEMORY_MONITORING_METHOD}    PROCESS_USAGE
${MEMORY_MONITORING_INTERVAL}    90

*** Keywords ***
Get memory usage monitoring script name
    [Arguments]    ${memory_usage_type}
    [Documentation]    Get memory usage monitoring script name
    ${memory_monitor_script_name}    set variable if    '${memory_usage_type}' == 'PROCESS_USAGE' and ('${PLATFORM}'=='SMT-G7400' or '${PLATFORM}'=='SMT-G7401')    process_memory_usage_monitor_selene.sh    '${memory_usage_type}' == 'PROCESS_USAGE'    process_memory_usage_monitor.sh    '${memory_usage_type}' == 'CONTAINER_USAGE' and ('${PLATFORM}'=='DCX960' or '${PLATFORM}'=='EOS1008C')
    ...    lxc_memory_usage_bcm.sh    '${memory_usage_type}' == 'CONTAINER_USAGE' and ('${PLATFORM}'=='SMT-G7400' or '${PLATFORM}'=='SMT-G7401')    lxc_memory_usage_selene_swap.sh
    ${memory_monitor_script_output}    set variable if    '${memory_usage_type}' == 'PROCESS_USAGE'    memory_usage.log    '${memory_usage_type}' == 'CONTAINER_USAGE' and ('${PLATFORM}'=='DCX960' or '${PLATFORM}'=='EOS1008C')    memory_usage.csv    '${memory_usage_type}' == 'CONTAINER_USAGE' and ('${PLATFORM}'=='SMT-G7400' or '${PLATFORM}'=='SMT-G7401')
    ...    memory_usage.csv,memory_usage_with_swap.csv
    [Return]    ${memory_monitor_script_name}    ${memory_monitor_script_output}

Start memory monitoring on STB
    [Arguments]    ${memory_usage_type}=${MEMORY_MONITORING_METHOD}    ${capture_interval}=${MEMORY_MONITORING_INTERVAL}
    [Documentation]    Start memory monitoring on the STB by executing the known script in the background.
    ...    Pre-reqs: STB partition that will be used for saving output from monitoring scripts should be available as variable ${STORAGE_PARTITION}.
    ${memory_monitor_script_name}    ${memory_monitor_script_output}    Get memory usage monitoring script name    ${memory_usage_type}
    ${memory_monitor_script_path}    join path    Utils/stb_monitoring/memory_usage    ${memory_monitor_script_name}
    @{memory_usage_output_files}    split string    ${memory_monitor_script_output}    ,
    ${memory_monitor_script_output}    set variable    ${EMPTY}
    : FOR    ${usage_output_file}    IN    @{memory_usage_output_files}
    \    ${memory_monitor_script_output}    set variable    ${memory_monitor_script_output} ${STORAGE_PARTITION}${usage_output_file}
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}
    Remote.put    ${STB_IP}    ${ssh_handle}    ${memory_monitor_script_path}    ${STORAGE_PARTITION}
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    export LD_LIBRARY_PATH='/usr/security'; sed -i $'s/\\r$//' ${STORAGE_PARTITION}${memory_monitor_script_name}
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    export LD_LIBRARY_PATH='/usr/security'; nohup sh ${STORAGE_PARTITION}${memory_monitor_script_name} ${capture_interval} ${memory_monitor_script_output} > /dev/null 2>&1 &
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    Set suite variable    ${MEMORY_MONITORING_ENABLED}    ${True}

Stop memory monitoring on STB
    [Arguments]    ${memory_usage_type}=${MEMORY_MONITORING_METHOD}
    [Documentation]    Stop memory monitoring on the STB
    ...    Pre-reqs: STB partition that will be used for saving output from monitoring scripts should be available as variable ${STORAGE_PARTITION}.
    ${memory_monitor_root_dir}    create dir if not exists in rl    stb_monitoring_output/memory_usage
    ${memory_monitor_script_name}    ${memory_monitor_script_output}    Get memory usage monitoring script name    ${memory_usage_type}
    @{memory_usage_output_files}    split string    ${memory_monitor_script_output}    ,
    ${timestr}    robot.libraries.DateTime.get current date    result_format=%d%m%Y%H%M%S
    ${output_file_list}    create list
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    export LD_LIBRARY_PATH='/usr/security'; kill -15 `ps -ef | grep ${memory_monitor_script_name} | grep -v grep | awk '{ print $1 }'`
    : FOR    ${usage_output_file}    IN    @{memory_usage_output_files}
    \    ${local_file}    Set Variable    ${memory_monitor_root_dir}/${VALUESETNAME}_${timestr}_${usage_output_file}
    \    Remote.get    ${STB_IP}    ${ssh_handle}    ${STORAGE_PARTITION}${usage_output_file}    ${local_file}
    \    Remote.execute_command    ${STB_IP}    ${ssh_handle}    rm -f ${STORAGE_PARTITION}${usage_output_file} ${STORAGE_PARTITION}${memory_monitor_script_name}
    \    ${output_files}    Parse and plot memory usage from memory usage log    ${local_file}
    \    ${is_multiple_files}    run keyword and return status    Evaluate    type(${output_files}) == list
    \    run keyword if    ${is_multiple_files} == ${False}    append to list    ${output_file_list}    ${output_files}
    \    ...    ELSE    ${output_file_list}    set variable    ${output_files}
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    : FOR    ${memory_usage_file}    IN    @{output_file_list}
    \    ${filename}    Fetch From Right    ${memory_usage_file}    /
    \    ${status}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${memory_monitor_root_dir}/${filename}
    \    Run Keyword If    '${status}' == '${False}'    Get and save file from remote library    ${memory_usage_file}    ${memory_monitor_root_dir}
    Log    Memory usage output is available in ../${memory_monitor_root_dir}/    WARN
    Set suite variable    ${MEMORY_MONITORING_ENABLED}    ${False}

Parse and plot memory usage from memory usage log
    [Arguments]    ${memory_usage_file}
    [Documentation]    Parse memory usage from memory usage logs and plot the graphs
    ${file_name}    ${file_extension}    split string    ${memory_usage_file}    .
    return from keyword if    '${file_extension}' == 'csv'    ${memory_usage_file}
    ${parsed_csv}    parse memory usage from logs    ${memory_usage_file}
    ${graph_plotted}    plot memory usage graph    ${parsed_csv}
    ${regression_plotted}    plot memory regression    ${parsed_csv}
    Log    Memory usage graphs are available in: ${graph_plotted}    INFO
    Log    Memory regression graph is available in: ${regression_plotted}    INFO
    [Return]    ${parsed_csv}

Memory Usage Monitoring Suite Setup
    [Documentation]    This keyword contains the suite setup steps for running the memory usage monitoring test
    [Timeout]    ${DEFAULT_SUITE_SETUP_TIMEOUT}
    Default Suite Setup
    Start memory monitoring on STB

Memory Usage Monitoring Suite Teardown
    [Documentation]    This keyword contains the suite teardown steps for the memory usage monitoring test
    Stop memory monitoring on STB
    Default Suite Teardown

Surf through main features to capture memory usage
    [Arguments]    ${memory_usage_capture_interval}
    [Documentation]    Surf through main STB features to capture memory usage
    I tune to a free channel
    I long press UP for ${memory_usage_capture_interval/2} seconds
    I long press UP for ${memory_usage_capture_interval/2} seconds
    I long press DOWN for ${memory_usage_capture_interval/2} seconds
    I long press RIGHT for ${memory_usage_capture_interval/2} seconds
    I long press LEFT for ${memory_usage_capture_interval/2} seconds
    repeat keyword    ${memory_usage_capture_interval/2} times    I press a particular key every    500    UP
    repeat keyword    ${memory_usage_capture_interval/2} times    I press a particular key every    500    DOWN
    repeat keyword    ${memory_usage_capture_interval/2} times    I press a particular key every    500    LEFT
    repeat keyword    ${memory_usage_capture_interval/2} times    I press a particular key every    500    RIGHT
    repeat keyword    ${memory_usage_capture_interval} times    I press a particular key every    500    CHANNELUP
    repeat keyword    ${memory_usage_capture_interval} times    I press a particular key every    500    CHANNELDOWN
    I open Guide through Main Menu
    I long press UP for ${memory_usage_capture_interval/2} seconds
    I long press DOWN for ${memory_usage_capture_interval/2} seconds
    I long press RIGHT for ${memory_usage_capture_interval/2} seconds
    I long press LEFT for ${memory_usage_capture_interval/2} seconds
    repeat keyword    ${memory_usage_capture_interval} times    I press a particular key every    500    UP
    repeat keyword    ${memory_usage_capture_interval} times    I press a particular key every    500    DOWN
    repeat keyword    ${memory_usage_capture_interval} times    I press a particular key every    500    LEFT
    repeat keyword    ${memory_usage_capture_interval} times    I press a particular key every    500    RIGHT
    I open On Demand through Main Menu
    repeat keyword    ${memory_usage_capture_interval} times    I press a particular key every    1000    LEFT
    repeat keyword    ${memory_usage_capture_interval} times    I press a particular key every    1000    RIGHT
    I press    DOWN
    repeat keyword    ${memory_usage_capture_interval} times    I press a particular key every    500    RIGHT
    I press    DOWN
    repeat keyword    ${memory_usage_capture_interval} times    I press a particular key every    500    LEFT
    I press    DOWN
    repeat keyword    ${memory_usage_capture_interval} times    I press a particular key every    500    RIGHT
    I open YouTube app
    repeat keyword    ${memory_usage_capture_interval/2} times    I press a particular key every    1000    DOWN
    repeat keyword    ${memory_usage_capture_interval/2} times    I press a particular key every    1000    UP
    I press a particular key every    2000    DOWN
    I press a particular key every    500    OK
    I wait for ${memory_usage_capture_interval*2} seconds
    I press a particular key every    5000    CHANNELUP
