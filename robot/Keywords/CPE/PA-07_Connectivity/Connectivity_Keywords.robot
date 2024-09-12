*** Settings ***
Documentation     Connectivity keywords
Resource          ../PA-07_Connectivity/Connectivity_Implementation.robot

*** Keywords ***
I retrieve Ethernet interface data from STB
    [Documentation]    This keyword gets device ip interface informations from STB
    I get output of commands '@{CMD_TO_GET_INTERFACE_INFORMATION}' executed on the STB

I verify that '${value}' is reported in STB command output list
    [Documentation]    This keyword checks if received STB command output list contain correct ${value}
    ...    Pre-reqs: Suite var @{STB_COMMAND_OUTPUT_LIST} has been set
    Variable should exist    @{STB_COMMAND_OUTPUT_LIST}    Variable @{STB_COMMAND_OUTPUT_LIST} is not set.
    ${STB_COMMAND_OUTPUT_LIST}    Convert To String    ${STB_COMMAND_OUTPUT_LIST}
    list should contain value    ${STB_COMMAND_OUTPUT_LIST}    ${value}    ${STB_COMMAND_OUTPUT_LIST} does not contain ${value}

I send wake on lan packets to put the STB into hot standby
    [Documentation]    This keyword establishes ssh connection to router pc, gets interface name, gets stb mac address
    ...    and sends wake on lan packets to put the STB in hot standby
    I connect to the router pc
    ${interface_name}    I get router pc interface name
    ${mac_address}    get_stb_mac    ${RACK_SLOT_ID}
    Remote.execute_command    ${ROUTER_PC}    ${SSH_HANDLE_ROUTER_PC}    sudo etherwake -i ${interface_name} ${mac_address}

Verify that STB is in hot standby
    [Documentation]    This keyword gets the power state of the STB and verifies if the STB is in hot standby
    ${power_state}    Get current power state with state change reason via AS
    Should Not Be Empty    ${power_state}    power state is not setup
    ${power_state}    convert to string    ${power_state}
    : FOR    ${value}    IN    @{HOT_STANBY_POWER_STATE_VALUES}
    \    should contain    ${power_state}    ${value}    ${value} not found in ${power_state}

I capture DHCPv4 packets for option 125 domain name server
    [Documentation]    This keyword gets dhcp packets for option 125 domain name server
    I capture DHCP packets during STB reboot    125    ${NON_ROUTABLE_ADDRESS}    ${BROADCAST_IP}    ${DEVICE_PRODUCT_CLASS}    ${DEVICE_SERIAL_NUMBER}    180

I capture DHCPv4 packets for option 12 hostname
    [Documentation]    This keyword gets dhcp packets for option 12 hostname
    I capture DHCP packets during STB reboot    12    ${STB_IP}    Router PC IP    ${DEVICE_HOSTNAME}

I set STB hostname to
    [Arguments]    ${stb_new_hostname}
    [Documentation]    This keyword changes the hostname of the STB to ${stb_new_hostname}.
    Set application services setting via as    ${STB_IP}    ${CPE_ID}    cpe.friendlyName    ${stb_new_hostname}

I expect STB DHCPv4 Client Option 12 is
    [Arguments]    ${stb_hostname}
    [Documentation]    This keyword checks if received DHCPv4 packet ${PACKET_MESSAGE_12} contains ${stb_hostname}
    ...    Pre-reqs: Suite var ${PACKET_MESSAGE_12} has been set
    Variable should exist    ${PACKET_MESSAGE_12}    Variable ${PACKET_MESSAGE_12} is not set.
    Packet '${PACKET_MESSAGE_12}' contains '${stb_hostname}'

I connect to the router pc
    [Documentation]    This keyword establishes ssh connection to router pc
    ...    then sets suite variables for ${SSH_HANDLE_ROUTER_PC} so it can be used further in the test scope.
    ${ssh_handle}    Remote.open connection    ${ROUTER_PC}
    Remote.login    ${ROUTER_PC}    ${ssh_handle}    ${ROUTER_PC_USER}    ${ROUTER_PC_PWD}
    set suite variable    ${SSH_HANDLE_ROUTER_PC}    ${ssh_handle}

I check DHCPv4 packets containing option 125 domain name server values
    [Documentation]    This keyword checks if received DHCPv4 packets ${PACKET_MESSAGE_125} contains the same values
    ...    product class and serial number that can be found in ${CPE_ID} variable.
    ...    Pre-reqs: Suite var ${PACKET_MESSAGE_125} has been set
    Variable should exist    ${PACKET_MESSAGE_125}    Variable ${PACKET_MESSAGE_125} is not set.
    ${CPE_ID}    Split String    ${CPE_ID}    -
    ${CPE_ID}    Get Slice From List    ${CPE_ID}    1
    Packet '${PACKET_MESSAGE_125}' contains '${STB_ID[0]}'
    Packet '${PACKET_MESSAGE_125}' contains '${STB_ID[1]}'

