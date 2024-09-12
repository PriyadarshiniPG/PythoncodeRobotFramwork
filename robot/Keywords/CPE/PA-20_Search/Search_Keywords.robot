*** Settings ***
Documentation     Keywords covering functions of the Search screen
Resource          ../PA-20_Search/Search_Implementation.robot

*** Variables ***
${asset_type}    show

*** Keywords ***
Move Focus to Search Result
    [Arguments]    ${search_result}    ${direction}    ${max_number_of_moves}=${DEFAULT_MAX_VALUE_PICKER_OPTIONS}
    [Documentation]    Navigate in a Search Results to the search result identified by ${search_result} through the direction specified by ${direction}
    ...    Accepts an optional ${max_number_of_moves} positional argument
    Move to element and assert    ${search_result}    color    ${HIGHLIGHTED_NAVIGATION_COLOUR}    ${max_number_of_moves}    ${direction}

'Nothing matches your search' is shown
    [Documentation]    This keyword verifies the message with textKey 'DIC_SEARCH_NO_RESULTS_TITLE' appears
    ...    when there are no matching results.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:searchNoResultsTitle' contains 'textKey:DIC_SEARCH_NO_RESULTS_TITLE'

'${text}' is not listed in Search Results
    [Documentation]    This keyword verifies that no matching results for the Search input field
    '${text}' is shown in the Search input field
    'Nothing matches your search' is shown

The search results are shown for entered query
    [Documentation]    This keyword verifies whether the search results shown match the query.
    ${list_container}    Search executed
    ${nodes}    Set Variable if    '${list_container[0]['id']}' == 'searchResultsList'    ${list_container[0]['children']}    ${list_container}
    Handle Search Results List    ${nodes}

Search executed    #USED
    [Documentation]    This keyword checks whether the search table is present in the UI, checks if the search results are loaded completely,
    ...    and returns the search result list.
    ${ready}    Run keyword and return status    wait until keyword succeeds    10 times    1 sec    I expect page contains 'id:searchItemNode\\\\d+' using regular expressions
    Run keyword if    ${ready} != ${True}    fail    "Search results list not found"
    ${list_container}    I retrieve value for key 'children' in element 'id:searchResultsList'
    ${is_list_updated}    run keyword and return status    wait until keyword succeeds    5 times    400 ms    Assert json node changed    ${list_container}
    ...    searchResultsList    children
    ${updated_list_container}    run keyword if    ${is_list_updated}    I retrieve value for key 'children' in element 'id:searchResultsList'
    ...    ELSE    set variable    ${list_container}
    [Return]    ${updated_list_container}

I focus the first item in the search results
    [Documentation]    This keyword focuses the first item in the search results and
    ...    stores its name in the ${CHANNEL_NAME} variable.
    Dismiss virtual keyboard if visible
    Search executed
    Move Focus to Search Result    id:searchItemNode0    DOWN    3
    ${channel_name_item_0}    Get channel name of first item in search result
    ${channel_name_item_0}    Remove String    ${channel_name_item_0}    <b>    </b>
    Set Global Variable    ${CHANNEL_NAME}    ${channel_name_item_0}

I focus the first VOD asset in the search results
    [Documentation]    This keyword focuses the first VOD asset in the search results
    Dismiss virtual keyboard if visible
    ${search_results}    Search executed
    ${search_results_nodes}    Extract Value For Key    ${search_results}    id:searchResultsList    children
    : FOR    ${search_result_node}    IN    @{search_results_nodes}
    \    ${result_id}    Extract Value For Key    ${search_result_node}    id:searchItemNode\\d+    id    ${True}
    \    ${is_rent}    run keyword and return status    I expect page element 'id:${result_id}' contains 'textKey:DIC_GENERIC_CURRENCY_FORMAT'
    \    ${is_on_demand}    run keyword and return status    I expect page element 'id:${result_id}' contains 'textKey:DIC_SEARCH_VOD_SOURCE'
    \    ${is_vod}    Evaluate    True if ${is_rent} or ${is_on_demand} else False
    \    run keyword if    ${is_vod}    Move Focus to Search Result    id:${result_id}    DOWN    10
    \    exit for loop if    ${is_vod}
    should be true    ${is_vod}    Failed to focus a VOD asset in search results

