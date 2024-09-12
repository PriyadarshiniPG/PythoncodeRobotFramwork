*** Settings ***
Documentation     Contains STB Monitoring keywords definitions

*** Variables ***
${PS_MONITORING_INTERVAL}    300
${PS_MONITORING_SCRIPT_NAME}    retrieve_processes.sh
${PS_MONITORING_LOG_NAME}    ps.log

*** Keywords ***
Start Running Process monitoring
    [Arguments]    ${script_name}=${PS_MONITORING_SCRIPT_NAME}    ${capture_interval}=${PS_MONITORING_INTERVAL}    ${log_name}=${PS_MONITORING_LOG_NAME}
    [Documentation]    Start Running Process monitoring on the STB by executing the known script in the background.
    ...    Pre-reqs: STB partition that will be used for saving output from monitoring scripts should be available as variable ${STORAGE_PARTITION}.
    ${retrieve_processes_script_path}    join path    Utils/stb_monitoring/process_status_monitoring    ${script_name}
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}
    Remote.put    ${STB_IP}    ${ssh_handle}    ${retrieve_processes_script_path}    ${STORAGE_PARTITION}
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    export LD_LIBRARY_PATH='/usr/security'; sed -i $'s/\\r$//' ${STORAGE_PARTITION}${script_name}
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    export LD_LIBRARY_PATH='/usr/security'; nohup sh ${STORAGE_PARTITION}${script_name} ${capture_interval} ${STORAGE_PARTITION}${log_name} > /dev/null 2>&1 &
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    Set suite variable    ${PROCESS_MONITORING_ENABLED}    ${True}

Stop Running Process monitoring
    [Arguments]    ${script_name}=${PS_MONITORING_SCRIPT_NAME}    ${log_name}=${PS_MONITORING_LOG_NAME}
    [Documentation]    Stop Running Process monitoring on the STB.
    ...    Pre-reqs: 'Start Running Process monitoring' keyword should be initiated previously.
    ...    Pre-reqs: STB partition that will be used for saving output from monitoring scripts should be available as variable ${STORAGE_PARTITION}.
    ${ps_monitor_root_dir}    create dir if not exists in rl    stb_monitoring_output/ps_monitor_logs
    ${timestr}    robot.libraries.DateTime.get current date    result_format=%d%m%Y%H%M%S
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    export LD_LIBRARY_PATH='/usr/security'; kill -15 `ps -ef | grep ${script_name} | grep -v grep | awk '{ print $1 }'`
    ${local_file}    Set Variable    ${ps_monitor_root_dir}/${VALUESETNAME}_${timestr}_${log_name}
    Remote.get    ${STB_IP}    ${ssh_handle}    ${STORAGE_PARTITION}${log_name}    ${local_file}
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    rm -f ${STORAGE_PARTITION}${log_name} ${STORAGE_PARTITION}${script_name}
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    Set suite variable    ${PROCESS_MONITORING_ENABLED}    ${False}
    Log    Processes status output is available in ../${ps_monitor_root_dir}/    WARN
