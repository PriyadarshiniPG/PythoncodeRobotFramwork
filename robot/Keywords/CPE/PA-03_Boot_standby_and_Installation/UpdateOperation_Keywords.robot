*** Settings ***
Documentation     Keywords concerning the STBs version information and update
Library           SSHLibrary
Resource          ../Common/Stbinterface.robot
Resource          ../PA-05_Linear_TV/LinearDetailsPage_Keywords.robot

*** Variables ***
${CDN_HOST}       172.30.104.85
${CDN_USERNAME}    root
${CDN_PASSWORD}    -----
${CDN_HOME_LOCATION}    /mnt/Dawnssu/Lab5a/swimages/dawn/software
${CDN_CPESI_HOME_LOCATION}    /mnt/Dawnssu/Lab5a/cpe-si/swimages/dawn/software
${HUMAX_STB_BUILD_LOCATION}    EOS1008C-DEV/Nagra
${ARRIS_STB_BUILD_LOCATION}    dcx960/1
${SELENE_STB_BUILD_LOCATION}    smt-g7401/nagra
${APOLLO_STB_BUILD_LOCATION}    VIP5002W-DEV/ONEM
${CPEPREV_LOCATION}    /mnt/Dawnssu/Lab5a/swimages/dawn/software/dcx960/1/cpeprev
${RECOVERY_MANIFEST_LOCATION}    /mnt/Dawnssu/Lab5a/swimages/dawn/software/dcx960/1/manifest.cms
${SOFTWARE_DWNLD_URL_PREFIX}    http://omwssu.lab5a.nl.dmdsdp.com/swimages/dawn/software
${SOFTWARE_DWNLD_URL_PREFIX_CPESI}    http://omwssu.lab5a.nl.dmdsdp.com/cpe-si/swimages/dawn/software
${HUMAX_EOS_MANIFEST_FILE_ROOT_ELEMENT}    software-images
${COMMON_MANIFEST_FILE_ROOT_ELEMENT}    CdlManifestFile

*** Keywords ***
STB is running with current software
    [Documentation]    Assert the STB's system software is in current version
    run keyword if    '${VERSION}' == 'DoNotUpgrade'    fail test    Variable Version is not given
    Update STB to    ${VERSION}

Verify STB is running with current software
    [Arguments]    ${software_version}=${VERSION}
    [Documentation]    Check whether the STB's system software is in current version
    run keyword if    '${software_version}' == 'DoNotUpgrade'    fail test    Version value is not given
    STB System Software is in version    ${software_version}

Verify STB is running with previous software
    [Documentation]    Check whether the STB's system software is in previous version
    ${previous_software_version}    Read the discovery image version from CDN
    ${running}    Read the STB software version
    Should be equal    ${previous_software_version}    ${running}

Get STB build version    #NOT_USED
    [Documentation]    Get the STB software version. This keyword tries to read the software version via AS,
    ...    then via SSH, if the read via AS fails
    ${status}    ${running}    Run Keyword And Ignore Error    Read the STB software version
    ${sw_version}    Set variable if    '${status}' == 'PASS'    ${running}
    Return from keyword if    '${status}' == 'PASS'    ${sw_version}
    ${status}    ${running}    Run Keyword And Ignore Error    Read the STB software version via SSH
    ${sw_version}    Set variable if    '${status}' == 'PASS'    ${running}
    [Return]    ${sw_version}

Verify STB is running with rescue software
    [Documentation]    Check whether the STB's system software is in rescue image
    Verify STB is running with previous software

I do a CheckNow to downgrade firmware
    [Documentation]    Assert the STB's system software is in previous version
    ${previous_software_version}    Read the discovery image version from CDN
    ${status}    ${value} =    Run Keyword And Ignore Error    Verify STB is running with previous software
    Run Keyword Unless    '${status}' == 'PASS'    Update via ACS    ${previous_software_version}

I signal a CheckNow firmware upgrade to discovery image from ACS
    [Documentation]    Assert the STB's system software in rescue/discovery image
    ${rescue_software_version}    Read the discovery image version from CDN
    I signal a CheckNow firmware upgrade from ACS    ${rescue_software_version}