I open the first item in the search results
    [Documentation]    This keyword opens the first item in the search results
    I focus the first item in the search results
    I press    OK

I open the first VOD item in the search results
    [Documentation]    This keyword opens the first VOD item in the search results
    I focus the first VOD asset in the search results
    I press    OK

I have searched for '${text}'
    [Documentation]    Searches for text on search screen
    Run keyword If    ${USE_DEEPLINKS} == ${False}    Run Keywords    I search for '${text}' using Virtual keyboard
    ...    AND    Return from keyword
    I Open Search through DeepLink    ${text}

I Search For Adult Content    #USED
    [Documentation]    This keyword gets the name of a current adult event and searches for it,
    ...    assuming we are already in the Search screen.
    ${adult_channel}    I Get A Random Adult Channel
    ${channel_id}    Get channel ID using channel number    ${adult_channel}
    @{event_info}    Get current channel event via as    ${channel_id}
    ${event_details_json}    Get Details Of An Event Based On Event ID    ${event_info[0]}
    ${search_query}    Set Variable    ${event_details_json['title'].strip()}
    ${search_query}    Replace String    ${search_query}    ${SPACE}    ±
    I search for '${search_query}' using Virtual keyboard
    Set Suite Variable    ${SEARCH_QUERY}    ${search_query}

Adult content is not shown in search results
    [Documentation]    This keyword verifies that there are no results for the
    ...    current search query value in the ${SEARCH_QUERY} variable.
    wait until keyword succeeds    10 times    0s    There are no results for '${SEARCH_QUERY}'. Please try again. is shown

Series Live TV programme available
    [Documentation]    This keyword gets the currently running event name on a series event channel. Chosen to use
    ...    ${REPLAY_SERIES_CHANNEL} because of its consistency in showing the logo in the search results.
    ${event_name}    i get current event name on    ${REPLAY_SERIES_CHANNEL}
    set test variable    ${SERIES_EVENT}    ${event_name}

Series Live TV programme with episodes available
    [Documentation]    This keyword gets the currently running event name on the ${SERIES_EPISODES_EVENT_CHANNEL}
    ...    channel and stores the event name in the ${SERIES_EVENT} variable.
    series Live TV programme on channel '${SERIES_EPISODES_EVENT_CHANNEL}' with episodes is available

I search for single linear programme
    [Documentation]    This keyword searchs for a single linear programme defined in the ${SINGLE_EVENT_SEARCH_QUERY}
    ...    variable using the Virtual keyboard, assuming we are already in the Search screen.
    I search for '${SINGLE_EVENT_SEARCH_QUERY}' using Virtual keyboard
    I choose GO action on Virtual keyboard
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Virtual Keyboard is not shown

I Focus Exact '${text}' Item In The Search Results With VOD Results '${select_vod}'    #USED
    [Documentation]    This keyword focuses and checks that the search results contains the exact replay/linear item being searched.
    ...    If select_vod is true, search result corresponding to VOD asset with searched string is selected. Otherwise non-VOD entries are
    ...    selected.
    ${vod_select}    Set Variable If    '${select_vod}'=='${True}'    ${True}    ${False}
    Focus The Exact Item In The Search Results    ${text}    ${vod_select}

