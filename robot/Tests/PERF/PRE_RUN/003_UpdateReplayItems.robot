*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        SETUP_UPDATE_REPLAY_ITEMS    SETUP    SETUP_UK
Resource          ./Settings.robot

#Author              Shanu Mopila


*** Test Cases ***
Update Replay contents for Continue Watching
    [Documentation]    Add item to continue watching and find a replay asset for playback
    [Setup]    Default First TestCase Setup
    :FOR    ${index}    in RANGE    0    25
#    \   I Tune To Random Replay Channel
    \   Run Keyword If    '${COUNTRY}' == 'ch'    Run Keyword And Assert Failed Reason    tune to channel ${CHANNEL_ZAP_SINGLE_DIGIT_INIT_CHANNEL}    'Failed to tune to predefined channel.'
    \   ...    ELSE    I Tune To Random Replay Channel
    \   ${channel_id}   get main session ref id via vldms    ${STB_IP}    ${CPE_ID}
    \   ${timestamp}    robot.libraries.DateTime.get current date    result_format=%Y-%m-%d %H:%M:%S
    \   ${timestamp}    DateTime.Convert date    ${timestamp}    epoch
    \   ${timestamp}    Convert to integer    ${timestamp}
    \   ${events}    Get channel events via As    ${STB_IP}    ${CPE_ID}    ${channel_id}    ${timestamp}    events_before=2
    \   ...    events_after=0    xap=${XAP}
    \   ${cw_event_details}   set variable   @{events}[0]
    \   ${duration}   robot.libraries.DateTime.Subtract Date From Date     &{cw_event_details}[endTime]     &{cw_event_details}[startTime]
    \   exit for loop if  ${duration} > 1799
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    Set Profile Bookmark For An Asset Based On Percentage    replay    &{cw_event_details}[eventId]    ${duration}     30    ${cpe_profile_id}
    ...    channel_id=&{cw_event_details}[channelId]
    update test config     SAVED_CONTINUE_WATCHING_REPLAY_ASSET    &{cw_event_details}[title]
    log to console    SAVED_CONTINUE_WATCHING_REPLAY_ASSET: &{cw_event_details}[title]

Update asset for Replay TV
    [Documentation]    Find asset for replay tv
     I open guide through main menu
     I focus previous event in the tv guide
     ${event_name}    I retrieve value for key 'textValue' in element 'id:guideInfoPanelTitle'
     Log   ${event_name}
     update test config     TV_GUIDE_REPLAY_ASSET    ${event_name}
     update test config     TV_GUIDE_REPLAY_CHANNEL    ${TUNED_CHANNEL_NUMBER}
     log to console    TV_GUIDE_REPLAY_CHANNEL: ${TUNED_CHANNEL_NUMBER}
     log to console    TV_GUIDE_REPLAY_ASSET: ${event_name}