*** Settings ***
Documentation     Keywords for Replay TV
Resource          ../PA-18_Replay_TV/ReplayTV_Implementation.robot
Library           Libraries.MicroServices.ReplayCatalogService

*** Keywords ***
Replay Specific Teardown
    [Documentation]    Teardown steps for tests that need to unsubscribe from
    ...    replay products
    delete products by feature    Replay    ${LAB_TYPE}    ${CPE_ID}
    Default Suite Teardown

I am subscribed to replay products
    [Documentation]    This Keyword is used to add replay product via ITC tool
    add products by feature    Replay    ${LAB_TYPE}    ${CPE_ID}

Replay Details Page is shown     #USED
    [Documentation]    Verify the Details Page is shown
    Common Details Page elements are shown
    Wait Until Keyword Succeeds And Verify Status   ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Asset is not replay enabled    I expect page contains 'id:replayIconprimaryMetadata'

I open Details Page for a past replay event     #USED
    [Documentation]    Open the detail page for the focused replay event
    I focus past replay event
    I Press    INFO
    Linear Details Page is shown

'WATCH' action is focused
    [Documentation]    This keyword verifies if the 'WATCH' action is focused
    Section is focused    DIC_ACTIONS_WATCH    textKey

'REPLAY' action is focused
    [Documentation]    This keyword verifies if the 'REPLAY' action is focused
    Section is focused    DIC_ACTIONS_REPLAY    textKey

I Open the replay detail page of Now event
    [Documentation]    Opens the detail page for the focused replay Now event
    ...    Precondition: The Now event should be focused in Channel Bar
    I Press    OK
    Replay Details Page is shown

I Open Replay Detail Page    #USED
    [Documentation]    Opens the detail page for the focused replay Past event
    ...    Precondition: The Past event should be focused in Channel Bar
    I Press    INFO
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Replay Details Page is shown

I open episode picker
    [Documentation]    Focus and open the episode picker from within the details page
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_DETAIL_EPISODE_PICKER_BTN'
    Move to element assert focused elements    textKey:DIC_DETAIL_EPISODE_PICKER_BTN    4    RIGHT
    I Press    OK
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:EpisodePicker.View' contains 'id:seasonListContainer-EpisodePicker'

past programmes with replays available are shown
    [Documentation]    Check we have duration fields that shows past events and the 'G' replay figure added to the title text
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:episodeList-EpisodePicker'
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:titleNodeepisode_item.*' contains 'iconKeys:REPLAY' using regular expressions
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:durationNodeepisode_item.*' contains 'textKey:DIC_GENERIC.*' using regular expressions

I focus programme with future replay event available in TV Guide
    [Documentation]    Focuses on future replay event on the TV Guide grid
    I focus Next event
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:replayIcongridPrimaryMetadata' contains 'iconKeys:REPLAY'
    Next event is focused on TV Guide

Replay icon is shown on the TV Guide    #USED
    [Documentation]    Verifies the presence of the Replay icon in the TV Guide for Replay Events
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:replayIcongridPrimaryMetadata'
    wait until keyword succeeds    10 times    1 sec    I expect page element 'id:replayIcongridPrimaryMetadata' contains 'iconKeys:REPLAY'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:nowiconSpacergridPrimaryMetadata'

Replay icon is not shown on the TV Guide
    [Documentation]    This keyword verifies that the Replay icon is not shown in the TV Guide for Replay Events.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page element 'id:replayIcongridPrimaryMetadata' contains 'iconKeys:REPLAY'

Replay Catalogue grid is opened
    [Documentation]    Verify the replay catalogue grid is opened and shown
    wait until keyword succeeds    10 times    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:ReplayCatalog.View'

Replay Catalogue grid is validated
    [Documentation]    Validate the elements of the replay catalogue grid
    # Wait until we know the json has the minimal highlighted elements in
    wait until keyword succeeds    10 times    ${JSON_RETRY_INTERVAL}    I expect page contains 'color:${INTERACTION_COLOUR}'
    ${json_object}    Get Ui Json
    ${is_search_icon_present}    Is In Json    ${json_object}    id:gridNavigation_searchIcon    textValue:x
    ${is_dates_filter_present}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_FILTER_ALL_DATES
    ${is_channels_filter_present}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_FILTER_ALL_CHANNELS
    ${is_sort_filter_present}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_SORT_POPULARITY
    should be true    ${is_search_icon_present}
    should be true    ${is_dates_filter_present}
    should be true    ${is_channels_filter_present}
    should be true    ${is_sort_filter_present}