Focus The Exact Item In The Search Results    #USED
    [Documentation]    This keyword focuses and checks that the search results contains the exact item being searched
    ...    If select_vod is true, search result corresponding to VOD asset with searched string is selected. Otherwise non-VOD entries are
    ...    selected.
    [Arguments]    ${text}    ${select_vod}=${False}
    Dismiss virtual keyboard if visible
    ${search_list}    Search executed
    ${text}    Convert To Lowercase    ${text}
    ${is_child}    Is In Json    ${search_list}    ${EMPTY}    id:searchResultsList
    ${nodes}    Set Variable If    ${is_child}    ${search_list[0]['children']}    ${search_list}
    ${nodes_length}    Get Length    ${nodes}
    : FOR    ${i}    IN RANGE    ${nodes_length}
    \    ${details}    Set Variable    ${nodes[${i}]['children']}
    \    ${date}    Is In Json    ${details}    ${EMPTY}    textKey:DIC_GENERIC_AIRING_DATE_.*    ${None}    ${True}
    \    ${time}    Is In Json    ${details}    ${EMPTY}    textKey:DIC_GENERIC_AIRING_TIME_.*    ${None}    ${True}
    \    ${on_tv}    Is In Json    ${details}    ${EMPTY}    textValue:On TV.*    ${None}    ${True}
    \    ${is_not_vod}    Set Variable If    ${date} or ${time} or ${on_tv}    ${True}    ${False}
    \    Continue For Loop If    ${select_vod} and ${is_not_vod}
    \    Continue For Loop If    ${select_vod}==${False} and ${is_not_vod}==${False}
    \    ${node_text}    Set Variable    ${details[${0}]['textValue']}
    \    ${match}    Get Regexp Matches    ${node_text}    (.*)<font_size.*>.*</font_size>    ${1}
    \    ${font_present}    Run Keyword And Return Status    Should Not Be Empty    ${match}
    \    ${stripped_string}    Run Keyword If    ${font_present}    remove html tag from string    ${match[${0}]}
    ...    ELSE    remove html tag from string    ${node_text}
    \    ${stripped_string}    Convert To Lowercase    ${stripped_string}
    \    ${is_valid}    Run Keyword And Return Status    Should Be Equal As Strings    ${stripped_string}   ${text}
    \    ${result}    Extract Value For Key    ${nodes[${i}]}    textValue:<b>${text}</b>    id
    \    Run Keyword If    ${is_valid}    set test variable    ${SEARCH_RES_ROW_INDEX}    ${i}
    \    Exit For Loop If    ${is_valid}
    Variable Should Exist    ${SEARCH_RES_ROW_INDEX}    searched item is not found in search result
    Log    ${SEARCH_RES_ROW_INDEX}
    ${ancestor}    get ancestor for highlighted element in search window
    : FOR    ${index}    IN RANGE    ${SEARCH_RES_ROW_INDEX + 1}
    \    I Press    DOWN
    \    ${ancestor}    get ancestor for highlighted element in search window
    \    Log    ${ancestor}

I focus single linear programme in search results
    [Documentation]    This keyword checks that the search results contains the single linear programme defined in the
    ...    ${SINGLE_EVENT_NAME} variable and focuses it.
    I Focus Exact '${SINGLE_EVENT_NAME}' Item In The Search Results With VOD Results '${False}'

I search for series Live TV programme
    [Documentation]    This keyword searches for a series event defined in the ${SERIES_EVENT}
    ...    variable using the Virtual keyboard, assuming we are already in the Search screen.
    I search for '${SERIES_EVENT}' using Virtual keyboard
    I choose GO action on Virtual keyboard

Series Live TV programme is shown in search results
    [Documentation]    This keyword verifies that the search results contains the series event defined in the
    ...    ${SERIES_EVENT} variable and focuses it.
    ${search_list}    Search executed
    ${nodes}    set variable    ${search_list[0]['children']}
    ${nodes_length}    Get Length    ${nodes}
    : FOR    ${i}    IN RANGE    ${nodes_length}
    \    ${node_text}    Set Variable    ${nodes[${i}]['children'][0]['textValue']}
    \    ${stripped_string}    remove html tag from string    ${node_text}
    \    ${is_equal}    evaluate    '${stripped_string}' == '${SERIES_EVENT}'
    \    ${result}    Extract Value For Key    ${nodes[${i}]['children'][0]}    textValue:<b>${SERIES_EVENT}</b>    id
    \    run keyword if    ${is_equal}    set test variable    ${SEARCH_ROW_INDEX}    ${result[-1]}
    \    exit for loop if    ${is_equal}
    ${SEARCH_ROW_INDEX}    Convert to integer    ${SEARCH_ROW_INDEX}
    : FOR    ${index}    IN RANGE    ${SEARCH_ROW_INDEX + 1}
    \    I press    DOWN

