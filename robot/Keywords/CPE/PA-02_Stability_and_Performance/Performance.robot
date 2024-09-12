*** Settings ***
Documentation     Stability keyword definitions
Resource          ../Common/Stbinterface.robot

*** Variables ***
${TS_ID_PERFORMANCE}    TUNING_PERFORMANCE_TS46
${STABIITY_VSM_USER}    ayush_singhal01
${STABILITY_VSM_PASSWORD}    Ayush@123
${LOCAL_TDI_PATH}    ./TDI/
${HDD_PERFORMANCE_ROUNDS}    100
${HDD_PERFORMANCE_TMP_FILE}    _hdd_tmp_file
${HDD_PERFORMANCE_BLOCKSIZE}    4M
${HDD_PERFORMANCE_IOENGINE}    libaio
${HDD_PERFORMANCE_TEST_FILE_SIZE}    9G
${HDD_PERFORMANCE_DIRECT}    1
${HDD_PERFORMANCE_FALLOCATE}    1
${HDD_PERFORMANCE_TIMEOUT}    ${1000}

*** Keywords ***
Enable tdi trace for channel zap performance
    [Documentation]    This keyword runs commands to enable tdi tracer for key press (irmgr) and 1st_picture_ready (rmfstreamer) events.
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}    ${username}    ${password}
    Remote.execute command    ${STB_IP}    ${ssh_handle}    systemctl start td@irmgr
    Remote.execute command    ${STB_IP}    ${ssh_handle}    systemctl start td@rmfstreamer
    Remote.execute command    ${STB_IP}    ${ssh_handle}    systemctl daemon-reload
    I wait for 10 seconds
    Remote.execute command    ${STB_IP}    ${ssh_handle}    sync
    I wait for 10 seconds
    Remote.close connection    ${STB_IP}    ${ssh_handle}

Disable tdi trace for channel zap performance
    [Documentation]    This keyword runs commands to disable tdi tracer for key press (irmgr) and 1st_picture_ready (rmfstreamer) events.
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}    ${username}    ${password}
    Remote.execute command    ${STB_IP}    ${ssh_handle}    systemctl stop td@irmgr
    Remote.execute command    ${STB_IP}    ${ssh_handle}    systemctl stop td@rmfstreamer
    Remote.execute command    ${STB_IP}    ${ssh_handle}    systemctl daemon-reload
    I wait for 5 seconds
    Remote.execute command    ${STB_IP}    ${ssh_handle}    sync
    I wait for 10 seconds
    Remote.close connection    ${STB_IP}    ${ssh_handle}

There is a channelzap performance test stream with configuration
    [Arguments]    ${dcom_config}
    [Documentation]    This keyword loads vsm lineup configuration.
    load vsm configuration    ${STABIITY_VSM_USER}    ${STABILITY_VSM_PASSWORD}    ${TS_ID_PERFORMANCE}    ${dcom_config}
    I wait for 20 seconds

Acquire Performance Test Stream Player
    [Documentation]    This keyword locks performance stream player.
    Acquire Lock    PERFORMANACESTREAM_Lock

Release Performance Test Stream Player
    [Documentation]    This keyword releases performance stream player.
    Release Lock    PERFORMANACESTREAM_Lock

I tune to channelzap performance test channel
    [Arguments]    ${channel_number}
    [Documentation]    This keyword tunes to the specified channel number.
    I tune to channel    ${channel_number}

generate tdi logs
    [Arguments]    ${ssh_handle}
    [Documentation]    This keyword runs commands to dump tdi stats into ${jiraid}_${VERSION}_${TYPE}.tdi file on STB.
    ${jiraid}    Get JiraID
    Remote.execute command    ${STB_IP}    ${ssh_handle}    tdistat
    Remote.execute command    ${STB_IP}    ${ssh_handle}    tdidump > /tmp/${jiraid}_${VERSION}_${TYPE}.tdi
    [Return]    ${jiraid}_${VERSION}_${TYPE}.tdi

tdi logs generated
    [Documentation]    This keyword runs commands to dump tdi stats into file on STB and copies this file to PC ${LOCAL_TDI_PATH}.
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}
    ${tdi_file}    generate tdi logs    ${ssh_handle}
    ${is_directory_absent}    Run Keyword And Return Status    OperatingSystem.Directory Should Not Exist    ${LOCAL_TDI_PATH}
    run keyword if    ${is_directory_absent}    Create Directory    ${LOCAL_TDI_PATH}
    Remote.get    ${STB_IP}    ${ssh_handle}    /tmp/${tdi_file}    ${LOCAL_TDI_PATH}
    Remote.close connection    ${STB_IP}    ${ssh_handle}

I perform a tuning cycle '${cycle_hops}' times
    [Documentation]    This keyword performs specified number ${cycle_hops} of CHANNELDOWN hops.
    : FOR    ${_}    IN RANGE    1    ${cycle_hops}
    \    I Press    CHANNELUP
    \    I wait for 5 seconds

I perform a tuning cycle '${cycle_hops}' times from channel '${channel_number}'
    [Documentation]    This keyword performs ${cycle_hops} * tuning cycle 7 times, then tunes to ${channel_number}.
    : FOR    ${_}    IN RANGE    0    ${cycle_hops}
    \    I perform a tuning cycle '7' times
    \    I tune to channel    ${channel_number}
    \    I wait for 5 seconds

Perform channelup '${repeat_num}' times
    [Documentation]    This keyword performs specified number ${repeat_num} of CHANNELUP hops.
    : FOR    ${_}    IN RANGE    0    ${repeat_num}
    \    I Press    CHANNELUP
    \    I wait for 5 seconds

