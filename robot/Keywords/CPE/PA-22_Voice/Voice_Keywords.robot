*** Settings ***
Resource          ../PA-22_Voice/Voice_Implementation.robot

*** Keywords ***
Voice indicator is shown
    [Documentation]    Verifies if the voice indicator is shown
    wait until keyword succeeds    10 times    300 ms    I expect page element 'id:VoiceReceiver.Popup' contains 'iconKeys:MIC_VOICE'

I open voice '${times}' times
    [Documentation]    Opens voice control menu '${times}' times
    : FOR    ${_}    IN RANGE    ${times} - 1
    \    I press    VOICE
    \    Voice indicator is shown
    \    wait until keyword succeeds    10 times    500 ms    I do not expect page contains 'iconKeys:MIC_VOICE'
    I press    VOICE

I use voice to open YouTube
    [Documentation]    Insert precooked Nuance response for the YouTube App
    ...    voice command by dbus injection
    I have agreed with Apps Opt-In conditions
    ${vrex_command}    Get Voice Recognition Json Command    youtube.json
    Send Voice Command    ${vrex_command}

I Open Guide via voice command
    [Documentation]    Insert precooked Nuance response for the 'Guide' voice
    ...    command by dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    guide.json
    Send Voice Command    ${vrex_command}

I Open On Demand via voice command
    [Documentation]    Insert precooked Nuance response for the 'On Demand' voice
    ...    command by dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    ondemand.json
    Send Voice Command    ${vrex_command}

I use voice to tune to channel 513
    [Documentation]    Insert precooked Nuance response for tuning to channel 513
    ...    voice command by dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    tuneto513.json
    Send Voice Command    ${vrex_command}

I open Main Menu via voice command
    [Documentation]    Insert precooked Nuance response for the 'Main Menu' voice
    ...    command by dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    mainmenu.json
    Send Voice Command    ${vrex_command}

I open Apps via voice command
    [Documentation]    Insert precooked Nuance response for the 'Apps' voice command
    ...    by dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    apps.json
    Send Voice Command    ${vrex_command}

I use voice to search for cartoons
    [Documentation]    Insert precooked Nuance response to
    ...    a cartoons search voice command by dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    search_cartoons.json
    Send Voice Command    ${vrex_command}

I use voice to Stop
    [Documentation]    Insert precooked Nuance response to response for the
    ...    'Stop' voice command by dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    stop.json
    Send Voice Command    ${vrex_command}
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:voiceIconCircle'

I use voice to Play
    [Documentation]    Insert precooked Nuance response for the 'Play' voice command via
    ...    dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    play.json
    Send Voice Command    ${vrex_command}
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:playerUIContainer-Player'

I use voice to Record
    [Documentation]    Insert precooked Nuance response for the 'Record' voice command via
    ...    dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    record.json
    Send Voice Command    ${vrex_command}

I use voice to Pause
    [Documentation]    Insert precooked Nuance response for the 'Pause' voice command via
    ...    dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    pause.json
    Send Voice Command    ${vrex_command}
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:playerUIContainer-Player'

I use voice to Rewind
    [Documentation]    Insert precooked Nuance response for the 'Rewind' voice command via
    ...    dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    rewind.json
    Send Voice Command    ${vrex_command}

I open Recordings via voice command
    [Documentation]    Insert precooked Nuance response for the 'Recordings' voice
    ...    command via dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    recorded.json
    Send Voice Command    ${vrex_command}

I use voice to tune to channel BBC
    [Documentation]    Insert precooked Nuance response for tuning to channel BBC
    ...    voice command by dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    tunetobbc.json
    Send Voice Command    ${vrex_command}

I use voice to go back to Live TV
    [Documentation]    Insert precooked Nuance response for the 'Back to Live TV' voice
    ...    command via dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    livetv.json
    Send Voice Command    ${vrex_command}

I use voice to turn on subtitles
    [Documentation]    Insert precooked Nuance response for the 'Subtitles on' voice
    ...    command via dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    subtitleson.json
    Send Voice Command    ${vrex_command}

I use voice to skip forward 10 seconds
    [Documentation]    Insert precooked Nuance response to skip video 10 seconds forward
    ...    using a voice command via dbus injection
    I switch Player to PLAY mode
    ${PLAYER_PROGRESS_TIME}    Get linear player viewing progress indicator time
    Set test variable    ${PLAYER_PROGRESS_TIME}
    ${vrex_command}    Get Voice Recognition Json Command    skipforward10seconds.json
    Send Voice Command    ${vrex_command}