Channel name with logo is shown in search results
    [Documentation]    This keyword verifies that the Channel logo is displayed in the search results. Chosen to use
    ...    ${REPLAY_SERIES_CHANNEL} because of its consistency in showing the logo in the search results.
    ${background_image_id}    Catenate    SEPARATOR=    channelLogosearchResultsListNode    ${SEARCH_ROW_INDEX}
    &{background_image}    I retrieve value for key 'background' in element 'id:${background_image_id}'
    ${channel_logo}    set variable    &{background_image}[image]
    ${ch_name}    get channel name with underscore for    ${REPLAY_SERIES_CHANNEL}
    ${channel_logo_name}    Catenate    SEPARATOR=.    ${ch_name}    png
    should contain    ${channel_logo}    ${channel_logo_name}

I open episode picker for linear series programme
    [Documentation]    This keyword verifies the search results contain a series event, focuses said event and
    ...    opens the Details Page, then opens the episode picker.
    series Live TV programme is shown in search results
    I press    OK
    Linear Details Page is shown
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_DETAIL_EPISODE_PICKER_BTN'
    Move to element and assert    textKey:DIC_DETAIL_EPISODE_PICKER_BTN    color    ${HIGHLIGHTED_OPTION_COLOUR}    2    RIGHT
    I press    OK

Specials or episode count is shown in search results
    [Documentation]    This keyword verifies that episode or specials count is displayed in the search results.
    ${element_id}    Catenate    SEPARATOR=    secondaryMetadatasearchResultsListNode    ${SEARCH_ROW_INDEX}
    ${textkey_string}    I retrieve value for key 'textKey' in element 'id:${element_id}'
    ${text_value}    I retrieve value for key 'textValue' in element 'id:${element_id}'
    ${matches}    Get Regexp Matches    ${textkey_string}    DIC_SEARCH_SHOW_EPISODES|DIC_GENERIC_AMOUNT_SPECIALS
    Should Not Be Empty    ${matches}
    ${matches}    Get Regexp Matches    ${text_value}    .*(\\d+ episodes)|.*(\\d+ specials)
    Should Not Be Empty    ${matches}

I search for VOD
    [Documentation]    This keyword searches for the VOD content defined in the ${TILE_TITLE} variable,
    ...    assuming we are already in the Search screen.
    ...    Precondition: Any of the keywords that set the ${TILE_TITLE} variable needs to be called before calling this
    ...    keyword or the variable will be undefined.
    Variable should exist    ${TILE_TITLE}    The title of a VOD asset tile has not been saved. TILE_TITLE does not exist.
    I search for '${TILE_TITLE}' using Virtual keyboard
    I choose GO action on Virtual keyboard

Series VOD is shown in search results
    [Documentation]    This keyword verifies that the search results contains the VOD content defined in the
    ...    ${TILE_TITLE} variable and focuses it.
    Variable should exist    ${TILE_TITLE}    The title of a VOD asset tile has not been saved. TILE_TITLE does not exist.
    ${search_list}    Search executed
    ${nodes}    set variable    ${search_list[0]['children']}
    ${nodes_length}    Get Length    ${nodes}
    : FOR    ${i}    IN RANGE    ${nodes_length}
    \    ${node_text}    Set Variable    ${nodes[${i}]['children'][0]['textValue']}
    \    ${stripped_string}    remove html tag from string    ${node_text}
    \    ${is_equal}    evaluate    '${stripped_string}' == '${TILE_TITLE}'
    \    ${result}    Extract Value For Key    ${nodes[${i}]['children'][0]}    textValue:<b>${TILE_TITLE}</b>    id
    \    run keyword if    ${is_equal}    set test variable    ${SEARCH_ROW_INDEX}    ${result[-1]}
    \    exit for loop if    ${is_equal}
    ${SEARCH_ROW_INDEX}    Convert to integer    ${SEARCH_ROW_INDEX}
    : FOR    ${index}    IN RANGE    ${SEARCH_ROW_INDEX + 1}
    \    I press    DOWN

