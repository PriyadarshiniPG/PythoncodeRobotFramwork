*** Settings ***
Documentation     Keywords related to firmware upgrade

*** Keywords ***
STB is running software
    [Documentation]    This keywords checks current stb software and update to latest image
    log    ${VERSION}
    Update STB to    ${VERSION}

Update STB to
    [Arguments]    ${change_version}
    [Documentation]    Verify the given STB software version and update to latest image
    run keyword if    '${PLATFORM}'=='DCX960'    Update Arris STB to    ${change_version}
    ...    ELSE IF    '${PLATFORM}'=='EOS1008C'    Update Humax STB to    ${change_version}
    ...    ELSE IF    '${PLATFORM}'=='SMT-G7401' or '${PLATFORM}'=='SMT-G7400'    Update Selene STB to    ${change_version}

Update Arris STB to
    [Arguments]    ${change_version}
    [Documentation]    Verify the given STB software version and update the Arris STB to given image
    run keyword if    '${UPGRADEPROCESS}' == 'FactoryReset'    Update STB with tftp flash via 2 button factory reset to    ${change_version}
    ...    ELSE IF    '${UPGRADEPROCESS}' == 'CodeDownload'    Update via ACS    ${change_version}
    ...    ELSE IF    '${UPGRADEPROCESS}' == 'SkipFti'    Update via 2-button factory reset using skip-fti    ${change_version}
    ...    ELSE IF    '${UPGRADEPROCESS}' == 'FactoryResetWithSkipFti'    Update STB with tftp flash via 2 button factory reset and skip-fti    ${change_version}
    ...    ELSE IF    '${UPGRADEPROCESS}' == 'ACSFactoryResetWithSkipFti'    Update STB with ACS factory reset and skip-fti    ${change_version}
    ...    ELSE    fail test    Given wrong value for UPGRADEPROCESS. Either the value should be FactoryReset or CodeDownload.

Update Humax STB to
    [Arguments]    ${change_version}
    [Documentation]    Verify the given STB software version and update the Humax STB to given image
    run keyword if    '${UPGRADEPROCESS}' == 'ACSFactoryResetWithSkipFti'    Update STB with ACS factory reset and skip-fti    ${change_version}
    ...    ELSE    Update Humax STB via network to    ${change_version}

Update Selene STB to
    [Arguments]    ${change_version}
    [Documentation]    Verify the given STB software version and update the Selene STB to given image
    ${needs_downgrade}    Selene box needs XFS downgrade    ${change_version}
    run keyword if    '${UPGRADEPROCESS}' == 'ACSFactoryResetWithSkipFti' and not ${needs_downgrade}    Update Selene STB with ACS factory reset and skip-fti    ${change_version}
    ...    ELSE IF    ${needs_downgrade}    Selene downgrade to XFS software image    ${change_version}
    ...    ELSE    Selene update software image    ${change_version}

Update STB with tftp flash via 2 button factory reset to
    [Arguments]    ${change_version}
    [Documentation]    Verify the given STB software version and update to latest image with
    ...    2 button factory reset downloading from tftp server
    ${status}    ${running}    Run Keyword And Ignore Error    Get STB build version
    ${status}    ${value}    Run Keyword And Ignore Error    Should be equal    ${change_version}    ${running}
    Run Keyword Unless    '${status}' == 'PASS'    Update via 2-button factory reset to    ${change_version}

Update STB with ACS factory reset and skip-fti
    [Arguments]    ${change_version}
    [Documentation]    Update STB to the given image with ACS factory reset.
    ...    This keyword will perform skip fti if the upgrade got failed.
    ${status}    run keyword and return status    Update STB with ACS factory reset to    ${change_version}
    run keyword unless    ${status}    I try to perform skip-fti and verify STB is running with current software

Update STB with ACS factory reset to
    [Arguments]    ${change_version}
    [Documentation]    Verify the given STB software version and update to latest image with
    ...    ACS factory reset
    ${status}    ${running}    Run Keyword And Ignore Error    Get STB build version
    ${status}    ${value}    Run Keyword And Ignore Error    Should be equal    ${change_version}    ${running}
    Run Keyword Unless    '${status}' == 'PASS'    Update via ACS factory reset to    ${change_version}

Update STB with tftp flash via 2 button factory reset and skip-fti
    [Arguments]    ${change_version}
    [Documentation]    Update STB to the given image with 2 button factory reset downloading from tftp server.
    ...    This keyword will perform skip fti if the upgrade via TFTP got failed.
    ${status}    run keyword and return status    Update STB with tftp flash via 2 button factory reset to    ${change_version}
    run keyword unless    ${status}    I try to perform skip-fti and verify STB is running with current software

STB System Software is in version    #NOT_USED
    [Arguments]    ${version}
    [Documentation]    Assert the STB's system software is in specific version
    ${running}    Get STB build version
    Log    ${version}
    should be equal as strings    ${running}    ${version}