I am able to navigate around the replay catalogue grid
    [Documentation]    User is able to navigate within the replay catalogue grid
    # Wait until we know the json has the minimal highlighted elements in
    wait until keyword succeeds    10 times    ${JSON_RETRY_INTERVAL}    I expect page contains 'color:${INTERACTION_COLOUR}'
    ${focused_element_default}    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Get Focused Tile
    I press    RIGHT
    wait until keyword succeeds    10 times    1s    Assert focused elements changed    ${LAST_FETCHED_FOCUSED_ELEMENTS}
    ${focused_element_right}    Get Focused Tile
    I press    DOWN
    wait until keyword succeeds    10 times    1s    Assert focused elements changed    ${LAST_FETCHED_FOCUSED_ELEMENTS}
    ${focused_element_down}    Get Focused Tile
    I press    LEFT
    wait until keyword succeeds    10 times    1s    Assert focused elements changed    ${LAST_FETCHED_FOCUSED_ELEMENTS}
    ${focused_element_left}    Get Focused Tile
    I press    UP
    wait until keyword succeeds    10 times    1s    Assert focused elements changed    ${LAST_FETCHED_FOCUSED_ELEMENTS}
    ${focused_element_up}    Get Focused Tile
    Should match    ${focused_element_up}    ${focused_element_default}    Initial tile element doesnt match the final tile element

I open Replay TV Catalogue from Main Menu
    [Documentation]    This keyword opens 'Replay TV' and check if 'Replay Catalogue' grid is opened.
    I open Main Menu
    I focus Replay TV
    I press    OK
    Replay Catalogue grid is opened

I open Replay TV asset
    [Documentation]    This keyword opens ${REPLAY_SERIES_ASSET_TITLE} asset. Then expects that opened page contains 'DIC_GENERIC_EP_NUMBER'.
    ...    Then retrieves current episode name from 'INFO' page and stores it as ${EPISODE_NAME_ON_INFO_PAGE} variable.
    ...    NOTE: ${REPLAY_SERIES_ASSET_TITLE} is set in implementation.robot
    ...    NOTE: ${max_assets_in_replay_tv} is set in implementation.robot
    Move to element assert focused elements    title:${REPLAY_SERIES_ASSET_TITLE}    ${max_assets_in_replay_tv}    RIGHT
    I press    OK
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_GENERIC_EP_NUMBER'
    ${EPISODE_NAME_ON_INFO_PAGE}    Get episode name from 'INFO' page
    Set Test Variable    ${EPISODE_NAME_ON_INFO_PAGE}

The most relevant episode is shown
    [Documentation]    This keyword compares focused episode name with an episode from 'INFO' page,
    ...    then retrieves name for every episode from current page,
    ...    then compares every extracted name with episode name from 'INFO' page,
    ...    if names match then keyword passes index ${index} to keyword 'Validate that episode is relevant'.
    ...    NOTE: Value for argument ${MAX_EPISODES_ON_ALL_EPISODES_PAGE} is set in implementation.robot
    ...    Pre-reqs: UI state from 'ALL EPISODES' page should be available in ${LAST_FETCHED_JSON_OBJECT} variable as JSON.
    ...    Variable ${EPISODE_NAME_ON_INFO_PAGE} should contain episode name from 'INFO' page.
    ...    'ALL EPISODES' page should be opened.
    Compare focused episode name from 'ALL EPISODES' page with episode from 'INFO' page
    : FOR    ${index}    IN RANGE    0    ${MAX_EPISODES_ON_ALL_EPISODES_PAGE}
    \    ${episode_title}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:titleNodeepisode_item_${index}    textValue
    \    ${status}    ${value}    Run Keyword And Ignore Error    Should Be Equal As Strings    ${episode_title.strip()}    ${EPISODE_NAME_ON_INFO_PAGE}
    \    Run Keyword If    '${status}' == 'PASS'    Run Keywords    Validate that episode is relevant    ${index}
    \    ...    AND    Exit For Loop
    Should Be True    ${index+1} < ${MAX_EPISODES_ON_ALL_EPISODES_PAGE}    There are no matches on current page for episode from 'INFO' page.

