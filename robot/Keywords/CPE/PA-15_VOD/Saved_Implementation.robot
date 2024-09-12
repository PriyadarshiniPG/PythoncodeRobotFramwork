*** Settings ***
Documentation     Saved area Implementation keywords
Resource          ../CommonPages/Modal_Implementation.robot
Resource          ../PA-04_User_Interface/MainMenu_Keywords.robot
Resource          ../PA-19_Cloud_Recordings/PVR_Keywords.robot
Resource          ../PA-23_Personalization/Personalization_Keywords.robot
Resource          ../PA-15_VOD/OnDemand_Keywords.robot
Resource          ../Services/Cloud/BookmarkService/BookmarkService_Keywords.robot
Library           robot.libraries.DateTime

*** Variables ***
${ADULT_ENTRY_TILE}    TileCollection_4_tile_0
${ADULT_IMAGE_ID}    ca61355d_d13b_4212_ab46_15ec52d4240d

*** Keywords ***
Get Recorded event container
    [Arguments]    ${event_name}
    [Documentation]    This keyword gets the recorded event json node with ${event_name}
    ...    name in the Recordings screen and returns it.
    ${event_container}    I retrieve json ancestor of level '2' for element 'textValue:^.*>${event_name}<.*$' using regular expressions
    [Return]    ${event_container}

Start Browsing is shown
    [Documentation]    This keyword verifies that the 'Start Browsing' button is shown on the Rented page.
    I expect page contains 'id:rentedEmptyStateButton-rented-empty-state'
    I expect page element 'id:rentedEmptyStateButton-rented-empty-state' contains 'textKey:DIC_RENTED_EMPTY_BUTTON'

Recordings Collection screen on Saved view is empty
    [Documentation]    This keyword verifies that the empty Recordings screen is shown.
    Saved is shown
    wait until keyword succeeds    10 times    1 s    I expect page contains 'textKey:DIC_RECORDINGS_EMPTY_TITLE'

Rented Collection screen on Saved view is empty
    [Documentation]    This keyword verifies that the empty Rented screen is shown.
    wait until keyword succeeds    10 times    1 s    I expect page contains 'textKey:DIC_RENTED_EMPTY_TITLE'

I focus a VOD episode tile
    [Documentation]    This keyword opens the 'Series' VOD section in On Demand and focuses a VOD episode tile,
    ...    saving the title of the asset in the ${TILE_TITLE} variable.
    I open On Demand through Main Menu
    I open 'Series'
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    @{series_details}    Get Content    ${LAB_CONF}    Series    SERIES    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}
    ...    ${CUSTOMER_ID}    count=all
    : FOR    ${asset}    IN    @{series_details}
    \    &{series_item}    Set Variable    ${asset}
    \    ${exit}    evaluate    True if 'broadcastDate' not in ${asset} else False
    \    exit for loop if    ${exit}
    Should Not Be Empty    &{series_item}[title]
    set test variable    ${TILE_TITLE}    &{series_item}[title]
    I press    DOWN
    I focus '${TILE_TITLE}' tile

Replay tile is focused
    [Documentation]    This keyword verifies if an asset tile is focused.
    wait until keyword succeeds    20 times    1 s    I expect focused elements contains '${TILE_NODE_ID_HIGH_PATTERN}' using regular expressions

Focus non-episode event
    [Documentation]    This keyword focuses a future non-episode event in Channel Bar
    ...    Precondition: Channel Bar should be open.
    : FOR    ${_}    IN RANGE    ${4}
    \    ${id}    Get Current Id
    \    ${current_text}    I retrieve value for key 'textValue' in element 'id:titleText${id}'
    \    ${is_episode}    Evaluate    True if 'Ep' in '${current_text}' else False
    \    exit for loop if    ${is_episode} == ${False}
    \    I press    RIGHT

Replay series tile is shown
    [Documentation]    This keyword verifies if the replay series tile saved in the ${TILE_TITLE} variable is shown.
    Variable should exist    ${TILE_TITLE}    The title of a VOD asset tile has not been saved. TILE_TITLE does not exist.
    wait until keyword succeeds    20 times    1 s    I expect page element 'id:.*CollectionsBrowser' contains 'textValue:.*${TILE_TITLE}.*' using regular expressions

I focus planned recording collection
    [Documentation]    This keyword focuses the planned recording collection in Recordings.
    ...    Precondition: Recordings screen in Saved should be open.
    Recordings is focused
    Move Focus to Collection named    DIC_ENTRY_TILE_PLANNED_REC
    Move Focus to Grid Link

I focus recording collection    #USED
    [Documentation]    This keyword focuses the recorded collection in Recordings.
    ...    Precondition: Recordings screen in Saved should be open.
#    Recordings is focused
    Move Focus to Collection named    DIC_RECORDING_LABEL_RECORDED

I focus the first asset in recorded collection
    [Documentation]    This keyword focuses the first asset in the recorded collection and verifies it's focused.
    ...    Precondition: Recordings screen in Saved should be open.
    Recordings is focused
    I focus recording collection
    Move Focus to Tile Position    1

I focus Planned recording tile
    [Documentation]    This keyword focuses the first asset in the recorded collection and verifies it's focused.
    ...    Precondition: Recordings screen in Saved should be open.
    I focus the first asset in Planned recordings collection

I rent one asset
    [Documentation]    This keyword rents one non-adult asset.
    I rent a non-adult asset