Read the STB software version    #USED
    [Documentation]    Keyword to read the current software version in STB
    ${running}    wait until keyword succeeds    4 times    0s    Get STB firmware version
    [Return]    ${running}

Read the STB software version via SSH
    [Documentation]    Keyword to read the current software version in STB via command over SSH
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}
    ${running}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    cat /etc/version
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    [Return]    ${running.strip()}

Get STB firmware version    #USED
    [Documentation]    Keyword to read the current software version in STB
    ${running}    get application service configuration    cpe.firmwareVersion
    [Return]    ${running}

STB Initial Software Version    #USED
    [Documentation]    This keywords checks current stb software before possible update
    ${initial_software_version}    Read the STB software version
    log    Initial STB Software: ${initial_software_version}
    set suite variable  ${CPE_FULL_VERSION}    ${initial_software_version}

STB Under Test Software Version
    [Documentation]    This keywords checks current stb software on which test will be executed
    ${tested_software_version}    Read the STB software version
    log    STB Under Test Software: ${tested_software_version}

Make sure STB is active and also fti is completedAndNotified
    [Documentation]    keyword to make sure STB is active and FTI completed and notified #NOT USER YET
    ${status}    run keyword and return status    Make sure that STB is active
    run keyword unless    ${status}    Handle FTI scenarios eventually with skip-fti if fails and make sure STB is active

Handle FTI scenarios eventually with skip-fti if fails and make sure STB is active
    [Documentation]    This keyword finishes the fti scenarios normally as the first step and eventually performs skip-fti if it fails
    ${status}    run keyword and return status    I try to finish fti scenario and make sure that box is up and running
    run keyword unless    ${status}    I try to finish fti scenario using skip-fti and make sure that box is up and running

Try to verify that FTI state is completed    #USED
    [Documentation]    Keyword to check that that FTI state is completed
    wait until keyword succeeds    8times    20 sec    Check that FTI state is completed

Get Fti State
    [Documentation]    Get STB FTI status
    ${fti_state}    get fti state via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    [Return]    ${fti_state}

Check that FTI state is completed
    [Documentation]    Keyword to check that STB is not in First-Time Install mode.
    ...    When pass you know that the Set-top Box is up and ready to run, but not necessarly running.
    ...    Additional check on the runnig is state is needed (i.e. STB is not in standby).
    ${fti_state}=    Get Fti State
    run keyword unless    '${fti_state}'=='${FTI_STATE_COMPLETED}'    fail test    FTI state is not completed yet

Make sure that STB is running with given version
    [Documentation]    Keyword to check if the STB needs a software upgrade or not. If an upgrade is needed, then an upgrade
    ...    is carried out via ACS, then a check on the version is made to validate the right build is in the STB
    ${status}    ${running}    Run Keyword And Ignore Error    Get STB build version
    return from keyword if    "${VERSION}" == "${running}"
    Verify the build is available in CDN
    STB is running software
    log    Implement update via XAP    WARN

Make sure that STB is running with given version following reboot
    [Documentation]    Keyword to check if the STB needs a software upgrade or not.
    ...    The STB is rebooted (it might be stuck) and checked for FTI complete. An attempt to complete FTI is made
    ...    and the STB is rebooted again and checked to see if it now boots up properly.
    ...    If the STB is still in a bad state, which happens on Selene STBs more than others, 3 button factory reset
    ...    is performed and FTI is completed as needed.
    ...    At this point, the STB should be in a good state to continue with a version check and upgrade (if needed).
    I reboot the STB
    Run keyword and ignore error    I verify STB is booting up in normal mode
    ${fti_status}    Run keyword and return status    first install completed successfully
    run keyword if    ${fti_status} == ${False}    Eventually finish FTI scenario
    I reboot the STB
    ${booting_status}    Run keyword and return status    I verify STB is booting up in normal mode
    run keyword if    ${booting_status} == ${False} and ('${PLATFORM}'=='SMT-G7401' or '${PLATFORM}'=='SMT-G7400')    Perform 3 button factory reset on Selene box finish FTI if needed
    ${status}    ${running}    Run Keyword And Ignore Error    Get STB build version
    ${sw_version}    Set variable if    '${status}' == 'PASS'    ${running}
    return from keyword if    "${VERSION}" == "${sw_version}"
    Verify the build is available in CDN
    STB is running software

Make sure that STB is running with given version using 3 button factory reset
    [Arguments]    ${change_version}=${VERSION}
    [Documentation]    Keyword to perform a software upgrade via 3 button factory reset
    Verify the build is available in CDN
    Check IR connectivity
    Make sure the STB is not in cold standby
    Set Suite Variable    ${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}    ${True}
    Set Suite Variable    ${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}    ${True}
    Perform 3 button factory reset and eventually finish FTI
    Try to verify that fti state is completed
    ${running}    Get STB build version
    run keyword if    "${change_version}" != "${running}"    fail    Software upgrade failed
    Run Keyword If    "${PLATFORM}" != "SMT-G7400" and "${PLATFORM}" != "SMT-G7401"    Disable Pairing Device popup by spoofing paired device status
