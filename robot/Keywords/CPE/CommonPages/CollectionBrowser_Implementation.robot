*** Settings ***
Documentation     Common keywords for navigation in Vod/Saved/Apps
Resource          ./Collection_Keywords.robot

*** Variables ***
${COLLECTIONS_BROWSER_NODE_ID}    .*CollectionsBrowser$
${COLLECTIONS_BROWSER_ID}    .*CollectionsBrowser_.*

*** Keywords ***
Move Focus to Collection Browser
    [Arguments]    ${max}=5
    [Documentation]    Move the focus until a collection in a collection browser is reached.
    ...    and set ${LAST_FETCHED_FOCUSED_COLLECTIONS} and ${NUMBER_OF_LAST_FETCHED_FOCUSED_COLLECTIONS}
    ...    to prevent from further unnecessary requests.
    ...    The default max number of key action can be specified by the ${max} argument (5 by default)
    ${is_back_to_top}    Is Back to top focused
    ${arrow}    Set Variable If    ${is_back_to_top}    UP    DOWN
    Move to element assert focused elements using regular expression    id:${COLLECTIONS_BROWSER_ID}    ${max}    ${arrow}
    ${use_items}    Is In Json    ${LAST_FETCHED_FOCUSED_ELEMENTS}    id:${COLLECTIONS_BROWSER_NODE_ID}    items:.+    ${EMPTY}    ${TRUE}
    ${key}    Set Variable If    ${use_items}    items    data
    ${collections_data}    Extract Value For Key    ${LAST_FETCHED_FOCUSED_ELEMENTS}    id:${COLLECTIONS_BROWSER_NODE_ID}    ${key}    ${True}
    Should Not Be Empty    ${collections_data}    Collection Browser Not Found
    ${number_of_collections}    Get Length    ${collections_data}
    Set Test Variable    ${LAST_FETCHED_FOCUSED_COLLECTIONS}    ${collections_data}
    Set Test Variable    ${NUMBER_OF_LAST_FETCHED_FOCUSED_COLLECTIONS}    ${number_of_collections}

Get Collection Position in Collection Browser
    [Arguments]    ${collection_id_or_name}    ${key}=id
    [Documentation]    Returns the position of a collection in a collection browser, or ${None} if the given collection is not found
    ...    The collection to look for can be identified by an id or name for the first ${collection_id_or_name} argument.
    ...    The second argument (${is_id}) must be set to ${False} if a name is used.
    ${position}    Set Variable    ${0}
    : FOR    ${current_collection}    IN    @{LAST_FETCHED_FOCUSED_COLLECTIONS}
    \    ${value}    Extract Value For Key    ${current_collection}    ${EMPTY}    ${key}
    \    ${found}    Evaluate    '${value}' == '${collection_id_or_name}'
    \    Return From Keyword if    ${found}    ${position}
    \    ${position}    Set Variable    ${position + 1}
    Should be True    ${found}    Could not find the position of the collection ${collection_id_or_name}
