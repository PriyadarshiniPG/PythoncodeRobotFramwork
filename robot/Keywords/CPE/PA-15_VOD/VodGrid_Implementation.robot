*** Settings ***
Documentation     Implementation Keywords for grid functionality
Resource          ../Common/Common.robot
Resource          ../CommonPages/ValuePicker_Implementation.robot
Resource          ../PA-15_VOD/OnDemand_Keywords.robot
Resource          ../PA-04_User_Interface/Tips_Keywords.robot

*** Variables ***
${any_cathup_tile}    Andries
${MAX_VOD_ASSETS_IN_GRID}    30
${ONDEMAND_TAB_LOAD_TIME}    3
${GRID_TILE_ID_PATTERN}    CollectionContainer_grid(Landscape)?_\\d+
${COLLECTION_TILE_ID_PATTERN}    shared-CollectionsBrowser_collection_\\d+_(tile_\\d+|gridEntryTile)
${PROVIDER_TILE_ID_PATTERN}    providerGridTile-\\d+

*** Keywords ***
Skip A-Spot collection
    [Documentation]    This keyword skips the A-Spot collection by pressing DOWN if the A-Spot collection is focused.
    ${aspot_button_focused}    Is A-Spot button focused
    Run Keyword If    ${aspot_button_focused}    I press    DOWN

Is A-Spot button focused
    [Documentation]    This keyword checks A-spot button is focused and returns True if so.
    ${aspot_button_focused}    Run Keyword And Return Status    I expect focused elements contains 'textKey:DIC_A_SPOT_SINGLE_PROMO' using regular expressions
    [Return]    ${aspot_button_focused}

Is A-Spot present
    [Documentation]    This keyword checks A-spot button is present and returns True if so.
    ${aspot_button_present}    Run Keyword And Return Status    wait until keyword succeeds    10 times    1 sec    I expect page contains 'id:aSpotButton.*' using regular expressions
    [Return]    ${aspot_button_present}

VOD Grid Screen is shown
    [Documentation]    This keyword asserts the VOD grid screen is shown.
    Wait Until Keyword Succeeds    10 times    200 ms    I expect page contains 'id:VodGrid.View'

I focus '${tile_name}' tile
    [Documentation]    This keyword focuses the tile with ${tile_name} name in the
    ...    VOD grid screen and verifies it's focused. First the keyword presses the DOWN key until the desired tile
    ...    is present in the focused elements (either because we are focusing the element itself or the collection
    ...    that contains it), then navigates to the RIGHT until the element itself is in focus.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:.+tile_\\\\d+$' using regular expressions
    Move Focus to Collection with Tile    ${tile_name}    title
    Move Focus to Tile    ${tile_name}    title

Focus Back to top
    [Documentation]    This keyword focuses the 'Back to top' button.
    Move to element assert focused elements    textKey:DIC_BACK_TO_TOP    18    DOWN

Is Back to top focused
    [Documentation]    This keyword verifies if the 'Back to top' button is focused.
    ${json_object}    Get Ui Focused Elements
    ${status}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_BACK_TO_TOP    ${EMPTY}
    [Return]    ${status}

Skip Promotional And Editorial Tiles    #USED
    [Documentation]    This keyword skips promotional and editorial tiles.
    ...    Precondition: On Demand screen should be open.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Get Ui Focused Elements
    ${is_in_promotional}    Is In Json    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${Empty}    id:^.*CollectionsBrowser_promotionalCollection    ${Empty}    ${True}
    ${is_in_editorial}    Is In Json    ${LAST_FETCHED_FOCUSED_ELEMENTS}    id:shared-CollectionsBrowser_collection_\\d+    title:^((Tile$|TILE$|tile$)|([Mm][Oo][Vv][Ii][Ee] )?([gG][eE][nN][rR][eE](?:$|[sS])))    ${EMPTY}
    ...    ${True}
    Run Keyword If    ${is_in_promotional} or ${is_in_editorial}    Press Key    DOWN

I navigate to all genres vod screen
    [Documentation]    This keyword opens a second level grid screen e.g. Komodie, and changes the filter to All genres.
    : FOR    ${_}    IN RANGE    ${10}
    \    I wait for ${MOVE_ANIMATION_DELAY} ms
    \    ${focused_elements}    Get Ui Focused Elements
    \    ${elem_is_focused}    Is In Json    ${focused_elements}    id:shared-CollectionsBrowser_collection_\\d+    title:Genre    ${EMPTY}
    \    ...    ${True}
    \    exit for loop if    ${elem_is_focused}
    \    I Press    DOWN
    I press    OK
    wait until keyword succeeds    10s    1s    I expect page contains 'textKey:DIC_SORT_POPULARITY'
    Move to element and assert    id:gridNavigation_filterButton_0    color    ${INTERACTION_COLOUR}    3    UP
    I press    OK
    wait until keyword succeeds    10s    1s    I expect page contains 'id:picker-item-text-.*' using regular expressions
    Move Focus to Option in Value Picker    id:picker-item-text-0    UP    10
    I press    OK
    # There's a delay after choosing a new genre so we wait for the picker to close, the highlight to move and tiles to load
    wait until keyword succeeds    5s    1s    I do not expect page contains 'id:picker-item-text-.*' using regular expressions
    wait until keyword succeeds    5s    1s    I do not expect page element 'id:gridNavigation_filterButton_0' contains 'color:${HIGHLIGHTED_OPTION_COLOUR}'
    # Now, the first asset is always highlighted
    Poster tile is focused

