*** Settings ***
Documentation     contain Platform based keywords
Resource          ../Common/Common.robot

*** Variables ***
${UnknownChannelName}    YYYYYY
${UnknownChannelIPKey}    NNNN
${JOURNAL_LINE_COUNT_TO_MATCH_RB_SOLUTION}    5000
${IS_SELENE_SWITCH_IMAGE}    ${False}

*** Keywords ***
monitor serial console for traces of box reboot
    [Arguments]    ${wait_duration}
    [Documentation]    monitor serial traces for signs of box rebooting over the specified duration
    ${reboot_string}    get reboot string for the platform    ${PLATFORM}
    ${status}    ${matching_line}    run keyword and ignore error    Wait for Serial line    ${reboot_string}    ${wait_duration}
    Should match    ${status}    FAIL    Reboot sequence found, box is unstable

Probe Channels and Get Screenshots for analysis
    [Documentation]    Keyword to get query all known channels and get properties to dump to output.xml and run diagnostics later.
    @{chList}    Create List
    Append To List    ${chList}    10
    Append To List    ${chList}    101
    Append To List    ${chList}    301
    Append To List    ${chList}    302
    Append To List    ${chList}    303
    Append To List    ${chList}    36
    Append To List    ${chList}    37
    Append To List    ${chList}    401
    Append To List    ${chList}    405
    Append To List    ${chList}    48
    Append To List    ${chList}    501
    Append To List    ${chList}    521
    Append To List    ${chList}    615
    Append To List    ${chList}    67
    Append To List    ${chList}    671
    Append To List    ${chList}    68
    Append To List    ${chList}    751
    Append To List    ${chList}    761
    Append To List    ${chList}    763
    Append To List    ${chList}    772
    Append To List    ${chList}    775
    Append To List    ${chList}    783
    Append To List    ${chList}    823
    Append To List    ${chList}    825
    Append To List    ${chList}    83
    Append To List    ${chList}    9
    Append To List    ${chList}    807
    Append To List    ${chList}    536
    Append To List    ${chList}    608
    Append To List    ${chList}    47
    Append To List    ${chList}    502
    Append To List    ${chList}    312
    ${length}    Get Length    ${chList}
    ${traxis_channel_lineup_xml}    get traxis channel lineup    ${CPE_ID}
    ${lineup_xml}=    Evaluate    "".join(${traxis_channel_lineup_xml})
    tune to channels in the provided list and get channel properties for validation    ${lineup_xml}    ${length}    @{chList}
    tune to channels in lineup and get channel properties for validation    ${lineup_xml}    400

tune to specific channel and run probe keywords
    [Arguments]    ${traxis_channel_lineup_xml}    ${channel_number}
    [Documentation]    tune to channel and retrieve properties for future validation
    I tune to stability test channel    ${channel_number}
    Sleep    3s
#    ${is_video_playing}    is video playing    ${STB_SLOT}
#    ${is_black_screen}    is black screen    ${STB_SLOT}
    ${is_video_playing}    Run keyword if    '${OBELIX}' == 'True'    Run Keywords    video playing
    ...    AND    audio playing
    ...    ELSE    Log    OBELIX variable set to False, skipping content check    WARN
    ${is_black_screen}    Run keyword if    '${OBELIX}' == 'True'    is black screen    ${STB_SLOT}
    ...    ELSE    Log    OBELIX variable set to False, skipping is black screen content check    WARN
    ${channelId}    Get Current Channel
    ${tmpchannelLCN}    get channel lcn from id    ${traxis_channel_lineup_xml}    ${channelId}
    ${status}    ${ch_name}    run keyword and ignore error    get channel name    ${traxis_channel_lineup_xml}    ${tmpchannelLCN}
    ${path}    get screenshot    ${STB_SLOT}
    run keyword if    '${status}' == 'PASS'    Log    "CHPROBE|${channel_number}|${channelId}|${tmpchannelLCN}|chName:${ch_name}|${is_video_playing}|${is_black_screen}|${path}"
    ...    ELSE    Log    "CHPROBE|${channel_number}|${channelId}|${tmpchannelLCN}|${UnknownChannelName}|${is_video_playing}|${is_black_screen}|${path}"

