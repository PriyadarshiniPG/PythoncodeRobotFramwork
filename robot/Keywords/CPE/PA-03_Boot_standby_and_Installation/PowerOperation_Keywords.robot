*** Settings ***
Documentation     Power operation Keywords
Resource          ./PowerOperation_Implementation.robot

*** Variables ***
${Quick start}    DIC_SETTINGS_STANDBYPOWER_VALUE_HIGH
${Normal start}    DIC_SETTINGS_STANDBYPOWER_VALUE_MEDIUM
${Eco start}      DIC_SETTINGS_STANDBYPOWER_VALUE_LOW
&{STANDBY_CONTENT_RESPONSE_WINDOW}    ActiveStandby=5    LukewarmStandby=30    ColdStandby=90

*** Keywords ***
I verify that standby warning toast message is shown
    [Documentation]    Keyword to verify that the standby warning toast message is present
    Standby warning toast message is present

I verify that standby warning toast message got dismissed
    [Documentation]    Keyword to verify that the standby warning toast message is not present
    wait until keyword succeeds    4times    1 min    Standby warning toast message is not present

validate STB parameters in Quick start mode
    [Documentation]    validate STB parameters in Quick start mode
    wait until keyword succeeds    5times    0s    Verify that STB is in standby mode
    Run keyword if    '${OBELIX}' == 'True'    Run Keywords    video not playing
    ...    AND    audio not playing
    ...    ELSE    Log    OBELIX variable set to False, skipping content check    WARN
    I wait until no signal screen is shown    ${1}
    verify network interface is    active
#    ${ssh_handle}    Remote.open connection    ${STB_IP}
#    Remote.login    ${STB_IP}    ${ssh_handle}
    verify serial console is active
    verify DVB-C Tuners are    active
    verify Video Processor is in    ${ssh_handle}    active
    verify Front panel keys are    ${ssh_handle}    inactive
    verify IR-RF4CE receiver is    ${ssh_handle}    active
    verify storage devices are    active    ${ssh_handle}
    verify EMM monitoring is    ${ssh_handle}    active
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    The power consumption in Quick start is attained

I turn power off
    [Documentation]    Just Power off the STB via PDU
    power off    ${STB_SLOT}    ${STB_PDU_SLOT}

Stb is turned off
    [Documentation]    Check the STB is off afer pressing power off button
    I wait until no signal screen is shown    ${10}
