*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        EPGToReplayTV    PROD-NL-SELENE    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-UK-EOS  PREPROD-UK-EOS  PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    VIDEO_PLAYOUT    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PROD-UK-BENTO    PREPROD-UK-BENTO
Resource          ./Settings.robot

#Author              Shanu Mopila


*** Test Cases ***
Launch the TV Guide and navigate to Replay Channel
    [Documentation]    Launch the TV Guide and go to the replay channel
    [Setup]    Default First TestCase Setup
    I open guide through main menu
    I wait for 5 seconds
    ${converted_channel}    Convert To String    ${TV_GUIDE_REPLAY_CHANNEL}
    I tune to ${converted_channel} in the tv guide

Navigate to the replay program
    [Documentation]    Find the replay asset and start playback from beginning
    [Setup]    Skip If Last Fail
    I wait for 5 seconds
    Go to given past event in TV Guide    ${TV_GUIDE_REPLAY_ASSET}

Play from Start a replay asset
    [Documentation]    Start the replay program
    [Setup]    Skip If Last Fail
    I Press    INFO
    I wait for 2 seconds
    I Press    OK
    I wait for 3 seconds
    Handle Popup And Play from Details Page
    set context     EPGToReplayTV
    log action     ReplayTVStarted
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Video playout is started
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify IP is Played via VLDMS
    log action     ReplayTVStarted_Done
    I wait for 5 seconds
    I dismiss video player bar
    I Press     BACK
    I Press     MENU