tune to channels in the provided list and get channel properties for validation
    [Arguments]    ${traxis_channel_lineup_xml}    ${length}    @{channel_list}
    [Documentation]    tune to channels in the provided list and retrieve properties for future validation
    : FOR    ${element}    IN RANGE    ${0}    ${length}
    \    tune to specific channel and run probe keywords    ${traxis_channel_lineup_xml}    ${channel_list[${element}]}

tune to next channel and run probe keywords
    [Arguments]    ${xml_}    ${ch_key}
    [Documentation]    tune to next channel and retrieve properties for future validation
    Press key    ${ch_key}
    Sleep    3s
    #${is_video_playing}    is video playing    ${STB_SLOT}
    ${is_video_playing}    Run keyword if    '${OBELIX}' == 'True'    Run Keywords    video playing
    ...    AND    audio playing
    ...    ELSE    Log    OBELIX variable set to False, skipping content check    WARN
    ${is_black_screen}    Run keyword if    '${OBELIX}' == 'True'    is black screen    ${STB_SLOT}
    ...    ELSE    Log    OBELIX variable set to False, skipping is black screen content check    WARN
    ${channelId}    Get Current Channel
    ${tmpchannelLCN}    get channel lcn from id    ${xml_}    ${channelId}
    ${status}    ${ch_name}    run keyword and ignore error    get channel name    ${xml_}    ${tmpchannelLCN}
    ${path}    get screenshot    ${STB_SLOT}
    run keyword if    '${status}' == 'PASS'    Log    "CHPROBE|${UnknownChannelIPKey}|${channelId}|${tmpchannelLCN}|${ch_name}|${is_video_playing}|${is_black_screen}|${path}"
    ...    ELSE    Log    "CHPROBE|${UnknownChannelIPKey}|${channelId}|${tmpchannelLCN}|${UnknownChannelName}|${is_video_playing}|${is_black_screen}|${path}"

tune to channels in lineup and get channel properties for validation
    [Arguments]    ${xml_}    ${lineup_count}
    [Documentation]    tune to channels in the provided list and retrieve properties for future validation
    repeat keyword    ${lineup_count} times    tune to next channel and run probe keywords    ${xml_}    CHANNELUP

Flash new build and bring up STB
    [Documentation]    Flash the new build and bring up the stb
    Run Keyword Unless    '${VERSION}' == 'DoNotUpgrade'    Make sure that STB is running with given version
    wait until keyword succeeds    3x    1s    Make sure that STB is not in standby

get device mount status
    [Arguments]    ${device}    ${ssh_handle}
    [Documentation]    Check if a specific device is mounted on the platform
    ${count}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    mount | grep 'on \/media\/${device}' | wc -l
    ${is_mounted}    set variable if    '${count}'>'${0}'    ${True}    ${False}
    [Return]    ${is_mounted}

verify serial console is active
    [Documentation]    Check if serial console works properly
    drop input buffer and send command    echo TEST
    Wait until line match and verify response    .*echo TEST.*    ${30}
    Wait until line match and verify response    .*TEST.*    ${30}

Get device storage type
    [Documentation]    This keyword returns the type of storage used in the device either HDD or CLOUD
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}
    ${count}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    mount | grep 'on \/media\/hdd' | wc -l
    ${hdd_mount_status}    set variable if    '${count}'>'${1}'    ${True}    ${False}
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    ${storage_type}    set variable if    ${hdd_mount_status}==${True}    HDD    CLOUD
    [Return]    ${storage_type}

Get Review Buffer hardware solution
    [Documentation]    This keyword returns the Review Buffer hardware solution available for the device
    ...    Precondition: You should have displayed the Review Buffer player within 20 seconds
    ...    because only a small number of lines of journal logs are read
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}
    ${query_result}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    journalctl -n '${JOURNAL_LINE_COUNT_TO_MATCH_RB_SOLUTION}' | grep -i "RAMToCloud"
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    ${buffer_solution}    set variable if    'RAMToCloud' in '''${query_result}'''    CLOUD    HDD
    [Return]    ${buffer_solution}

I verify the STB is HDD less
    [Documentation]    This keyword verifies that the STB is HDD less
    ${storage_type}    Get device storage type
    ${status}    set variable if    '${storage_type}'=='CLOUD'    ${True}    ${False}
    should be true    ${status}    Connected to a STB with HDD