I set the audio language in the Action Menu to
    [Arguments]    ${audio_language}
    [Documentation]    This keyword sets the Audio language via Action Menu to '${audio_language}'
    ${audio_language}    convert to lowercase    ${audio_language}
    ${is_hoh}    run keyword and return status    should contain    ${audio_language}    hoh
    @{temp}    run keyword if    ${is_hoh}    Split String    ${audio_language}    separator=hoh
    ${audio_language}    set variable if    ${is_hoh}    @{temp}[0]    ${audio_language}
    ${default_audio_language_textkey}    Get default Audio language textkey from Linear Detail Page
    return from keyword if    '${default_audio_language_textkey}' == '${${${audio_language}}}'
    ${hoh_id}    run keyword if    ${is_hoh}    Get hard of hearing id for language    ${audio_language}
    ${textKey_value}    set variable if    '${audio_language}'=='off'    DIC_DISABLED    ${${${audio_language}}}
    ${nav_key}    set variable if    ${is_hoh}    id:${hoh_id}    textKey:${textKey_value}
    Move Focus to Setting    textKey:DIC_ACTIONS_LANGUAGE_OPTIONS_AUDIO    DOWN
    I Press    OK
    ${is_focused}    run keyword and return status    Move Focus to Option in Value Picker    ${nav_key}    DOWN    3
    run keyword unless    ${is_focused}    Move Focus to Option in Value Picker    ${nav_key}    UP    4
    I Press    OK
    ${default_audio_language_textkey}    Get default Audio language textkey from Linear Detail Page
    run keyword if    '${default_audio_language_textkey}' != '${textKey_value}'    fail test    Newly set Audio language not reflected in Linear Detail Page

The '${language}' Audio language is focused
    [Documentation]    This keyword verifies that the given audio language is set for the channel
    'Audio' action is shown
    ${ancestor}    I retrieve json ancestor of level '2' for element 'textKey:DIC_ACTIONS_LANGUAGE_OPTIONS_AUDIO'
    ${present_audio_language}    Extract Value For Key    ${ancestor}    id:settingFieldValueText_undefined    dictionnaryValue
    Should Be Equal As Strings    '${present_audio_language}'    '${language}'    Newly set Audio language not reflected in Linear Detail Page

I tune to audio subtitle test replay channel
    [Documentation]    This keyword tunes to a replay channel which is having both subtitle and audio language settings
    I tune to channel    ${AUDIO_SUBTITLE_REPLAY_CHANNEL}

I Navigate To Replay '${asset_type}' In Replay Catalog    #USED
    [Documentation]    This keyword opens replay asset in replay catalog.
    ...    It takes one argument ${asset_type} : show/asset
    ${replay_event}    I Get Replay Catalogue Program    ${asset_type}
    Set Suite Variable    ${REPLAY_ASSET}     ${replay_event}
    Log    Replay asset details: ${REPLAY_ASSET}
    Move Focus to Collection with Tile    ${REPLAY_ASSET['name']}    title
    ${tile_pos}    Get Tile Position in Collection    ${REPLAY_ASSET['name']}    title
    Move Focus to Tile Position in Replay Catalog    ${tile_pos}

Verify bookmark For Replay Asset From BO    #USED
    [Documentation]    This keyword will check whether bookmarks has been set for replay asset
    ...   precondition: 'FILTERED_REPLAY_EVENT', tuned replay event
    ...   we are setting it as a suite variable while tunning to the event.
    Variable Should Exist    ${FILTERED_REPLAY_EVENT}    Variable 'FILTERED_REPLAY_EVENT' is not set.
    ${bookmarks}    Fetch All Bookmarks For The Profile    replay
    Should Not Be Empty    ${bookmarks}    No bookmark has been created
    ${content_id}    Set Variable    ${FILTERED_REPLAY_EVENT['id']}
    :FOR    ${event}    IN    @{bookmarks}
    \    Exit For Loop If    '${event['contentId']}' == '${content_id}'
    Should Be Equal    ${event['contentId']}    ${content_id}    Bookmark is not set on the replay asset.

