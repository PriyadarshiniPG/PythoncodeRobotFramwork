*** Settings ***
Library           SSHLibrary

*** Keywords ***
Deploy Telnet Tool Onto Remote Host
    [Arguments]    ${host}    ${port}    ${user}    ${password}
    Open Connection And Login    ${host}    ${port}    ${user}    ${password}
    SSHLibrary.Put File    ${CURDIR}${/}..${/}..${/}scripts${/}telnetpy${/}telnet_connect.py    telnet_connect.py

Telnet From Local Host
    [Arguments]    ${remote_host}    ${remote_port}
    ${command}    Catenate    SEPARATOR=${SPACE}    python    ${CURDIR}${/}..${/}..${/}scripts${/}telnetpy${/}telnet_connect.py    ${remote_host}    ${remote_port}
    ${output}    Operating System.Run    ${command}
    ${error}    Set Variable if    "OK" in "${output}"    ${EMPTY}    ${output}
    Run Keyword And Ignore Error    Should Be Empty    ${error}    ${error}
    [Return]    ${error}

Telnet From Remote Host
    [Arguments]    ${remote_src_host}    ${ssh_port}    ${ssh_user}    ${ssh_password}    ${remote_dst_host}    ${remote_dst_port}
    Deploy Telnet Tool Onto Remote Host    ${remote_src_host}    ${ssh_port}    ${ssh_user}    ${ssh_password}
    ${command}    Catenate    SEPARATOR=${SPACE}    python    telnet_connect.py    ${remote_dst_host}    ${remote_dst_port}
    ${output}    SSHLibrary.Execute Command    ${command}
    ${error}    Set Variable if    "OK" in "${output}"    ${EMPTY}    ${output}
    Run Keyword And Ignore Error    Should Be Empty    ${error}    ${error}
    [Teardown]    SSHLibrary.Close Connection
    [Return]    ${error}

Check Local Connectivity To Remote LLD Component
    [Arguments]    ${lld_comp_name}    ${hosts_alias}    # Use one of 'prod_lg', 'prod_tenant', 'mgmt' as a value for ${host_alias}
    ${errors}    Create List
    ${hosts}    Set Variable    ${CONF_LLD["${lld_comp_name}"]["${hosts_alias}"]}
    ${ports}    Set Variable    ${CONF_LLD["${lld_comp_name}"]["ports"]}
    ${host_port_combinations}    Evaluate    [{"host": item[0], "port": item[1]} for item in list(itertools.product(${hosts}, ${ports}))]    itertools
    Log    ${host_port_combinations}
    : FOR    ${item}    IN    @{host_port_combinations}
    \    ${err}    Telnet From Local Host    ${item["host"]}    ${item["port"]}
    \    Run Keyword If    "${err}" != ""    Append To List    ${errors}    ${err}
    \    Run Keyword If    "${err}" != ""    Log    Error when run "telnet ${item["host"]} ${item["port"]}"
    ${error}    Concatenate List Values    ${errors}
    [Return]    ${error}

Check Remote Connectivity To Remote LLD Component
    [Arguments]    ${remote_src_host}    ${ssh_port}    ${ssh_user}    ${ssh_password}    ${lld_comp_name}    ${hosts_alias}
    ...    # Use one of 'prod_lg', 'prod_tenant', 'mgmt' as a value for ${host_alias}
    ${errors}    Create List
    ${hosts}    Set Variable    ${CONF_LLD["${lld_comp_name}"]["${hosts_alias}"]}
    ${ports}    Set Variable    ${CONF_LLD["${lld_comp_name}"]["ports"]}
    ${host_port_combinations}    Evaluate    [{"host": item[0], "port": item[1]} for item in list(itertools.product(${hosts}, ${ports}))]    itertools
    Log    ${host_port_combinations}
    :FOR    ${item}    IN    @{host_port_combinations}
    \    ${err}    Telnet From Remote Host    ${remote_src_host}    ${ssh_port}    ${ssh_user}    ${ssh_password}
    \    ...    ${item["host"]}    ${item["port"]}
    \    Run Keyword If    "${err}" != ""    Append To List    ${errors}    ${err}
    \    Run Keyword If    "${err}" != ""    Log    Error when run "ssh ${ssh_user}@${remote_src_host} -p ${ssh_port}". Password: ${ssh_password}. Then run "telnet ${item["host"]} ${item["port"]}"
    ${error}    Concatenate List Values    ${errors}
    [Return]    ${error}