I get STB MAC address for
    [Arguments]    ${NETWORK_INTERFACE}
    [Documentation]    This keyword retrieves mac address from STB via ssh, and from using 'get stb mac' keyword.
    ...    then sets test variables for ${NETWORK_INTERFACE}, ${ETH_MAC_ADDRESS}, ${MAC_RETRIEVED_FROM_IFCONFIG}, so they would be available in test scope for further usage.
    ${NETWORK_INTERFACE}    convert to uppercase    ${NETWORK_INTERFACE}
    ${NETWORK_INTERFACE}    replace string    ${NETWORK_INTERFACE}    ${SPACE}    _
    ${MAC_RETRIEVED_FROM_IFCONFIG}    I connect to STB via ssh to run    ${${NETWORK_INTERFACE}}
    Should Match Regexp    ${MAC_RETRIEVED_FROM_IFCONFIG}    (?im)([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})    Retrieved MAC address is invalid.
    ${MAC_RETRIEVED_FROM_IFCONFIG}    remove string    ${MAC_RETRIEVED_FROM_IFCONFIG}    :
    ${ETH_MAC_ADDRESS}    get stb mac    ${RACK_SLOT_ID}
    ${ETH_MAC_ADDRESS}    remove string    ${ETH_MAC_ADDRESS}    :
    Set Test Variable    ${NETWORK_INTERFACE}
    Set Test Variable    ${ETH_MAC_ADDRESS}
    Set Test Variable    ${MAC_RETRIEVED_FROM_IFCONFIG}

I expect STB MAC address to be valid
    [Documentation]    This keyword, generates expected mac ${expected_wlan_mac} for WLAN, then validates (according to ${NETWORK_INTERFACE}), mac address for WLAN or for Ethernet.
    ...    Pre-reqs: It is expected that previously 'I get STB MAC address for' keyword was called and/or
    ...    next variables should have values ${NETWORK_INTERFACE}, ${ETH_MAC_ADDRESS}, ${MAC_RETRIEVED_FROM_IFCONFIG}
    ${expected_wlan_mac}    I generate wlan mac from eth mac    ${ETH_MAC_ADDRESS}
    Run Keyword If    '${NETWORK_INTERFACE}' == 'ETHERNET_INTERFACE'    Should be equal as strings    ${ETH_MAC_ADDRESS}    ${MAC_RETRIEVED_FROM_IFCONFIG}    Incorrect Ethernet STB MAC address.    ignore_case=${True}
    ...    ELSE IF    '${NETWORK_INTERFACE}' == 'WLAN_INTERFACE'    Should be equal as strings    ${expected_wlan_mac}    ${MAC_RETRIEVED_FROM_IFCONFIG}    Incorrect WLAN STB MAC address.
    ...    ignore_case=${True}
    ...    ELSE    Fail Test    Invalid interface ${NETWORK_INTERFACE}

I expect '${expected_connection_state}' TCP session for '${service_name}' should be '${is_expected}'
    [Documentation]    This keyword gets ${current_connection_state} for ${service_name} from STB via ssh.
    ...    Then if connection state should or shouldn't be expected ${is_expected},
    ...    keyword compares that retrieved connection state is (equal/not equal) to ${expected_connection_state}.
    ${service_name}    Run Keyword If    '${service_name}' == 'TRAXIS'    Set Variable    ${TRAXIS_IP}
    ...    ELSE    fail test    Unknown service name = ${service_name}
    ${current_connection_state}    I connect to STB via ssh to run    netstat -anlp | grep ${service_name} | awk '{print $6}'
    Run Keyword If    '${is_expected}' == '${True}'    should be equal as strings    ${current_connection_state}    ${expected_connection_state}    Expected TCP session for '${service_name}' should be '${expected_connection_state}', but recieved state is ${current_connection_state}.
    ...    ELSE    should not be equal as strings    ${current_connection_state}    ${expected_connection_state}    Expected TCP session for '${service_name}' shouldn't be '${expected_connection_state}'.

I establish tcp connection to traxis
    [Documentation]    This keyword establishes tcp connection to traxis by sending simple http request via curl.
    I connect to STB via ssh to run    curl http://127.0.0.1:81/traxis/traxis/

I wait for TCP session to expire
    [Documentation]    This keyword waits for ${KEEPALIVE_TIMEOUT} seconds.
    I wait for ${KEEPALIVE_TIMEOUT} seconds
