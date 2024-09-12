*** Settings ***
Documentation     Search implementation keywords
Resource          ../Common/Common.robot
Resource          ../CommonPages/ValuePicker_Implementation.robot

*** Variables ***
${SINGLE_EVENT_NAME}    Billy Bam Bam en meer
${SINGLE_EVENT_SEARCH_QUERY}    bam
${MULTIPLE_EPISODE_WITH_DIFFERENT_SEASON}    The Simpsons
${SEARCH_DIGITS_ONLY}    44
${RADIO_CHANNEL_SEARCH_QUERY}    Classic
${CHANNEL_NAME}    ${EMPTY}
${AGE_RATED_VOD_SEARCH_QUERY}    Wonder Woman
${APP_SEARCH_WAIT_TIME}    3

*** Keywords ***
There are no results for '${search_for}'. Please try again. is shown
    [Documentation]    This keyword verifies the 'There are no results' message appears
    ...    when there are no matching results.
    ${search_for}    Replace String    ${search_for}    ±    ${SPACE}
    I expect page element 'id:searchNoResultsBody' contains 'textValue:There are no results for \'${search_for}\'. Please try again.'

Handle Search Results List
    [Arguments]    ${nodes}
    [Documentation]    This keyword iterates over all the result values in the ${nodes} argument and
    ...    verifies each result matches the search query.
    ${nodes_length}    Get Length    ${nodes}
    : FOR    ${i}    IN RANGE    ${nodes_length}
    \    ${node_text}    Set Variable    ${nodes[${i}]['children'][0]['textValue']}
    \    ${node_text}    remove html tag from string    ${node_text}
    \    ${status}    Run Keyword And Return Status    Handle Results item    ${node_text}
    \    Exit For Loop If    '${status}'=='${True}'

Handle Results item
    [Arguments]    ${node_text}
    [Documentation]    This keyword iterates over the strings in the ${SEARCH_QUERY} and verifies the
    ...    ${node_text} contain the query string. This keyword cannot be used in Setups and Teardowns as it uses a test variable.
    ${SEARCH_QUERY}    convert to lowercase    ${SEARCH_QUERY}
    ${node_text}    convert to lowercase    ${node_text}
    ${node_text}    convert to string    ${node_text}
    @{search_query_list}    Split String    ${SEARCH_QUERY}
    : FOR    ${search_string}    IN    @{search_query_list}
    \    Should Contain    ${node_text}    ${search_string}    No match found for search query '${SEARCH_QUERY}' in search result '${node_text}'

Check if current focussed event has episodes listed in details page
    [Documentation]    This keyword checks if the current focused event has episodes listed in its Details Page.
    I Press    INFO
    Linear Details Page is shown
    ${has_episodes}    run keyword and return status    'Episodes' action is shown
    I Press    INFO
    [Return]    ${has_episodes}

Series Live TV programme on channel '${channel_number}' with episodes is available
    [Documentation]    This keyword checks if a series event that has episodes listed on the specified channel is
    ...    available and stores the event name in the ${SERIES_EVENT} variable.
    ${currently_tuned}    Get current channel number
    run keyword if    ${channel_number}!=${currently_tuned}    I tune to channel    ${channel_number}
    I focus Current event
    : FOR    ${i}    IN RANGE    ${1}    ${40}
    \    ${has_episodes}    check if current focussed event has episodes listed in details page
    \    Run Keyword unless    ${has_episodes}    run keywords    I focus Next event in Channel Bar
    \    ...    AND    continue for loop
    \    ${event_name}    I retrieve value for key 'viewStateValue' in element 'viewStateKey:selectedProgramme'
    \    set test variable    ${SERIES_EVENT}    ${event_name}
    \    Exit For Loop
    run keyword if    '${SERIES_EVENT}'=='${EMPTY}'    Fail    Not found any series event with episodes listed

Get ancestor for highlighted element in search window
    [Documentation]    This keyword gets the ancestor of the element that is highlighted in
    ...    the search window and returns it.
    ${json_object}    Get Ui Json
    ${ancestor}    Get Enclosing Json    ${json_object}    id:.*    color:${HIGHLIGHTED_OPTION_COLOUR}    ${2}    ${EMPTY}
    ...    ${True}
    [Return]    ${ancestor}

Remove html tag from string
    [Arguments]    ${string}
    [Documentation]    This keyword returns the string given as an argument after removing all
    ...    HTML tags (any text enclosed in <> symbols).
    ${html_tags_re}    Evaluate    re.compile(r'<[^>]+>').sub('', "${string}")    re
    [Return]    ${html_tags_re}

Seasons grouped count is shown in search results
    [Documentation]    This keyword verifies that the seasons grouped count is displayed in the search results for the
    ...    series event defined in the ${MULTIPLE_EPISODE_WITH_DIFFERENT_SEASON} variable.
    Season grouped info shown in search results    ${MULTIPLE_EPISODE_WITH_DIFFERENT_SEASON}
    ${element_id}    Catenate    SEPARATOR=    secondaryMetadatasearchResultsListNode    ${SEARCH_ROW_INDEX}
    ${textkey_string}    I retrieve value for key 'textKey' in element 'id:${element_id}'
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'textKey:${textkey_string}' contains 'textValue:.*seasons.*' using regular expressions

Season grouped info shown in search results
    [Arguments]    ${event_name}
    [Documentation]    This keyword verifies the given event in the ${event_name} argument is present
    ...    in the search results and focuses it.
    ${search_list}    Search executed
    ${nodes}    set variable    ${search_list[0]['children']}
    ${nodes_length}    Get Length    ${nodes}
    : FOR    ${i}    IN RANGE    ${nodes_length}
    \    ${node_text}    Set Variable    ${nodes[${i}]['children'][0]['textValue']}
    \    ${stripped_string}    remove html tag from string    ${node_text}
    \    ${is_equal}    evaluate    '${stripped_string}' == '${event_name}'
    \    ${result}    Extract Value For Key    ${nodes[${i}]['children'][0]}    textValue:<b>${event_name}</b>    id
    \    run keyword if    ${is_equal}    set test variable    ${SEARCH_ROW_INDEX}    ${result[-1]}
    \    exit for loop if    ${is_equal}
    ${SEARCH_ROW_INDEX}    Convert to integer    ${SEARCH_ROW_INDEX}
    : FOR    ${index}    IN RANGE    ${SEARCH_ROW_INDEX + 1}
    \    I press    DOWN

Get channel name of first item in search result
    [Documentation]    This keyword gets the channel name of the first item in the search result
    ...    Pre-reqs: We've completed a search and have at least one item in the search result list.
    ${list_container}    I retrieve value for key 'children' in element 'id:searchItemNode0'
    [Return]    ${list_container[0]['textValue']}