I use voice to skip back 10 seconds
    [Documentation]    Insert precooked Nuance response to skip video 10 seconds back
    ...    using a voice command via dbus injection
    I switch Player to PLAY mode
    ${PLAYER_PROGRESS_TIME}    Get linear player viewing progress indicator time
    Set test variable    ${PLAYER_PROGRESS_TIME}
    ${vrex_command}    Get Voice Recognition Json Command    skipback10seconds.json
    Send Voice Command    ${vrex_command}

I use voice to say 'blah blah'
    [Documentation]    Insert precooked Nuance response that doesn't correspond
    ...    with any intent via dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    blahblah.json
    Send Voice Command    ${vrex_command}

I use voice to turn off subtitles
    [Documentation]    Insert precooked Nuance response for 'Subtitles off' voice
    ...    voice command via dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    subtitlesoff.json
    Send Voice Command    ${vrex_command}

I use voice to stop Recording
    [Documentation]    Insert precooked Nuance response for the 'Stop recording' command via
    ...    dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    stoprecording.json
    Send Voice Command    ${vrex_command}

I open Rented via voice command
    [Documentation]    Insert precooked Nuance response for the 'Rentals' voice
    ...    command via dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    rentals.json
    Send Voice Command    ${vrex_command}

I use the Show Info voice command
    [Documentation]    Insert precooked Nuance response for the 'Show Info' voice
    ...    command via dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    showinfo.json
    Send Voice Command    ${vrex_command}

I use voice to Fast Forward
    [Documentation]    Insert precooked Nuance response for the 'Fast Forward' command via
    ...    dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    fastforward.json
    Send Voice Command    ${vrex_command}

I use voice to Resume
    [Documentation]    Insert precooked Nuance response for the 'Resume' command via
    ...    dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    resume.json
    Send Voice Command    ${vrex_command}
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:playerUIContainer-Player'

I use voice to Shutdown the STB
    [Documentation]    Insert precooked Nuance response for the 'Shutdown' command via
    ...    dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    fxxk_off.json
    Send Voice Command    ${vrex_command}

I use voice to Go Back
    [Documentation]    Insert precooked Nuance response for the 'Go Back' command via
    ...    dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    goback.json
    Send Voice Command    ${vrex_command}

I use voice to Restart the player
    [Documentation]    Insert precooked Nuance response for the 'Restart' command via
    ...    dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    restart.json
    Send Voice Command    ${vrex_command}

I use voice to turn off audio description
    [Documentation]    Insert precooked Nuance response for 'Audio Description off' voice
    ...    command via dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    audiodescriptionoff.json
    Send Voice Command    ${vrex_command}

I use voice to move '${direction}' in the Guide
    [Documentation]    Insert precooked Nuance response for moving in the given ${direction} via
    ...    voice command via dbus injection
    ${lowercase_direction}    convert to lowercase    ${direction}
    ${vrex_command}    Get Voice Recognition Json Command    move_${lowercase_direction}.json
    Send Voice Command    ${vrex_command}

I use voice to jump to Tomorrow in the Guide
    [Documentation]    Insert precooked Nuance response for 'Tomorrow' voice command
    ...    via dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    tomorrow.json
    Send Voice Command    ${vrex_command}

I Open Settings via voice command
    [Documentation]    Insert precooked Nuance response for the 'Settings' voice
    ...    command by dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    settings.json
    Send Voice Command    ${vrex_command}

I Open Replay TV via voice command
    [Documentation]    Insert precooked Nuance response for the 'Replay TV' voice
    ...    command by dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    replaytv.json
    Send Voice Command    ${vrex_command}

I Open Watchlist via voice command
    [Documentation]    Insert precooked Nuance response for the 'Watchlist' voice
    ...    command by dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    watchlist.json
    Send Voice Command    ${vrex_command}

I use voice to move Back to Top
    [Documentation]    Insert precooked Nuance response for 'Top' voice command
    ...    via dbus injection
    ${vrex_command}    Get Voice Recognition Json Command    backtotop.json
    Send Voice Command    ${vrex_command}

I use voice to Switch Back the channel
    [Documentation]    Insert precooked Nuance response for 'Switch back' voice command
    ...    via dbus injection
    Set test variable    ${PREVIOUS_CHANNEL_NUMBER}    ${TUNED_CHANNEL_NUMBER}
    ${vrex_command}    Get Voice Recognition Json Command    switchback.json
    Send Voice Command    ${vrex_command}
