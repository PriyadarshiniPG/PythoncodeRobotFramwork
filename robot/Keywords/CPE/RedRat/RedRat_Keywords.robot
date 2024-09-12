*** Settings ***
Library            Libraries.RedRat.RedRatService


*** Keywords ***
I put stb in standby via RedRat
    [Documentation]    Power off the settop box using RedRat Device
    I press Button via RedRat        power
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    content unavailable
    log to console  stb is turned off via Red Rat

I put stb out of standby via RedRat
    [Documentation]    Power on the settop box using RedRat Device
    I press Button via RedRat        power
    log to console  stb is turned on via Red Rat


I press Button via RedRat
    [Documentation]    Sends IR signal via RedRat device
    [Arguments]    ${ir_code}
    Send Red Rat Signal    ${ir_code}
