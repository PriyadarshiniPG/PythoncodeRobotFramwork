*** Settings ***
Documentation     This file holds PA-02 reliability implementation keywords which uses JSON(test tools)
Resource          ../PA-22_Voice/Voice_Keywords.robot

*** Keywords ***
I upgrade the stb via acs with
    [Arguments]    ${build_version}
    [Documentation]    This keyword verifies if the ${build_version} is available in CDN and then
    ...    upgrades the STB with the given ${build_version} via ACS
    Verify the build is available in CDN    ${build_version}
    Update via ACS factory reset to    ${build_version}
    run keyword if    ${JSON}    I Want To Enable Json Handler Function
    Set all the tips as already shown in the past via as
    disable tips and tricks

I am able to play different type of channels
    [Documentation]    This keyword verifies the user is able to playback different type of channels
    I tune to channel    ${SD_ALL_SERVICE}
    both audio and video are playing out
    I tune to channel    ${HD_ALL_SERVICE}
    both audio and video are playing out
    I tune to channel    ${IP_CHANNEL}
    both audio and video are playing out

I am able to record and schedule recordings
    [Documentation]    This keyword verifies the user is able to record and schedule recordings
    I record an ongoing event
    I have scheduled a Future complete series recording

I am able to navigate through the guide
    [Documentation]    This keyword verifies the user is able to navigate through the TV Guide
    wait until keyword succeeds    3 times    1 s    I tune to channel with short duration events
    I open Guide through Main Menu
    I focus future event in the tv guide
    I focus past event in the tv guide

I am able to navigate through the replay catalogue
    [Documentation]    This keyword verifies the user is able to navigate through the replay TV catalogue
    wait until keyword succeeds    3 times    1 s    I tune to a channel with replay events
    I open Replay TV Catalogue from Main Menu
    I am able to navigate around the replay catalogue grid

I am able to use the review buffer functionality
    [Documentation]    This keyword verifies the user is able to use the review buffer functionality
    wait until keyword succeeds    3 times    1 s    I tune to a channel with replay events
    wait until keyword succeeds    3 times    1 s    I open Review Buffer Player
    I wait for 5 seconds
    I switch Player to PLAY mode
    I wait for 10 seconds

I am able to playback a past replay event
    [Documentation]    This keyword verifies the user is able to playback a past replay event and switching the playback speeds
    wait until keyword succeeds    3 times    1 s    I start playback of a past replay event from the replay events channel
    I switch Player to x64 FFWD mode
    Player is in 'x64' FFWD mode

I am able to add item to watchlist
    [Documentation]    This keyword verifies the user is able to add items to watchlist and then opens added items in saved.
    wait until keyword succeeds    3 times    1 s    I added one VOD asset to Watchlist
    wait until keyword succeeds    3 times    1 s    I open Watchlist through Saved
    I open VOD tile
    VOD Details page is shown

I am able to add profile with personal line-up
    [Documentation]    This keyword verifies the user is able to add profile with personal line-up and then resets profiles.
    I create a profile with 3 channels
    I tune to the first channel of personal line-up
    Reset profiles

I am able to change the master PIN code
    [Documentation]    This keyword verifies the user is able to change the master PIN code
    wait until keyword succeeds    3 times    1 s    I open Change PIN through 'PARENTAL CONTROL'
    I enter a valid pin
    'Please enter a new 4 digit PIN' code is shown
    I generate a new pin
    I enter the new valid pin
    I Press    OK
    'Please enter your new PIN again' is shown
    I enter the new valid pin
    'PIN changed' toast message is shown

I am able to lock and unlock channels
    [Documentation]    This keyword adds channel to the locked channel list, tunes to this channel and uses master PIN to unlock this channel.
    ...    Then clears locked channel list
    wait until keyword succeeds    3 times    1 s    I add Channel '2' to the Locked channels list through parental control
    I press BACK 2 times
    wait until keyword succeeds    3 times    1 s    I tune to channel    2
    I unlock the channel
    Both Audio and Video are playing out
    wait until keyword succeeds    3 times    1 s    I Clear Locked channel list

I am able to view the recommendations
    [Documentation]    This keyword verifies the user is able to view the contextual recommendation then opens first tile.
    wait until keyword succeeds    3 times    1 s    I focus ON DEMAND through Contextual Main Menu
    Recommended for you is shown
    I open first tile for Recomended for you

I am able to change the age rating
    [Documentation]    This keyword sets age rating of the STB to 6, tunes to channel with AR 9 and checks if channel is locked.
    ...    Then reset the age lock via AS
    wait until keyword succeeds    3 times    1 s    I set age rating of the STB to    6
    wait until keyword succeeds    3 times    1 s    I tune to channel with AR 9
    Age rated programme is Locked
    I Set Age Rating Of The STB To Off

I am able to use voice commands
    [Documentation]    This keyword verifies the user is able to use voice commands using the remote by opening the main menu
    Update d-bus config for voice testing
    wait until keyword succeeds    3 times    1 s    I tune to an unlocked channel
    I open Main Menu via voice command
    Main Menu is shown

I save existing recordings and watchlist data
    [Documentation]    This keyword saves existing recordings and watchlist data
    ...    Then sets ${OLD_RECORDINGS} and ${OLD_WATCHLISTS} suite variables.
    ${current_recordings}    Get recording ID list from STB via AS
    ${watchlist_contents}    Get watchlist content via watchlist service
    set suite variable    ${OLD_RECORDINGS}    ${current_recordings}
    set suite variable    ${OLD_WATCHLISTS}    ${watchlist_contents}

I verify the stb has old recordings and watchlist
    [Documentation]    This keyword verifies the STB has old recordings and watchlist after upgrade
    ...    Pre-reqs: ${OLD_RECORDINGS} and ${OLD_WATCHLISTS} variables should exist.
    variable should exist    ${OLD_RECORDINGS}    Variable OLD_RECORDINGS has not been set.
    variable should exist    ${OLD_WATCHLISTS}    Variable OLD_WATCHLISTS has not been set.
    ${current_recordings}    Get recording ID list from STB via AS
    ${watchlist_contents}    Get watchlist content via watchlist service
    should be equal    ${OLD_RECORDINGS}    ${current_recordings}    OLD_RECORDINGS has not been successfully retained after upgrade.
    should be equal    ${OLD_WATCHLISTS}    ${watchlist_contents}    OLD_WATCHLISTS content has not been successfully retained after upgrade.

I clear existing user related data
    [Documentation]    This keyword clear recordings, watchlist, profiles and unlock history
    There is no unlock history
    Reset Watchlist
    Reset All Recordings
    Reset All Continue Watching Events
    Reset profiles

I perform critical functional validation of the STB
    [Documentation]    This keyword validates the critical functionalities of the STB
    I am able to play different type of channels
    I am able to record and schedule recordings
    I am able to navigate through the guide
    I am able to navigate through the replay catalogue
    I am able to use the review buffer functionality
    I am able to playback a past replay event
    I am able to add item to watchlist
    I am able to view the recommendations
    I am able to add profile with personal line-up
    I am able to change the master PIN code
    I am able to lock and unlock channels
    I am able to change the age rating
    I am able to use voice commands

I perform critical functional validation after software upgrade with
    [Arguments]    ${version}
    [Documentation]    This keyword performs set top box critical functional validation after software upgrade with ${version}
    I save existing recordings and watchlist data
    I upgrade the stb via acs with    ${version}
    I verify the stb has old recordings and watchlist
    I clear existing user related data
    I perform critical functional validation of the STB
