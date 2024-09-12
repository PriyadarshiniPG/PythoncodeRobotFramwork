*** Settings ***
Documentation     Connectivity implementation keywords
Resource          ../Common/Common.robot

*** Variables ***
${ETH2}           /sbin/ifconfig -a | grep eth2 | awk '{print $5}'
${WLAN2}          /sbin/ifconfig -a | grep wlan2 | awk '{print $5}'
${ENABLE_WLAN2}    /sbin/ifconfig wlan2 up
${DISABLE_WLAN2}    /sbin/ifconfig wlan2 down
${DISABLE_AXACT}    systemctl stop axact
${ENABLE_AXACT}    systemctl start axact
${ETHERNET_INTERFACE}    ${eth2}
${WLAN_INTERFACE}    ${wlan2}
${KEEPALIVE_TIMEOUT}    60
@{CMD_TO_GET_INTERFACE_INFORMATION}    dmtest gv Device.IP.Interface.2.Name | grep Name    dmtest gv Device.IP.Interface.2.LowerLayers | grep LowerLayers
${DHCP_PORTS}     'udp port 67 || udp port 68'
${DEVICE_PRODUCT_CLASS}    bootp.option.vi.tr111.device_product_class
${DEVICE_SERIAL_NUMBER}    bootp.option.vi.tr111.device_serial_number
${DEVICE_HOSTNAME}    bootp.option.hostname
${BROADCAST_IP}    255.255.255.255
${NON_ROUTABLE_ADDRESS}    0.0.0.0
${DHCP_TIMEOUT}    480
@{HOT_STANBY_POWER_STATE_VALUES}    WOL    ActiveStandby

*** Keywords ***
I get output of commands '${commands}' executed on the STB
    [Documentation]    This keyword retrieves output for any number of commands ${commands} executed on the STB
    ...    and saves those outputs in @{command_output_list} list. Then sets suite variables for @{STB_COMMAND_OUTPUT_LIST}
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    @{command_output_list}    Create List
    Remote.login    ${STB_IP}    ${ssh_handle}
    : FOR    ${command}    IN    @{commands}
    \    ${command_output}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    ${command}
    \    Should Not Be Empty    ${command_output}    Logs for ${command} returned no messages
    \    Append to List    ${command_output_list}    ${command_output}
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    Set suite variable    @{STB_COMMAND_OUTPUT_LIST}    ${command_output_list}

I capture DHCP packets during STB reboot
    [Arguments]    ${packet_option}    ${ip.addr}    ${ip.dst}    ${field_parameter_1}    ${field_parameter_2}=_ws.col.Info    ${timeout_duration}=${DHCP_TIMEOUT}
    [Documentation]    This keyword gets the interface name, reboots the STB and then sends a tshark command to sniff for packets,
    ...    After STB has booted up in normal mode, we read the output of the tshark command and close the connection.
    ...    Then sets suite variables for ${PACKET_MESSAGE_${packet_option}} so it can be used further in the test scope.
    ...    Pre-reqs: Suite var ${SSH_HANDLE_ROUTER_PC} has been set
    Variable should exist    ${SSH_HANDLE_ROUTER_PC}    Variable SSH_HANDLE_ROUTER_PC is not set.
    ${ip.dst}    run keyword if    '${ip.dst}'=='Router PC IP'    I get router pc interface ip
    ...    ELSE    set variable    ${ip.dst}
    ${interface_name}    I get router pc interface name
    I reboot the STB
    Remote.start_command    ${ROUTER_PC}    ${SSH_HANDLE_ROUTER_PC}    sudo tshark -i ${interface_name} -f ${DHCP_PORTS} -T fields -Y 'ip.addr==${ip.addr} && ip.dst==${ip.dst}' -e ${field_parameter_1} -e ${field_parameter_2} -a duration:${timeout_duration}
    I verify STB is booting up in normal mode
    ${packet_message}    Remote.read_command_output    ${ROUTER_PC}    ${SSH_HANDLE_ROUTER_PC}
    Remote.close connection    ${ROUTER_PC}    ${SSH_HANDLE_ROUTER_PC}
    set suite variable    ${PACKET_MESSAGE_${packet_option}}    ${packet_message}

I get STB hostname
    [Documentation]    This keyword gets STB hostname.
    ...    Then sets suite variables for ${ORIGINAL_HOSTNAME} so it can be used further in the suite scope.
    ${original_hostname}    get application service setting via as    ${STB_IP}    ${CPE_ID}    cpe.friendlyName
    should not be empty    ${original_hostname}    Hostname is not set
    ${original_hostname}    remove string    ${original_hostname}    "
    set suite variable    ${ORIGINAL_HOSTNAME}