ON DEMAND source is shown
    [Documentation]    This keyword checks if the textValue 'ON Demand' is shown in the UI.
    ${source_id}    Catenate    SEPARATOR=    secondaryMetadatasearchResultsListNode    ${SEARCH_ROW_INDEX}
    I expect page element 'id:${source_id}' contains 'textValue:On Demand' using regular expressions

I enter search query to find multiple episodes of different seasons
    [Documentation]    This keyword goes to the Search screen and searches for the series defined in the
    ...    ${MULTIPLE_EPISODE_WITH_DIFFERENT_SEASON} variable, then verifies multiple
    ...    episodes of different seasons are shown in the results.
    I open Search through Main Menu
    I search for '${MULTIPLE_EPISODE_WITH_DIFFERENT_SEASON}' using Virtual keyboard
    I choose GO action on Virtual keyboard
    Seasons grouped count is shown in search results

Specific seasons episode items are displayed
    [Documentation]    This keyword verifies that specific season episode items are displayed
    ...    in the episode picker inside the Details Page.
    ${json_object}    Get Ui Json
    ${season}    Extract Value For Key    ${json_object}    id:subTitleInfo-ItemDetails    textValue
    Option is Focused in Value Picker    textValue:${season}
    ${result}    Is In Json    ${json_object}    id:titleNodeepisode_item_\\d    textValue:^.+$    ${EMPTY}    ${True}
    Should Be True    ${result}    Failed to display specific season episode items

I focus a season
    [Documentation]    This keyword verifies that a season is focused in the episode picker inside the Details Page
    I Press    LEFT
    Option is Focused in Value Picker    textKey:DIC_GENERIC_SEASON_NUMBER

I open episode picker to reveal the shows details
    [Documentation]    This keyword opens the Details Page from the search results and attempts to open
    ...    the episode picker, checking that the episodes are shown in the UI.
    I press    OK
    Linear Details Page is shown
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_DETAIL_EPISODE_PICKER_BTN'
    Move Focus to Section    DIC_DETAIL_EPISODE_PICKER_BTN    textKey
    I press    OK
    Option is Focused in Value Picker    id:titleNodeepisode_item_\\\\d+    ${True}

I search for Operator locked channel
    [Documentation]    This keyword searches for the channel name corresponding to the channel defined in the
    ...    ${OPERATOR_LOCKED_CHANNEL} variable, assuming we are already in the Search screen.
    ${channel_name}    lookup channelname for    ${OPERATOR_LOCKED_CHANNEL}
    I search for '${channel_name}' using Virtual keyboard

I search for Adult channel
    [Documentation]    This keyword searches for the channel name corresponding to the channel defined in the
    ...    ${ADULT_CHANNEL} variable, assuming we are already in the Search screen.
    ${channel_name}    lookup channelname for    ${ADULT_CHANNEL}
    I search for '${channel_name}' using Virtual keyboard

I search for HD channel
    [Documentation]    This keyword searches for the channel name corresponding to the channel defined in the
    ...    ${HD_ALL_CHANNEL} variable, assuming we are already in the Search screen.
    ${channel_name}    lookup channelname for    ${HD_ALL_CHANNEL}
    I search for '${channel_name}' using Virtual keyboard

I search for Radio channel
    [Documentation]    This keyword searches for the channel name corresponding to the channel defined in the
    ...    ${RADIO_CHANNEL_SEARCH_QUERY} variable, assuming we are already in the Search screen.
    I search for '${RADIO_CHANNEL_SEARCH_QUERY}' using Virtual keyboard

