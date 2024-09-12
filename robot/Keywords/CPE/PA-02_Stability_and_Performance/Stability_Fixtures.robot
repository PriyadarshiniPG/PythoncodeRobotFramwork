*** Settings ***
Documentation     Stability Fixtures keyword definitions

*** Keywords ***
Stability Zap Specific Suite Setup
    [Documentation]    This keyword contains the Stability Zap Specific Setup steps for running the
    ...    Stability Zap Specific Tests. Doesn't use JSON.
    ...    Sets ${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN} and ${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP} suite variables
    [Timeout]    ${STABILITY_SUITE_SETUP_TIMEOUT}
    Stability Suite Setup    ${False}    ${False}
    Set Good Channels List Lineup Length
    Set Suite Variable    ${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}    ${True}
    Set Suite Variable    ${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}    ${True}
    Restart UI by rebooting the STB for Stability
    STB Monitoring setup to collect data

Stability Trickplay Specific Suite Setup
    [Documentation]    This keyword contains the Stability Trickplay Specific Setup steps for running the
    ...    Trickplay Specific Tests. Doesn't use JSON.
    ...    Sets @{STABILITY_TRICKPLAY_RECORDING_IDS} suite variable.
    [Timeout]    ${STABILITY_SUITE_SETUP_TIMEOUT}
    Stability Suite Setup
    Reset All Recordings
    Record current event on the trickplay channels
    I wait for ${RECORDING_TRICK_MODE_BUFFER_LENGTH} minutes
    @{stability_trickplay_recording_ids}    Get recording ID list from STB via AS
    should not be empty    ${stability_trickplay_recording_ids}    Recordings not retrieved from AS
    Set Suite Variable    @{STABILITY_TRICKPLAY_RECORDING_IDS}

HDD Stability Suite Setup with channel verification
    [Arguments]    @{channel_list}
    [Documentation]    Calls keyword 'Default Suite Setup with channel verification' then checks the number
    ...    of partial, completed, planned or current recordings on the HDD is 0
    [Timeout]    ${STABILITY_SUITE_SETUP_TIMEOUT}
    Stability Trickplay Specific Suite Setup
    Channel Data Verification    @{channel_list}

Recordings Specific Stability Teardown
    [Documentation]    Contains teardown steps for Recording related Stability tests. If a recording is playing
    ...    any menu or linear player bar that might be present is removed before stopping the recording.
    ...    Recordings are deleted via AS and a check is made via recordings/getCount to ensure there are 0 recordings
    ...    before calling the Default Suite Teardown.
    [Timeout]    ${TIMEOUT_20_MINUTES}
    I press    STOP
    I wait for 5 seconds
    Press 'BACK' for '6' times then tune to '${FREE_CHANNEL_1}'
    There is no recording ongoing in the background
    Stability Suite Teardown

Stability Cold Standby Specific Suite Setup
    [Documentation]    This keyword contains the Stability Cold Standby Specific Setup steps for running the
    ...    Stability Cold Standby Test. Doesn't use JSON. Memory monitoring shouldn't be started.
    [Timeout]    ${STABILITY_SUITE_SETUP_TIMEOUT}
    Stability Suite Setup    ${False}
    Set application services setting    cpe.showColdStandByMessage    ${False}

Stability Lukewarm Standby Specific Suite Setup
    [Documentation]    This keyword contains the Stability Lukewarm Standby Specific Setup steps for running the
    ...    Stability Lukewarm Standby Test. Doesn't use JSON. Memory monitoring shouldn't be started.
    [Timeout]    ${STABILITY_SUITE_SETUP_TIMEOUT}
    Stability Suite Setup    ${False}

Stability Cold Standby Specific Suite Teardown
    [Documentation]    This keyword contains Stability Cold Standby Test specific Teardown Steps. Doesn't use JSON.
    [Timeout]    ${TIMEOUT_20_MINUTES}
    Set application services setting    cpe.showColdStandByMessage    ${True}
    Stability Suite Teardown

Stability Review Buffer Suite Teardown
    [Documentation]    This keyword contains Stability Review Buffer Suite Teardown Steps.
    ...    Tunes to stability test channel ${REVIEW_BUFFER_CHANNEL} then runs Stability Suite Teardown keyword.
    [Timeout]    ${TIMEOUT_20_MINUTES}
    I tune to stability test channel    ${REVIEW_BUFFER_CHANNEL}
    Stability Suite Teardown