I get router pc interface ip
    [Documentation]    This keyword gets interface ip from router pc and returns ${interface_ip}.
    ...    Pre-reqs: Suite var ${SSH_HANDLE_ROUTER_PC} has been set
    Variable should exist    ${SSH_HANDLE_ROUTER_PC}    Variable SSH_HANDLE_ROUTER_PC is not set.
    ${interface_name}    I get router pc interface name
    ${interface_ip}    Remote.execute_command    ${ROUTER_PC}    ${SSH_HANDLE_ROUTER_PC}    ifconfig ${interface_name} | grep 'inet addr' | awk '{print $2}' | tr -d 'addr:'
    should not be empty    ${interface_ip}    Interface ip is not setup.
    [Return]    ${interface_ip}

I get router pc interface name
    [Documentation]    This keyword gets interface name from router pc and returns ${interface_name}.
    ...    Pre-reqs: Suite var ${SSH_HANDLE_ROUTER_PC} has been set
    Variable should exist    ${SSH_HANDLE_ROUTER_PC}    Variable SSH_HANDLE_ROUTER_PC is not set.
    ${eth_mac_address}    get stb mac    ${RACK_SLOT_ID}
    ${eth_mac_address}    convert to lowercase    ${eth_mac_address}
    Remote.start_command    ${ROUTER_PC}    ${SSH_HANDLE_ROUTER_PC}    echo $(arp | grep ${eth_mac_address} | awk '{print $5}')
    ${interface_name}    Remote.read_command_output    ${ROUTER_PC}    ${SSH_HANDLE_ROUTER_PC}
    should not be empty    ${interface_name}    Interface name is not setup.
    [Return]    ${interface_name}

Packet '${packet}' contains '${message}'
    [Documentation]    This keyword checks if the packet identified by the ${packet} argument contains the correct message
    ...    identified by the ${message} argument.
    Should Contain    ${packet}    ${message}    Packet ${packet} does not contain message ${message}

I connect to STB via ssh to run
    [Arguments]    ${command}
    [Documentation]    This keyword connects to STB via ssh to run command, ${command} passed as argument. Returns ${output} from command.
    ${sshhandle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${sshhandle}
    ${output}    Remote.execute_command    ${STB_IP}    ${sshhandle}    ${command}
    Remote.close connection    ${STB_IP}    ${sshhandle}
    [Return]    ${output}

I generate wlan mac from eth mac
    [Arguments]    ${eth_mac}
    [Documentation]    Generates and returns ${wlan_mac} WLAN MAC address from Ethernet MAC address, ${eth_mac} passed as argument.
    ${wlan_mac}    set variable    ${eth_mac}
    ${wlan_mac}    remove string    ${wlan_mac}    :
    ${wlan_mac}    convert to integer    ${wlan_mac}    16
    ${wlan_mac}    set variable    ${wlan_mac+1}
    ${wlan_mac}    convert to hex    ${wlan_mac}
    [Return]    ${wlan_mac}

WLAN Specific Setup
    [Documentation]    Setup steps for tests related to WLAN
    Default Suite Setup
    I connect to STB via ssh to run    ${ENABLE_WLAN2}

WLAN Specific Teardown
    [Documentation]    Teardown steps for tests related to WLAN
    I connect to STB via ssh to run    ${DISABLE_WLAN2}
    Default Suite Teardown

Hostname Specific Setup
    [Documentation]    Setup steps for tests related to Hostname
    Default Suite Setup
    I get STB hostname

Hostname Specific Teardown
    [Documentation]    Teardown steps for tests related to Hostname
    I set STB hostname to    ${ORIGINAL_HOSTNAME}
    ${stb_hostname}    get application service setting via as    ${STB_IP}    ${CPE_ID}    cpe.friendlyName
    should be equal    ${stb_hostname}    ${ORIGINAL_HOSTNAME}    Hostnames are not equal
    Default Suite Teardown

TR-069 Specific Teardown
    [Documentation]    Teardown steps for tests related to TR-069
    I connect to STB via ssh to run    ${ENABLE_AXACT}
    Default Suite Teardown

TR-069 Specific Setup
    [Documentation]    Setup steps for tests related to TR-069
    Default Suite Setup
    I connect to STB via ssh to run    ${DISABLE_AXACT}

TCP Session Connection Suite Setup
    [Documentation]    Setup steps for TCP Session Connection tests that are using traxis ip ${TRAXIS_IP}.
    Default Suite Setup
    I connect to STB via ssh to run    /usr/sbin/iptables -P INPUT ACCEPT && /usr/sbin/iptables -P OUTPUT ACCEPT && /usr/sbin/iptables -P FORWARD ACCEPT && /usr/sbin/iptables -F
    ${retrieved_traxis_ip}    get traxis ip
    Set Suite Variable    ${TRAXIS_IP}    ${retrieved_traxis_ip}
    Wait until keyword succeeds    2times    ${KEEPALIVE_TIMEOUT}s    I expect 'ESTABLISHED' TCP session for 'TRAXIS' should be 'False'
    Wait until keyword succeeds    2times    ${KEEPALIVE_TIMEOUT}s    I expect 'TIME_WAIT' TCP session for 'TRAXIS' should be 'False'