I search for an Entitled channel
    [Documentation]    This keyword searches for the channel name corresponding to the channel defined in the
    ...    ${LINEAR_CHANNEL} variable, assuming we are already in the Search screen.
    ${channel_name}    lookup channelname for    ${LINEAR_CHANNEL}
    I search for '${channel_name}' using Virtual keyboard

The channel tuned from the search is the channel selected from the search
    [Documentation]    This keyword checks that the channel tuned from the search is the one that we selected from the search and that
    ...    the CPE didn't tune to a different channel.
    ...    Pre-reqs: We're actually tuned to a channel and we tuned to this channel from a search.
    ${tuned_channel_number}    Read channel number from channel bar data
    ${tuned_channel_name}    lookup channelname for    ${tuned_channel_number}
    Should Be Equal    ${CHANNEL_NAME}    ${tuned_channel_name}

'${text}' app logo is shown
    [Documentation]    This keyword verifies that the specified app logo is shown in the current screen
    ${text}    Convert To Lowercase    ${text}
    I expect page element 'id:searchItemNode\\d+' contains 'url:.*app.*${text}.*png.*' using regular expressions

I search for Age rated VOD
    [Documentation]    This keyword searches for the age rated VOD title defined in the
    ...    ${AGE_RATED_VOD_SEARCH_QUERY} variable, assuming we are already in the Search screen.
    I search for '${AGE_RATED_VOD_SEARCH_QUERY}' using Virtual keyboard

I search for a Linear TV asset being shown now
    [Documentation]    This keyword searches for the Linear TV asset being shown now.
    ...    Pre-reqs: We've previously tuned to a live event on a Linear TV channel and we're now on the search screen.
    ${json_object}    Get Ui Json
    ${header}    Extract Value For Key    ${json_object}    id:watchingNow    textValue
    ${watching_now_text}    Split String    ${header}    separator=:
    ${programme_title}    Strip String    ${watching_now_text[1]}
    I search for '${programme_title}' using Virtual keyboard

'${app_name}' app is shown in search results
    [Documentation]    This keyword verifies if the app is listed in search results.
    ...    Precondition: App search results should be available on the screen
    ...    Keyword make sure that the results is having target application by verifying the absence of channel metadata in search result
    I wait for ${APP_SEARCH_WAIT_TIME} seconds
    ${json_object}    Get Ui Json
    ${children}    Extract Value For Key    ${json_object}    id:searchResultsList    children
    ${node_length}    get length    ${children}
    : FOR    ${i}    IN RANGE    ${node_length}
    \    ${search_result}    Extract Value For Key    ${json_object}    id:titlesearchResultsListNode${i}    textValue
    \    ${search_result}    remove html tag from string    ${search_result}
    \    ${linear_metadata}    Extract Value For Key    ${json_object}    id:secondaryMetadatasearchResultsListNode${i}    textValue
    \    ${search_status}    set variable if    '${search_result}'=='${app_name}'    ${True}    ${False}
    \    ${is_app}    set variable if    '${linear_metadata}'==''    ${True}    ${False}
    \    ${is_found}    set variable if    ${is_app}==${True} and ${search_status}==${True}    ${True}    ${False}
    \    exit for loop if    ${is_found}
    should be true    ${is_found}    The searched application is not found in search results

I search for grouped series VOD
    [Documentation]    This keyword searches for VOD series with multiple episodes and/or seasons, like the one
    ...    defined in the ${MULTIPLE_EPISODE_WITH_DIFFERENT_SEASON} variable.
    I search for '${MULTIPLE_EPISODE_WITH_DIFFERENT_SEASON}' using Virtual keyboard
    I press 'Go' on the Virtual Keyboard