The operator signals a CheckNow firmware upgrade from the ACS
    [Documentation]    This keyword signals the STB from ACS through checknow to download new software
    I signal a CheckNow firmware upgrade to discovery image from ACS

Open Connection And Log In
    [Documentation]    This keyword opens ssh connection to CDN host
    ${index}    SSHLibrary.Open Connection    ${CDN_HOST}
    SSHLibrary.Login    ${CDN_USERNAME}    ${CDN_PASSWORD}
    log    ${index}

I set the Software Download URL
    [Arguments]    ${change_version}
    [Documentation]    Set the Software Download URL to perform the upgrade
    ${download_url}    run keyword if    '${PLATFORM}'=='DCX960'    Catenate    SEPARATOR=/    ${SOFTWARE_DWNLD_URL_PREFIX}    ${ARRIS_STB_BUILD_LOCATION}
    ...    ${change_version}
    ...    ELSE IF    '${PLATFORM}'=='EOS1008C'    Catenate    SEPARATOR=/    ${SOFTWARE_DWNLD_URL_PREFIX}    ${HUMAX_STB_BUILD_LOCATION}
    ...    ${change_version}
    ...    ELSE IF    '${PLATFORM}'=='SMT-G7401' or '${PLATFORM}'=='SMT-G7400'    Catenate    SEPARATOR=/    ${SOFTWARE_DWNLD_URL_PREFIX}    ${SELENE_STB_BUILD_LOCATION}
    ...    ${change_version}
    ...    ELSE IF    '${PLATFORM}'=='APOLLO'    Catenate    SEPARATOR=/    ${SOFTWARE_DWNLD_URL_PREFIX}    ${APOLLO_STB_BUILD_LOCATION}
    ...    ${change_version}
    ${download_url}    Catenate    SEPARATOR=    ${download_url}    /
    log    ${download_url}
    set acs parameter    ${ACS_LOGIN}    ${ACS_PASS}    ${download_url_param}    ${download_url}    ${CPE_ID}

I wait for the forced update info screen
    [Arguments]    ${wait_time}=60
    [Documentation]    Keyword to wait until the forced update info screen shown for the given time
    wait until keyword succeeds    ${wait_time} sec    2 sec    I expect page contains 'id:forcedUpdatePopup'

Forced update info screen is shown
    [Documentation]    Verifying forced update info screen is shown or not
    ${json_object}    Get Ui Json
    ${popup_title}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_SW_FORCED_UPDATE_HEADER
    ${popup_text}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_SW_FORCED_UPDATE_MESSAGE
    ${spinner_present}    Is In Json    ${json_object}    ${EMPTY}    id:forcedUpdatePopupSpinner
    Should Be True    ${popup_title}
    Should Be True    ${popup_text}
    Should Be True    ${spinner_present}

The forced update info screen is shown
    [Documentation]    Verifyies with multiple retries until forced update info screen is shown
    I wait for the forced update info screen    wait_time=90
    Forced update info screen is shown