I focus '${tile_name}' tile in Rented area
    [Documentation]    This keyword focuses the tile with the given ${tile_name} in the Rented section in Saved, and
    ...    verifies the tile is focused.
    Move Focus to Tile in Grid Page    ${tile_name}    title

I focus the first asset in Planned recordings collection
    [Documentation]    This keyword focuses the first asset in Planned recordings collection.
    ...    Precondition: Recordings screen in Saved should be open.
    I focus planned recording collection
    Move Focus to Tile Position    1

Is 'ON DEMAND' page
    [Documentation]    This keyword verifies that if any 'ON DEMAND' page is shown
    ${json_object}    Get Ui Json
    ${is_on_demand}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_MAIN_MENU_MOVIES_AND_SERIES
    [Return]    ${is_on_demand}

Verify Bookmark Of An Asset Based On Position In Saved Page    #USED
    [Documentation]    This keyword verifies that the first tile in continue watched section is same as that of last watched  asset
    ...    or navigates to given tile in saved page. Playback is initiated and it is ensured
    ...    that playback resumes from point last stopped. precondition: section inside saved page is opened.
    ...    PARAMETERS asset_title: title of the asset for which bookmark is to be verified
    ...    progressbar_time: time from player progressbar when the given asset was last played
    ...    position: if 1, validates first tile of continue watching section. if >1, moves to asset with given title in saved page
    ...    and verifies bookmark
    [Arguments]    ${asset_title}    ${progressbar_time}    ${position}=${1}
    Move Focus to direction and assert     DOWN    3
    Run Keyword If    ${position}==${1}    Validate First Asset Tile In Continue Watching Section And Select Continue Watching    ${asset_title}
    ...    ELSE    Continue Watching Any Asset In Saved Page    ${asset_title}
    Wait Until Keyword Succeeds    15times    500ms    Verify That Asset Starts Playing From Where It Stopped    ${progressbar_time}
    I Press    STOP


Validate First Asset Tile In Continue Watching Section And Select Continue Watching    #USED
    [Documentation]    This keyword verifies that the first tile in continue watching is that of the
    ...    given asset which was last watched, plays the asset and selects 'Continue Watching' from the popup and handles intermediate popups
    ...    PARAMETERS  asset_title: Title of the last watched asset
    [Arguments]    ${asset_title}
    ${focused_tile}    Get Ui Focused Elements
    ${title_json}    Extract Value For Key    ${focused_tile}    id:shared-CollectionsBrowser_collection_\\d_tile_0    data    ${True}
    Should Be Equal As Strings    ${title_json['title']}    ${asset_title}    'Last watched asset not found'
    ${ui_json}    Get Ui Json
    ${json_object}    Get Enclosing Json    ${ui_json}    ${EMPTY}    textValue:.*${asset_title}.*    ${2}    ${EMPTY}    ${True}
    ${is_in_json}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_GENERIC_FULLY_WATCHED_INDICATOR
    Should Not Be True    ${is_in_json}    Fully watched indicator is present for the selected asset
    ${is_locked}    Extract Value For Key    ${json_object}    id:shared-CollectionsBrowser_collection_\\d_tile_0_primaryTitle    iconKeys    ${True}
    I Press    OK
    ${pin_entry_present}    Run Keyword If    "${is_locked}" == "LOCK"    Run Keyword And Return Status    Pin Entry popup is shown
    Run Keyword If    ${pin_entry_present}    I Enter A Valid Pin

Continue Watching Any Asset In Saved Page    #USED
    [Documentation]    This keyword  navigates to specific asset in a section within saved page. Handles age restricted pin entry popup,
    ...    rental popup and rental limit warning screen while selecting 'Continue Watching' whenever prompted
    ...    PARAMETERS  asset_title: title to navigate to in saved page
    [Arguments]    ${asset_title}
    Move Focus to Tile in Grid Page    ${asset_title}    title
    Continue Watching Selected Asset From Detail Page

Verify That Asset Starts Playing From Where It Stopped          #USED
    [Documentation]    This keyword verifies that an asset starts playing from time specified in progressbar_time parameter
    ...    PARAMETERS  progresbar_time: time from the player progressbar where the asset being verified for was last played
    [Arguments]    ${progressbar_time}
    I switch Player to PAUSE mode
    ${progress_time}    ${_}    Get viewing progress indicator data
    ${CONTINUE_WATCHING_PROGRESS_TIME}    robot.libraries.DateTime.Convert Time    ${progressbar_time}
    ${progress_time}    robot.libraries.DateTime.Convert Time    ${progress_time}
    ${time_difference}    Evaluate    abs(${CONTINUE_WATCHING_PROGRESS_TIME} - ${progress_time})
    Should Be True    ${time_difference} <= ${CONTINUE_WATCHING_TOLERANCE_VALUE_SECONDS}    'Continue Watching' asset didn't start playing where it was stopped
    make sure Playout continues for the duration    ${10}s
    I Press    STOP

I Try To Play Focused Asset And Validate Continue Watching Popup        #USED
    [Documentation]    This keyword tries to play focused asset and verifies if continue watching pop up is displayed
    ...    It also verifies if popup has options 'Play from start' and 'Continue Watching'
    I press    OK
    Handle Pin Popup
    ${continue_watching_popup_status}    Run Keyword And Return Status    'Continue Watching' popup is shown
    ${playback_status}     Run Keyword And Return Status    Run Keyword If    not ${continue_watching_popup_status}    video is playing from start
    Should Be True    ${continue_watching_popup_status} or not ${playback_status}     Recording Playback started without displaying 'Continue Watching' popup for selected bookmarked asset
    'Play from start' action is shown