The Review Buffer hardware solution is cloud
    [Documentation]    This keyword verifies if the system has a cloud Review Buffer solution
    ...    Precondition: You should have displayed the Review Buffer player within 20 seconds
    ...    because only a small number of lines of journal logs are read
    ${buffer_solution}    Get Review Buffer hardware solution
    ${is_cloud}    set variable if    '${buffer_solution}'=='CLOUD'    ${True}    ${False}
    should be true    ${is_cloud}    The system is having a HDD Review Buffer solution

I verify the STB has a HDD
    [Documentation]    This keyword verifies that the STB has a HDD
    ${storage_type}    Get device storage type
    ${status}    set variable if    '${storage_type}'=='HDD'    ${True}    ${False}
    should be true    ${status}    Connected to a HDD less STB

The Review Buffer hardware solution is local HDD
    [Documentation]    This keyword verifies if the system has a local HDD Review Buffer solution
    ...    Precondition: You should have displayed the Review Buffer player within 20 seconds
    ...    because only a small number of lines of journal logs are read
    ${buffer_solution}    Get Review Buffer hardware solution
    ${is_hdd}    set variable if    '${buffer_solution}'=='HDD'    ${True}    ${False}
    should be true    ${is_hdd}    The system is having a CLOUD Review Buffer solution

Get selene platform specific service list
    [Documentation]    Get list of selene platform
    @{service_list}    run keyword if    ${IS_SELENE_SWITCH_IMAGE} == ${False}    create list    axact    dbus    dibbler
    ...    dnsmasq    dsmgr    fanctrl    iarmbusd    irmgr    jsapp
    ...    lgias    mfrmgr    nginx    nginxcfg    om-netconfig    pwrmgr
    ...    rmfstreamer    slauncher    sysmgr    systemd-tmpfiles-setup    tz-update    westeros
    ...    ELSE    create list    dbus    dibbler    dnsmasq    dsmgr
    ...    fanctrl    iarmbusd    irmgr    mfrmgr    om-netconfig    pwrmgr
    ...    sysmgr    systemd-tmpfiles-setup    tz-update
    [Return]    ${service_list}

Check the given services are active
    [Arguments]    ${service_list}
    [Documentation]    Validate the list of services are active and return inactive service list
    @{inactive_services}    create list
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    wait until keyword succeeds    3x    2s    Remote.login    ${STB_IP}    ${ssh_handle}
    : FOR    ${service}    IN    @{service_list}
    \    ${output}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    systemctl is-active ${service}
    \    run keyword if    "${output}" != "active"    Append To List    ${inactive_services}    ${service}
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    [Return]    ${inactive_services}

Verify box is not in degraded mode
    [Documentation]    Verify the box is not in degraded mode
    run keyword if    ('${PLATFORM}'=='SMT-G7401' or '${PLATFORM}'=='SMT-G7400') and ${IS_SELENE_SWITCH_IMAGE} == ${True}    Verify box is not in degraded mode for switch image
    ...    ELSE    STB is not in degraded mode

Verify box is not in degraded mode for switch image
    [Documentation]    Verify the box is not in degraded mode for switch images
    @{host_names}    create list    dss.dmdsdp.com    selene-remote-serialization.lab5a.nl.dmdsdp.com
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    wait until keyword succeeds    3x    2s    Remote.login    ${STB_IP}    ${ssh_handle}
    : FOR    ${host_name}    IN    @{host_names}
    \    ${output}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    ping -c 3 ${host_name}
    \    ${status}    run keyword and return status    should contain    ${output}    0% packet loss
    \    exit for loop if    ${status}
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    should be true    ${status}    STB is in degraded mode

Get box storage partition
    [Documentation]    This keyword retrieves STB partition and set it as suite variable ${STORAGE_PARTITION}.
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}
    ${storage_partition}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    mount -o remount,rw /; df 2>/dev/null | egrep "/media/sd/pvr$|/media/hdd/pvr$" | sort -k 2 -r | awk 'NR==1{print $6}'
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    Set Suite Variable    ${STORAGE_PARTITION}    ${storage_partition}/

STB Monitoring setup to collect data
    [Arguments]    ${monitor_memory}=${True}    ${monitor_processes}=${True}
    [Documentation]    This keyword retrieves STB partition that will be used for saving output from monitoring scripts.
    ...    ${monitor_memory} or ${monitor_processes} values stand for specific monitoring that can be enabled.
    run keyword if    ${monitor_memory} or ${monitor_processes}    Get box storage partition
    run keyword if    ${monitor_memory}    Start memory monitoring on STB
    run keyword if    ${monitor_processes}    Start Running Process monitoring