Retrieve asset count in open vod grid
    [Documentation]    This keyword retrieves the asset count in the opened vod grid
    ${counter_string}    I retrieve value for key 'textValue' in element 'id:gridNavigation_gridCounter'
    ${counter_string}    Strip string    ${counter_string}
    ${split_counter}    Split String    ${counter_string}    separator=/
    ${max_assets}    convert to integer    @{split_counter}[1]
    [Return]    ${max_assets}

I focus full-length series asset via 'Series' all genres
    [Documentation]    This keyword opens the 'Series' category and focuses the tile of the asset with
    ...    full length episodes saved in the ${FULL_LENGTH_SERIES_TVOD_ASSET} variable.
    ...    Precondition: On Demand screen should be open.
    I open 'Series'
    I navigate to all genres vod screen
    I focus '${FULL_LENGTH_SERIES_TVOD_ASSET}' tile

I focus the 'Info' action
    [Documentation]    This keyword verifies the 'Info' action is shown and focuses it.
    ...    Precondition: A Contextual Menu popup should be open.
    'Info' action is shown
    Move Focus to Option in Value Picker    textKey:DIC_ACTIONS_INFO    DOWN    5

'Info' action is shown
    [Documentation]    This keyword verifies the 'Info' action is shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ACTIONS_INFO'

I focus the 'Subtitle' action
    [Documentation]    This keyword verifies the 'Subtitle' action is shown and focuses it.
    ...    Precondition: A Contextual Menu popup should be open.
    'Subtitle' action is shown
    Move Focus to Option in Value Picker    textKey:DIC_ACTIONS_LANGUAGE_OPTIONS_SUBTITLES    DOWN    5

'Subtitle' action is shown
    [Documentation]    This keyword verifies the 'Subtitle' action is shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ACTIONS_LANGUAGE_OPTIONS_SUBTITLES'

I focus the 'Audio' action
    [Documentation]    This keyword verifies the 'Audio' action is shown and focuses it.
    ...    Precondition: A Contextual Menu popup should be open.
    'Audio' action is shown
    Move Focus to Option in Value Picker    textKey:DIC_ACTIONS_LANGUAGE_OPTIONS_AUDIO    DOWN    5

'Audio' action is shown
    [Documentation]    This keyword verifies the 'Audio' action is shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ACTIONS_LANGUAGE_OPTIONS_AUDIO'

#******************************************CPE PERFORMANCE*****************************************************
VOD Grid Screen for given section is shown
    [Documentation]    This keyword asserts the VOD grid screen for the given setion is shown.
    [Arguments]  ${section_name}    ${only_highlight_check}=False    ${highlight_check}=True
    ${json_object}    Get Ui Json
    ${vod_grid_view}    Is In Json    ${json_object}    ${EMPTY}    id:CollectionsBase.View|VodCollections.View    ${EMPTY}    ${TRUE}
    Should Be True    ${vod_grid_view}  "VOD Grid View is not Shown"
    ${focused_section}    Get Enclosing Json    ${json_object}    ${EMPTY}    textValue:${section_name}    ${1}    ${EMPTY}
    ${text_color}    Extract Value For Key    ${focused_section}    ${EMPTY}    color
    run keyword if  ${highlight_check} == True    should be equal    '${text_color}'    '${HIGHLIGHTED_NAVIGATION_COLOUR}'
    ...    Focused Section isn't correctly highlighted
    return from keyword if    ${only_highlight_check} == True
     ${vod_tile_posters}    Is In Json    ${json_object}    ${EMPTY}
     ...   id:shared-CollectionsBrowser_collection_[\\d]+_tile_[\\d]+_poster    ${EMPTY}    ${True}
     Should Be True    ${vod_grid_view}  "VOD Grid tile Posters are not Shown"

Get VOD Section Json
    [Documentation]    This keyword return json for the vod sections
    @{cleaned_sections}    create list
    ${rotate}    Set Variable        ${-1}
    Get UI Json
    @{sections}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:shared-SectionNavigation-actionContainer
    ...    children
    # Remove the menus with empty text values

    : FOR    ${index}  ${SECTION_JSON}    IN ENUMERATE    @{sections}
    \    ${section_title}    Extract Value For Key    ${SECTION_JSON}    ${EMPTY}    textValue
    \    Continue For Loop If    '${section_title}' == '${EMPTY}'
    \    Append To List    ${cleaned_sections}    ${SECTION_JSON}

    #Arrange in the next available menu order.
    : FOR    ${index}  ${SECTION_JSON}    IN ENUMERATE    @{cleaned_sections}
    \    ${section_title}    Extract Value For Key    ${SECTION_JSON}    ${EMPTY}    textValue
    \    ${focused_section}    Get Enclosing Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textValue:${section_title}    ${1}
    \    ${text_color}    Extract Value For Key    ${focused_section}    ${EMPTY}    color
    \    Exit for loop if    '${text_color}' == '${HIGHLIGHTED_NAVIGATION_COLOUR}'
    \    ${rotate}    Set Variable    ${rotate-1}
    @{cleaned_sections}    rotate list   ${cleaned_sections}    ${rotate}
    [Return]     ${cleaned_sections}
