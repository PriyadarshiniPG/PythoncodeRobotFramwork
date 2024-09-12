*** Settings ***
Documentation     Voice Implementation keywords
Resource          ../Common/Common.robot
Library           Libraries.Stb.VoiceRecognitionJsonLoader

*** Variables ***
${VOICE_KEY_INJECTOR_URL}    http://localhost:10014/keyinjector/emulateuserevent/64/
${VREX_DBUS_OBJECT}    /vrex com.lgi.rdk.vrex.

*** Keywords ***
Update d-bus config for voice testing
    [Documentation]    This keyword updates the d-bus config for voice testing
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    mount -o remount rw /; sed -i 's/ receive_sender="onemw.vrex"//g' /etc/dbus-1/system.d/mainapp.conf; wait
    Remote.close connection    ${STB_IP}    ${ssh_handle}

Voice Suite Setup
    [Documentation]    Suite Setup specific to Voice tests in which dbus access is needed.
    Default Suite Setup
    Update d-bus config for voice testing

Voice Specific Teardown
    [Documentation]    Teardown Specific to Voice in which dbus access was enabled in the setup.
    Reset All Recordings
    I reboot the STB
    I wait until stb is up and running
    Default Suite Teardown

Voice App Specific Test Teardown
    [Documentation]    Teardown for voice test cases that open Applications
    ${fullscreen_is_shown}    run keyword and return status    Fullscreen is shown
    return from keyword if    ${fullscreen_is_shown}
    @{exit_keys}    Create List    LIVETV    CHANNELUP    GUIDE
    : FOR    ${key}    IN    @{exit_keys}
    \    I exit app through    ${key}
    \    ${channel_bar_open}    run keyword and return status    I open Channel Bar
    \    run keyword if    ${channel_bar_open}    I press    BACK
    \    ${fullscreen_is_shown}    run keyword and return status    Fullscreen is shown
    \    return from keyword if    ${fullscreen_is_shown}
    Restart UI via command over SSH

Send DBUS Signal
    [Arguments]    ${ssh_handle}    ${signal_object}    ${signal_value}    ${sleep_time}=1
    [Documentation]    This keyword is used to insert a DBUS signal into the
    ...    DBUS object defined in ${signal_object}.
    ...    ${signal_value} carries the data/value to insert.
    ...    ${sleep_time} specifies the amount of time to wait for the operation
    ...    to complete.
    ...    Pre-reqs: The remote connection is open
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    dbus-send --system --type=signal ${signal_object} ${signal_value} sleep ${sleep_time}; wait

Send Voice Command
    [Arguments]    ${command}    ${end_sleep}=3
    [Documentation]    This keyword performs the sequence of actions to insert
    ...    a precooked nuance response signal defined in ${command}.
    ...    ${end_sleep} carries the final sleep time to finish the transaction,
    ...    default value of 3 fits most scenarios.
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}
    Remote.start_command    ${STB_IP}    ${ssh_handle}    curl ${VOICE_KEY_INJECTOR_URL}8000; dbus-send --system ${VREX_DBUS_OBJECT}BeginningOfSpeech uint64:0 uint64:59; sleep 1; wait
    Send DBUS Signal    ${ssh_handle}    ${VREX_DBUS_OBJECT}EndOfSpeech    uint64:0 uint64:59;    ${1}
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    curl ${VOICE_KEY_INJECTOR_URL}8100
    Send DBUS Signal    ${ssh_handle}    ${VREX_DBUS_OBJECT}SpeechResult    uint64:1 string:'${command}' uint64:0 uint64:59;    ${0}
    Send DBUS Signal    ${ssh_handle}    ${VREX_DBUS_OBJECT}TransactionComplete    uint64:59;    ${end_sleep}
    Remote.close connection    ${STB_IP}    ${ssh_handle}