Perform channeldown '${repeat_num}' times
    [Documentation]    This keyword performs specified number ${repeat_num} of CHANNELDOWN hops.
    : FOR    ${_}    IN RANGE    0    ${repeat_num}
    \    I Press    CHANNELDOWN
    \    I wait for 5 seconds

DCA_INTRA channel swap
    [Documentation]    This keyword performs direct channel tune between channels within the same transponder.
    I tune to channel    957
    I wait for 5 seconds
    I tune to channel    950
    I wait for 5 seconds

DCA_INTER channel swap
    [Documentation]    This keyword performs direct channel tune between channels of different transponders.
    I tune to channel    956
    I wait for 5 seconds
    I tune to channel    949
    I wait for 5 seconds

I perform a tuning cycle '${cycle_hops}' times for CH_INTER
    [Documentation]    This keyword performs CHANNELDOWN then CHANNELUP, ${cycle_hops} * 7 times.
    ${cycle_hops}    evaluate    ${cycle_hops} * ${7}
    : FOR    ${_}    IN RANGE    0    ${cycle_hops}
    \    I wait for 5 seconds
    \    I Press    CHANNELDOWN
    \    I wait for 5 seconds
    \    I Press    CHANNELUP

I perform a tuning cycle '${cycle_hops}' times for CH_INTRA
    [Documentation]    This keyword performs channel up 7 times then channel down 7 times for ${cycle_hops} times.
    : FOR    ${_}    IN RANGE    0    ${cycle_hops}
    \    I wait for 5 seconds
    \    Perform channelup '7' times
    \    Perform channeldown '7' times

I perform a tuning cycle '${cycle_hops}' times for DCA_INTRA
    [Documentation]    This keyword performs 7 times direct channel tune between channels within the same transponder. It does this ${cycle_hops} times.
    I wait for 5 seconds
    : FOR    ${_}    IN RANGE    0    ${cycle_hops}
    \    repeat keyword    7 times    DCA_INTRA channel swap

I perform a tuning cycle '${cycle_hops}' times for DCA_INTER
    [Documentation]    This keyword performs 7 times direct channel tune between channels within different transponders. It does this ${cycle_hops} times.
    I wait for 5 seconds
    : FOR    ${_}    IN RANGE    0    ${cycle_hops}
    \    repeat keyword    7 times    DCA_INTER channel swap

I perform HDD performance benchmark for io pattern
    [Arguments]    ${io_pattern}    ${ioengine}=${HDD_PERFORMANCE_IOENGINE}    ${size}=${HDD_PERFORMANCE_TEST_FILE_SIZE}    ${blocks}=${HDD_PERFORMANCE_BLOCKSIZE}    ${tmp_file}=${HDD_PERFORMANCE_TMP_FILE}    ${direct}=${HDD_PERFORMANCE_DIRECT}
    ...    ${fallocate}=${HDD_PERFORMANCE_FALLOCATE}    ${timeout}=${HDD_PERFORMANCE_TIMEOUT}
    [Documentation]    This keyword performs HDD performance bechmark for ${io_pattern}(read or write) using fio tool.
    ...    Pre-reqs: ${STORAGE_PARTITION} variable should exist.
    Variable should exist    ${STORAGE_PARTITION}    Storage variable ${STORAGE_PARTITION} has not been set.
    ${csv_file}    Set Variable    ${io_pattern}${tmp_file}.csv
    ${hdd_io_pattern_root_dir}    create dir if not exists in rl    stb_monitoring_output/hdd
    ${timestr}    robot.libraries.DateTime.get current date    result_format=%d%m%Y%H%M%S
    ${local_file}    Set Variable    ${hdd_io_pattern_root_dir}/${VALUESETNAME}_${timestr}_${csv_file}
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    echo "usr_cpu(%),sys_cpu(%),latency(us),disk_util(%),disk_usage(%)" >> ${STORAGE_PARTITION}${csv_file}
    ${awk_command_for_fio}    Set Variable    awk -F";" '{printf "%d,%d,", $88, $89; if ($40 == 0) printf "%d,%d", $81, $NF; else printf "%d,%d", $40, $NF}'
    : FOR    ${i}    IN RANGE    ${HDD_PERFORMANCE_ROUNDS}
    \    Remote.execute_command    ${STB_IP}    ${ssh_handle}    fio --name=hdd_test --filename=${STORAGE_PARTITION}${i}.${io_pattern}${tmp_file} --blocksize=${blocks} --ioengine=${ioengine} --size=${size} --direct=${direct} --fallocate=${fallocate} --rw=rand${io_pattern} --output-format=terse | ${awk_command_for_fio} >> ${STORAGE_PARTITION}${csv_file}    timeout=${timeout}
    \    Remote.execute_command    ${STB_IP}    ${ssh_handle}    df ${STORAGE_PARTITION} | awk 'FNR==2{ print "," $5 }' | sed 's/%//' >> ${STORAGE_PARTITION}${csv_file}
    Remote.get    ${STB_IP}    ${ssh_handle}    ${STORAGE_PARTITION}${csv_file}    ${local_file}
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    ${hdd_performance_plotted}    plot graph    ${local_file}    disk_usage(%)    latency(us)
    Log    HDD ${io_pattern} graph is available in: ${hdd_performance_plotted}    INFO

I check that fio tool is installed on STB
    [Documentation]    This keyword checks that fio tool is installed on STB.
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}
    ${result}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    type fio
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    Should not be equal as strings    ${result}    fio: not found    Failed:fio tool should be installed but it's not.