Set Bookmarks At '${percentage}' For A Replay Asset    #USED
    [Documentation]    This keyword sets bookmark based on profile id for Replay Asset whose
    ...   crid_id='FILTERED_REPLAY_EVENT['id']', content identifier which is set during tunning to replay event.
    ...   It takes one perameterised argument i.e percentage at which bookmarks need to be set.
    ...   Precondition: The 'FILTERED_REPLAY_EVENT}' variable must have been set before.
    Variable Should Exist    ${FILTERED_REPLAY_EVENT}    Variable 'FILTERED_REPLAY_EVENT' is not set.
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${content_id}     Run Keyword And Return Status    Dictionary Should Contain Key    ${FILTERED_REPLAY_EVENT}    id
    ${content_id}    Run Keyword If    ${content_id}    Set Variable    ${FILTERED_REPLAY_EVENT['id']}
    ...    ELSE    Set Variable    ${FILTERED_REPLAY_EVENT['eventId']}
    ${start_time}    Get From Dictionary    ${FILTERED_REPLAY_EVENT}    startTime
    ${end_time}    Get From Dictionary    ${FILTERED_REPLAY_EVENT}    endTime
    ${event_duration}    Evaluate    ${end_time} - ${start_time}
    ${season_id}    Evaluate    ${FILTERED_REPLAY_EVENT}.get("seriesId", ${None})
    ${show_id}    Evaluate    ${FILTERED_REPLAY_EVENT}.get("parentSeriesId", ${None})
    ${status}    Run Keyword And Return Status    Should Be Equal As Strings    ${show_id}    ${None}
    ${show_id}    Set Variable If    ${status}    ${season_id}    ${show_id}
    ${season_id}    Set Variable If    ${status}    ${None}    ${season_id}
    ${episode_number}    Evaluate    ${FILTERED_REPLAY_EVENT}.get("episodeNumber", ${None})
    ${season_number}    Evaluate    ${FILTERED_REPLAY_EVENT}.get("seasonNumber", ${None})
    Set Profile Bookmark For An Asset Based On Percentage    replay    ${content_id}
    ...    ${event_duration}    ${percentage}    ${cpe_profile_id}    ${season_id}    ${show_id}
    ...    ${episode_number}    ${season_number}

Watch Complete Replay Event And Verify Watch Again    #USED
    [Documentation]    This keyword will play the total content of replay asset
    ...   by drag and drop for 15 seconds and varifies Watch again in the screen.
    I press FFWD to forward till the end
    Dismiss Delayed Toast Message If Present And Exit Playback
    Replay Details Page is shown
    'WATCH AGAIN' Action Is Shown

Verify Bookmark Of A Replay TV Asset Titled '${title}' In Position '${position}' From Time '${progressbar_time}' In Continue Watching Section    #USED
    [Documentation]    This keyword verifies that the last watched asset is present as the first tile in the
    ...    continue watching section or navigates to asset with given title in saved page.It is verified that when being played, the asset starts from where it has stopped
    ...    precondition: continue watching section is open
    ...    PARAMETERS title: title of the asset for which bookmark has to be verified
    ...    position: if 1, verifies bookmark for the first tile in continue watching section, otherwise navigates to given title
    ...    in saved page and verifies bookmark
    Verify Bookmark Of An Asset Based On Position In Saved Page    ${title}    ${progressbar_time}    ${position}

Get Details For A Replay Catalog Asset    #USED
    [Documentation]    This keyword gets the details of the replay catalog asset using linear service
    Variable Should Exist    ${REPLAY_ASSET}    variable 'REPLAY_ASSET' doesn't exist
    ${response}    Get Most Relevant Instance For ${REPLAY_ASSET['id']} and ${REPLAY_ASSET['type']}
    ${most_relevant_instance}    Set Variable    ${response.json()['mostRelevantInstances']}
    ${event_details}    Get Details Of An Event Based On Event ID    ${most_relevant_instance[0]['eventId']}
    Set Suite Variable   ${FILTERED_REPLAY_EVENT}    ${event_details}

#***************************************************CPE PERFORMANCE************************************************
Get position of Tile with no bound App
    [Documentation]      Get the catchup asset which is not bound to any app
    ${bound_channels}    I Fetch All App Bound Channels ID From Linear Service
    Log    ${bound_channels}
    I Press     RIGHT
    I Press     DOWN
    I Press     DOWN
    Get Ui Focused Elements
    ${tiles}    Extract Value For Key    ${LAST_FETCHED_FOCUSED_ELEMENTS}    id:shared-CollectionsBrowser    data
    : FOR    ${index}  ${tile}    IN ENUMERATE    @{tiles}
    \    continue for loop if      ${index} == ${0}
    \    ${channel_id}    Extract Value For Key    ${tile}    ${EMPTY}    id
    \    ${channel_id}    convert to string     ${channel_id}
    \    ${position}    Set Variable If    '${channel_id}' in ${bound_channels}    ${-1}    ${index}
    \    exit for loop if   ${position} > ${0}
    should be true      ${position} > ${0}
    [Return]      ${position}