Verify the build is available in CDN
    [Arguments]    ${build_version}=${VERSION}    ${redeploy}=${False}
    [Documentation]    Keyword to make sure that build is present in the folder specific for the Set-top Box in CDN
    ${connection_index}    Open Connection And Log In
    SSHLibrary.Get Connections
    ${CDN_HOME_LOCATION}    run keyword if    '${PLATFORM}'=='DCX960'    Catenate    SEPARATOR=/    ${CDN_HOME_LOCATION}    ${ARRIS_STB_BUILD_LOCATION}
    ...    ELSE IF    '${PLATFORM}'=='EOS1008C'    Catenate    SEPARATOR=/    ${CDN_HOME_LOCATION}    ${HUMAX_STB_BUILD_LOCATION}
    ...    ELSE IF    '${PLATFORM}'=='SMT-G7401' or '${PLATFORM}'=='SMT-G7400'    Catenate    SEPARATOR=/    ${CDN_HOME_LOCATION}    ${SELENE_STB_BUILD_LOCATION}
    ...    ELSE IF    '${PLATFORM}'=='APOLLO'    Catenate    SEPARATOR=/    ${CDN_HOME_LOCATION}    ${APOLLO_STB_BUILD_LOCATION}
    log    ${CDN_HOME_LOCATION}
    ${build_dir}    Catenate    SEPARATOR=/    ${CDN_HOME_LOCATION}    ${build_version}
    log    ${build_dir}
    ${is_build_dir_present}    run keyword and return status    SSHLibrary.Directory Should Exist    ${build_dir}
    should be true    ${is_build_dir_present}    The requested build directory is not present
    ${build_version}    run keyword if    '${PLATFORM}'=='EOS1008C'    SSHLibrary.Execute Command    cd ${build_dir}/; ls *.hdf
    ...    ELSE    SSHLibrary.Execute Command    cd ${build_dir}/; ls *${PLATFORM_IMAGE_POSTFIX}
    log    ${build_version}
    ${individual_build_path}    Catenate    SEPARATOR=/    ${CDN_HOME_LOCATION}    ${VALUESETNAME}    ${build_version}
    log    ${individual_build_path}
    ${individual_build_dir}    Catenate    SEPARATOR=/    ${CDN_HOME_LOCATION}    ${VALUESETNAME}
    log    ${individual_build_dir}
    ${is_individual_build_dir_present}    run keyword and return status    SSHLibrary.Directory Should Exist    ${individual_build_dir}
    run keyword unless    ${is_individual_build_dir_present}    SSHLibrary.Execute Command    mkdir ${individual_build_dir}
    ${is_individual_build_path_present}    run keyword and return status    SSHLibrary.File Should Exist    ${individual_build_path}
    return from keyword if    ${is_individual_build_path_present} and ${redeploy}==${False}
    log    Removing:${individual_build_dir}/*old*
    SSHLibrary.Execute Command    rm -f ${individual_build_dir}/*old*;
    log    Moving ${individual_build_dir}/manifest.cms to ${individual_build_dir}/manifest.cms.old
    SSHLibrary.Execute Command    mv ${individual_build_dir}/manifest.cms ${individual_build_dir}/manifest.cms.old
    ${previous_version}    run keyword if    '${PLATFORM}'=='EOS1008C'    SSHLibrary.Execute Command    cd ${individual_build_dir}; ls *.hdf
    ...    ELSE    SSHLibrary.Execute Command    cd ${individual_build_dir}; ls *${PLATFORM_IMAGE_POSTFIX}
    log    Moving ${individual_build_dir}/${previous_version} ${individual_build_dir}/${previous_version}.old
    SSHLibrary.Execute Command    mv ${individual_build_dir}/${previous_version} ${individual_build_dir}/${previous_version}.old
    log    Copying ${build_dir}/* ${individual_build_dir}/
    SSHLibrary.Execute Command    cp ${build_dir}/* ${individual_build_dir}/
    ${is_individual_build_path_present}    run keyword and return status    SSHLibrary.File Should Exist    ${individual_build_path}
    run keyword unless    ${is_individual_build_path_present}    fail test    Failed to copy the build to ${individual_build_dir}
    ${manifest_present}    run keyword and return status    SSHLibrary.File Should Exist    ${individual_build_dir}/manifest.cms
    run keyword unless    ${manifest_present}    fail test    Failed to copy manifest to ${individual_build_dir}

A new software version is loaded into the CDN
    [Documentation]    This keyword makes sure that a new build (rescue build) is available in the folder specific for the Set-top Box in CDN
    ${previous_software_version}    Read the discovery image version from CDN
    Verify the build is available in CDN    ${previous_software_version}

Update via 2-button factory reset using skip-fti
    [Arguments]    ${change_version}
    [Documentation]    Instruct the STB to perform the steps to emulate 2-button factory reset and update the box via skip FTI. This method is valid for debug build only.
    ${running}    Read the STB software version
    return from keyword if    '${change_version}' == '${running}'
    wait until keyword succeeds    2times    5s    Perform 2-button factory reset and flash from CFE to    ${change_version}
    check if STB is booting up on FTI with 2 button factory reset using skip-fti
    verify STB is running with current software

check if STB is booting up on FTI with 2 button factory reset using skip-fti
    [Documentation]    Verifying STB is booted up during skip FTI method
    I verify STB is booting up    180
    I wait until initial welcome screen is shown    60
    I wait until please wait screen is shown    150
    I wait until please wait screen got dismissed
    Perform skip-fti action and apply configuration

Perform skip-fti action and apply configuration
    [Documentation]    Steps to perform skip FTI method
    run keyword if    '${SERIALCOM}' == 'True'    Execute skip-fti over Serial
    ...    ELSE    Execute skip-fti over SSH
    I wait until please wait screen is shown    600
    I wait until please wait screen got dismissed
    ${build_version}    run keyword if    '${SERIALCOM}' == 'True'    Get software version via Serial
    ...    ELSE    Read the STB software version via SSH
    Apply build configuration via SSH    ${build_version}
    I reboot the STB
    I verify STB is booting up in normal mode
    Run Keyword if    '${JSON}' == 'True'    Enable JSON Ui Handler via Application Services

Download configuration file from CDN for update via SSH
    [Arguments]    ${build_version}
    [Documentation]    This keyword downloads default configuration file from CDN and stores it on the rack PC
    ${exact_platform}    Get Exact Platform    ${RACK_SLOT_ID}
    ${lowercase_platform}    Convert To Lowercase    ${exact_platform}
    ${box_platform}    Set Variable If    '${lowercase_platform}' == 'eos1008c'    eos-1008c    '${lowercase_platform}' == 'eos1008r'    eos-1008r    ${lowercase_platform}
    ${cdn_path}    Set Variable If    ${MULTI_ROOM_UPGRADE}    /mnt/omw/Lab5a/configs/lab5a/gb/local_dvr    /mnt/omw/Lab5a/configs/lab5a/be
    ${ssh_handle}    Remote.open connection    ${CDN_HOST}
    Remote.login    ${CDN_HOST}    ${ssh_handle}    ${CDN_USERNAME}    ${CDN_PASSWORD}
    Remote.get    ${CDN_HOST}    ${ssh_handle}    ${cdn_path}/${box_platform}/${build_version}/config.json    ${VALUESETNAME}_config.json
    Remote.close connection    ${CDN_HOST}    ${ssh_handle}

Upload configuration file from rack PC to the STB via SSH
    [Documentation]    This keyword uploads configuration file from rack PC to the STB
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Wait Until Keyword Succeeds    3x    2s    Remote.login    ${STB_IP}    ${ssh_handle}
    Remote.put    ${STB_IP}    ${ssh_handle}    ${VALUESETNAME}_config.json    /tmp/config.json
    ${cmd_result}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    ls -la /tmp/config.json
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    Should Not Be Empty    ${cmd_result}
    @{file_details}    Split String    ${cmd_result}
    Should Not Be Equal As Integers    @{file_details}[4]    0    Configuration file size should not be Zero

Swap configuration file on the STB with one from the rack PC via SSH
    [Documentation]    This keyword swaps the current configuration file with the one stored under /tmp/config.json
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Wait Until Keyword Succeeds    3x    2s    Remote.login    ${STB_IP}    ${ssh_handle}
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    /usr/sbin/iptables -P INPUT ACCEPT
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    /usr/sbin/iptables -P OUTPUT ACCEPT
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    /usr/sbin/iptables -P FORWARD ACCEPT
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    /usr/sbin/iptables -F
    ${output}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    cd /tmp; curl -X PUT --header 'Content-Type: application/json' --header 'Accept: application/json' 'http://localhost:10014/configuration/setConfiguration' -d @config.json
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    rm /tmp/config.json
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    [Return]    ${output}

Apply build configuration via SSH
    [Arguments]    ${build_version}
    [Documentation]    This keyword applies the configuration after downloading it from CDN over SSH
    Download configuration file from CDN for update via SSH    ${build_version}
    Upload configuration file from rack PC to the STB via SSH
    ${result}    Swap configuration file on the STB with one from the rack PC via SSH
    Should Contain    ${result}    "firmwareVersion":"${build_version}"    msg=Failed to skip the FTI process

Execute skip-fti over Serial
    [Documentation]    This keyword will execute skip fti command over serial connection
    Drop input buffer and verify response
    Send command and verify response    sh /usr/share/lgias/skip-fti.sh

Execute skip-fti over SSH
    [Documentation]    This keyword will execute skip fti command over ssh connection
    ${sshhandle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${sshhandle}
    Remote.execute_command    ${STB_IP}    ${sshhandle}    sh /usr/share/lgias/skip-fti.sh
    Remote.close connection    ${STB_IP}    ${sshhandle}

Update Humax STB via network to
    [Arguments]    ${change_version}
    [Documentation]    Instruct the Humax STB to update to the given version
    ${status}    ${running} =    Run Keyword And Ignore Error    Get STB build version
    ${status}    ${value} =    Run Keyword And Ignore Error    Should be equal    ${change_version}    ${running}
    return from keyword if    '${status}' == 'PASS'
    I reboot the STB
    Go to humax bootloader console
    Try to set manifest URL in nvram    ${change_version}
    Download manifest file and trigger update on Humax box
    I verify STB is booting up    300
    I verify STB is booting up until no signal screen is shown
    I wait until please wait screen is shown    150
    I wait until please wait screen got dismissed
    ${running}    Get STB build version
    ${status}    ${value} =    Run Keyword And Ignore Error    Should be equal    ${change_version}    ${running}
    Run Keyword Unless    '${status}' == 'PASS'    fail    Software upgrade failed

Update via ACS factory reset to
    [Arguments]    ${change_version}
    [Documentation]    Instruct the STB to perform the steps to emulate ACS factory reset.
    I perform factory reset through ACS
    I verify STB is booting up    180
    I wait until initial welcome screen is shown    120
    I wait until software download screen is shown    180
    I wait until software installation screen is shown    120
    I try to finish fti scenario and make sure that box is up and running
    Make sure that STB is active
    Run Keyword if    '${JSON}' == 'True'    Enable JSON Ui Handler via Application Services
    verify STB is running with current software    ${change_version}

Use CPE-SI CDN Folder Redirection
    [Documentation]    This keyword saves the initial values for the CDN_HOME_LOCATION and SOFTWARE_DWNLD_URL_PREFIX
    ...    variables and overwrites them with a redirection to the CPE-SI specific folder in the CDN as Test Variables,
    ...    saving the original values to the INITIAL_CDN_HOME_LOCATION and INITIAL_SOFTWARE_DWNLD_URL_PREFIX tests variables.
    Set Test Variable    ${INITIAL_CDN_HOME_LOCATION}    ${CDN_HOME_LOCATION}
    Set Test Variable    ${INITIAL_SOFTWARE_DWNLD_URL_PREFIX}    ${SOFTWARE_DWNLD_URL_PREFIX}
    Set Test Variable    ${CDN_HOME_LOCATION}    ${CDN_CPESI_HOME_LOCATION}
    Set Test Variable    ${SOFTWARE_DWNLD_URL_PREFIX}    ${SOFTWARE_DWNLD_URL_PREFIX_CPESI}

Make sure that STB is running with given version reverting CDN redirection
    [Documentation]    This keyword reverts the changes made to the CDN_HOME_LOCATION and SOFTWARE_DWNLD_URL_PREFIX
    ...    variables in the test scope before making sure the STB is running the version defined in the VERSION variable.
    Set Test Variable    ${CDN_HOME_LOCATION}    ${INITIAL_CDN_HOME_LOCATION}
    Set Test Variable    ${SOFTWARE_DWNLD_URL_PREFIX}    ${INITIAL_SOFTWARE_DWNLD_URL_PREFIX}
    Make sure that STB is running with given version