'On Demand' label is shown in search results
    [Documentation]    This keyword verifies the 'On Demand' label is shown in the search results for VOD assets.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:searchResultsListScrollableContainer' contains 'id:searchResultsList'
    ${children}    Extract value for key    ${LAST_FETCHED_JSON_OBJECT}    id:searchResultsList    children
    ${node_length}    get length    ${children}
    : FOR    ${id}    IN RANGE    ${node_length}
    \    ${on_demand_is_present}    Is In Json    ${children}    id:secondaryMetadatasearchResultsListNode${id}    substitutionTextKeys:.+DIC_SEARCH_VOD_SOURCE.+    ${EMPTY}
    \    ...    ${True}
    \    exit for loop if    ${on_demand_is_present}
    should be true    ${on_demand_is_present}    DIC_SEARCH_VOD_SOURCE textKey not found in the search results

There is no UI change after button press
    [Documentation]    This keyword waits for ${UI_LOAD_DELAY} ms then gets current UI state and compares it with previous UI state.
    ...    ${UI_LOAD_DELAY} variable is set in Stbinterface.robot
    ...    Pre-reqs: UI state as JSON should be stored at variable ${LAST_FETCHED_JSON_OBJECT}.
    I wait for ${UI_LOAD_DELAY} ms
    ${old_json}    Set variable    ${LAST_FETCHED_JSON_OBJECT}
    ${new_json}    Get Ui Json
    ${compare_result}    Check if jsons are different    ${old_json}    ${new_json}
    Should Not Be True    ${compare_result}    UI state is not the same

Search input field contains string
    [Arguments]    ${expected_search_string}
    [Documentation]    This keyword verifies that given string ${expected_search_string} is shown in the input field in the search view
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:searchInputField' contains 'textValue:${expected_search_string}'

Search results screen is blank
    [Documentation]    This keyword verifies that the search results screen does not contain any result, and that
    ...    the message with textKey 'DIC_SEARCH_NO_RESULTS_TITLE' does not appear.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textKey:DIC_SEARCH_NO_RESULTS_TITLE'
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:searchResultsListNode\\\\d+' using regular expressions

I Search For A Replay Asset With '${replay_source}' As Replay Content Source    #USED
    [Documentation]    This Keyword searches for replay asset with the given replay content source
    I Search For Replay Asset    ${replay_source}

I Search For Replay Asset    #USED
    [Documentation]    This Keyword searches for replay asset e.g. NOS Tour de France
    [Arguments]    ${replay_source}=cloud
    ${hash_list}    ${replay_channel}    Get Event Metadata Segment For Yesterday And Today    ${replay_source}
    ${past_replay_events}    Set Variable    ${None}
    :FOR    ${hash}    IN    @{hash_list}
    \    ${epg_segment}    Get Event Metadata For A Particular Segment    ${hash}
    \    ${event_list}    Set Variable    ${epg_segment.json()['entries'][0]['events']}
    \    ${past_replay_events}    Get Details Of Past Replay Events    ${event_list}
    \    Exit For Loop If    ${past_replay_events}
    Should Not Be Empty    ${past_replay_events}    Unable to get replay event on channel: ${replay_channel} in last two days
    ${replay_asset}    Get Random Element From Array    ${past_replay_events}
    Set Suite Variable    ${REPLAY_ASSET}    ${replay_asset}
    I open Search through Main Menu
    I search for '${REPLAY_ASSET['title']}' using Virtual keyboard
    I choose GO action on Virtual keyboard
    The search results are shown for entered query

I Search for Single Recorded Asset With '${SELECTED_ASSET_TITLE}' Title And Open Detail Page    #USED
    [Documentation]   This Keyword Searches For The Locked Asset Event
	I search for '${SELECTED_ASSET_TITLE}' using Virtual keyboard
	I choose GO action on Virtual keyboard
	sleep  2s
	I open the first item in the search results

#********** CPE PERFORMANCE TESTING**********

Search results are shown for '${expected_search_string}'
    [Documentation]    This keyword verifies that given string is shown in the input field in the search view and search results are shown
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    id:searchInputField    textValue:${expected_search_string}
    Should Be True    ${result}    Item '${expected_search_string}' was not found in search field
    ${result}    Is In Json    ${json_object}    ${EMPTY}    id:searchItemNode1
    Should Be True    ${result}    No search results found
