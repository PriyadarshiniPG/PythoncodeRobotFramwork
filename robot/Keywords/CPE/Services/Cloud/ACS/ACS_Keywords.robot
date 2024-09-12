*** Settings ***
Documentation     Keywords related to STB management with ACS
Resource          ../../../Common/Common.robot
Resource          ../../../PA-03_Boot_standby_and_Installation/UpdateOperation_Keywords.robot

*** Variables ***
${acs_factory_reset_param}    Device.DeviceInfo.X_LGI-COM_DeviceReset.SelectedResetMode
${acs_factory_reset_value}    RESET_AND_CLEAR_LOCAL_SETTINGS
${check_now_param}    Device.ManagementServer.X_LGI-COM_SoftwareDownload.OAL.CheckNow
${download_url_param}    Device.ManagementServer.X_LGI-COM_SoftwareDownload.OAL.DownloadURL
${ACS_LOGIN}      admin
${ACS_PASS}       ax

*** Keywords ***
I signal a CheckNow firmware upgrade from ACS
    [Arguments]    ${change_version}
    [Documentation]    Request remote firmware upgrade using ACS
    I try to set the Software Download URL    ${change_version}
    I try to set the ACS checknow param

I perform factory reset through ACS
    [Documentation]    Request remote factory reset using ACS
    set acs parameter    ${ACS_LOGIN}    ${ACS_PASS}    ${acs_factory_reset_param}    ${acs_factory_reset_value}    ${CPE_ID}

Update via ACS
    [Arguments]    ${change_version}
    [Documentation]    Instruct the STB to perform the steps to update via ACS and fail the step if
    ...    the updated version is not matching with the given version
    ${running}    Read the STB software version
    return from keyword if    '${change_version}' == '${running}'
    wait until keyword succeeds    2x    5s    Make sure that STB is not in standby
    Run Keyword if    '${JSON}' == 'True'    I Want To Enable Json Handler Function
    I signal a CheckNow firmware upgrade from ACS    ${change_version}
    I wait for the forced update info screen    300
    Forced update info screen is shown
    Run keyword if    '${OBELIX}' == 'True'    I verify STB is booting up in normal mode
    Run keyword unless    '${OBELIX}' == 'True'    Sleep    4 minutes
    Make sure that STB is active
    ${running}    Read the STB software version
    should be equal    ${running}    ${change_version}

I do a CheckNow to upgrade firmware
    [Documentation]    Request remote firmware upgrade using ACS for the user given version
    run keyword if    '${VERSION}' == 'DoNotUpgrade'    fail test    Variable Version is not given
    I signal a CheckNow firmware upgrade from ACS    ${VERSION}

I try to set the Software Download URL
    [Arguments]    ${change_version}
    [Documentation]    Try to set the Software Download URL.
    ${status}    run keyword and return status    I set the Software Download URL    ${change_version}
    return from keyword if    '${status}' == 'True'
    I reboot the STB
    I verify STB is booting up in normal mode
    wait until keyword succeeds    3times    10 sec    tune to free channel and check content
    I set the Software Download URL    ${change_version}

I try to set the ACS checknow param
    [Documentation]    Try to set the ACS checknow param.
    ${status}    run keyword and return status    set acs parameter    ${ACS_LOGIN}    ${ACS_PASS}    ${check_now_param}    1
    ...    ${CPE_ID}
    return from keyword if    '${status}' == 'True'
    I reboot the STB
    I verify STB is booting up in normal mode
    wait until keyword succeeds    3times    10 sec    tune to free channel and check content
    set acs parameter    ${ACS_LOGIN}    ${ACS_PASS}    ${check_now_param}    1    ${CPE_ID}

I set the '${variable_name}' value via ACS to '${variable_value}'
    [Documentation]    This keyword sets ${variable_name} value via ACS to '${variable_value}'.
    Set acs parameter    ${ACS_LOGIN}    ${ACS_PASS}    ${variable_name}    ${variable_value}    ${CPE_ID}

I verify the '${variable_name}' value is set via ACS to '${variable_value}'
    [Documentation]    This keyword verifies that ${variable_name} value is actually set via ACS to ${variable_value}.
    ${retrieved_value}    I connect to STB via ssh to run    cat /mnt/app_services/data/upgrade/main.json | grep -Eo '${variable_name}":[0-9]+' | awk -F ':' '{print $2}'
    Should Be Equal    ${retrieved_value}    ${variable_value}    The ${variable_name} value should be ${variable_value}, but received ${retrieved_value}

Set Periodic Check Interval via ACS Setup
    [Documentation]    This retrieves origin value for PeriodicCheckInterval value
    ...    that will be set as a global variable ${RETRIEVED_UPGRADE_PERIODIC_CHECK_INTERVAL}.
    Default Suite Setup
    ${retrieved_value}    I connect to STB via ssh to run    cat /mnt/app_services/data/upgrade/main.json | grep -Eo 'PeriodicCheckInterval":[0-9]+' | awk -F ':' '{print $2}'
    Set Global Variable    ${RETRIEVED_UPGRADE_PERIODIC_CHECK_INTERVAL}    ${retrieved_value}

Set Periodic Check Interval via ACS Teardown
    [Documentation]    This sets origin ${RETRIEVED_UPGRADE_PERIODIC_CHECK_INTERVAL} value via ACS.
    ...    Pre-reqs: ${RETRIEVED_UPGRADE_PERIODIC_CHECK_INTERVAL} variable should exist.
    Variable should exist    ${RETRIEVED_UPGRADE_PERIODIC_CHECK_INTERVAL}    Variable ${RETRIEVED_UPGRADE_PERIODIC_CHECK_INTERVAL} has not been set.
    Set acs parameter    ${ACS_LOGIN}    ${ACS_PASS}    Device.ManagementServer.X_LGI-COM_SoftwareDownload.OAL.PeriodicCheckInterval    ${RETRIEVED_UPGRADE_PERIODIC_CHECK_INTERVAL}    ${CPE_ID}
    Default Suite Teardown
