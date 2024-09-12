*** Settings ***
Documentation     Keywords for the Saved menu
Resource          ../PA-15_VOD/Saved_Implementation.robot

*** Keywords ***
I open Saved    #USED
    [Documentation]    This keyword opens the Saved menu and verifies it's shown.
    ...    Precondition: The Main Menu should be open.
    I focus Saved
    I Press    OK
    Saved is shown

I open Saved through Main Menu    #USED
    [Documentation]    This keyword opens the Saved menu through the Main Menu.
    I open Main Menu
    I open Saved

Saved is shown    #USED
    [Documentation]    This keyword verifies that Saved is shown in Main Menu.
    I Wait For 2 Second
    Error popup is not shown
    ${action_found}    Run Keyword And Return Status    Wait Until Keyword Succeeds    10 times    1 sec    I expect page contains 'id:OnDemand.View|Recordings.View' using regular expressions
    Should Be True    ${action_found}    Saved is not shown
    ${action_found}    Run Keyword And Return Status    Wait Until Keyword Succeeds    10 times    1 sec    I expect page element 'id:mastheadPrimaryTitle' contains 'textKey:DIC_MAIN_MENU_RECORDINGS'
    Should Be True    ${action_found}    Saved is not shown

I focus Saved    #USED
    [Documentation]    This keyword moves the cursor in the Main Menu to Saved.
    Move Focus to Section    DIC_MAIN_MENU_RECORDINGS    textKey

I open Recordings through Saved    #USED
    [Documentation]    This keyword focuses the Recordings section within the Saved menu, and verifies it's shown.
    I open Saved through Main Menu
#    I focus Recordings
#    Recordings is focused
    Recordings collection screen is shown

I open Watchlist through Saved    #USED
    [Documentation]    This keyword focuses the Watchlist section within the Saved menu, and verifies it's shown.
    I open Saved through Main Menu
    I focus Watchlist
    Watchlist is focused

I open Continue Watching through Saved
    [Documentation]    This keyword moves the cursor in the Saved Menu to focus the Continue Watching page
    I focus Continue Watching in Saved
    Continue Watching is focused

I open Rented through Saved
    [Documentation]    This keyword focuses the Rented section within the Saved menu, and verifies it's shown.
    I open Saved through Main Menu
    I focus Rented
    Rented is focused

I focus Go to TV Guide
    [Documentation]    This keyword focuses the 'TV Guide' button in the Recordings section.
    ...    Precondition: The Recordings section in Saved should be open and empty.
    Move to element and assert    id:noContentEmptyStateButton    textKey    DIC_RECORDINGS_EMPTY_BUTTON    1    DOWN
    I press    DOWN

I focus start browsing button
    [Documentation]    This keyword verifies the 'Go to On Demand' button in the Rented section is shown,
    ...    focuses it and verifies the button is focused.
    ...    Precondition: The Rented section in Saved should be open and empty.
    Start Browsing is shown
    I press    DOWN
    Start browsing button is focused

I focus Recordings    #USED
    [Documentation]    This keyword focuses the Recordings section within the Saved menu.
    ...    Precondition: Saved should be open.
    Move Focus to Section    DIC_SECTION_NAV_RECORDINGS    textKey

Recordings is focused    #USED
    [Documentation]    This keyword verifies that the Recordings section selector within Saved is focused.
    Section is Focused    DIC_SECTION_NAV_RECORDINGS    textKey

Recordings is shown
    [Documentation]    This keyword verifies that the Recordings section selector within Saved is shown.
    I expect page contains 'textKey:DIC_SECTION_NAV_RECORDINGS'

I focus Watchlist
    [Documentation]    This keyword focuses the Watchlist section within Saved.
    ...    Precondition: Saved should be open.
    Move Focus to Section    DIC_SECTION_NAV_WATCHLIST    textKey

Watchlist is focused
    [Documentation]    This keyword verifies that the Watchlist section selector within Saved is focused.
    Section is Focused    DIC_SECTION_NAV_WATCHLIST    textKey

Watchlist is shown
    [Documentation]    This keyword verifies that the Watchlist section selector within Saved is shown.
    I expect page contains 'textKey:DIC_SECTION_NAV_WATCHLIST'

Continue Watching is focused
    [Documentation]    This keyword checks that the Continue Watching page is focused within the Saved Menu
    Section is Focused    DIC_SECTION_NAV_CONTINUEWATCHING    textKey

I focus Rented
    [Documentation]    This keyword focuses the Rented section within Saved.
    ...    Precondition: Saved should be open.
    Move Focus to Section    DIC_SECTION_NAV_RENTED    textKey

Rented is focused
    [Documentation]    This keyword verifies that the Rented section selector within Saved is focused.
    Section is Focused    DIC_SECTION_NAV_RENTED    textKey

Rented is shown
    [Documentation]    This keyword verifies that the Rented section selector within Saved is focused.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SECTION_NAV_RENTED'

Recordings Collection screen is empty
    [Documentation]    This keyword verifies that the Recordings section does not contain any recorded assets.
    Recordings Collection screen on Saved view is empty

Rented Collection screen is empty
    [Documentation]    This keyword verifies that the Rented section does not contain any rented assets.
    Rented is focused
    Rented Collection screen on Saved view is empty

Watchlist screen is empty
    [Documentation]    This keyword verifies that the Watchlist section is focused and does not contain any assets.
    Watchlist is focused
    Watchlist is empty

Start browsing button is focused
    [Documentation]    This keyword verifies that the 'Start browsing' button is focused.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:rentedEmptyStateButton-rented-empty-state' contains 'color:${INTERACTION_COLOUR}'

Recordings is not shown
    [Documentation]    This keyword verifies that the Recordings section is not displayed.
    I do not expect page contains 'viewStateValue:SAVED'

Rented is not shown
    [Documentation]    This keyword verifies that the Rented section is not displayed.
    I do not expect page contains 'viewStateValue:RENTED'

Saved is not shown
    [Documentation]    This keyword verifies that the Saved menu is not displayed.
    ${textKey}    I retrieve value for key 'textKey' in element 'id:mastheadScreenTitle'
    Should Not Be Equal    ${textKey}    DIC_MAIN_MENU_SAVED

Saved is focused
    [Documentation]    This keyword verifies that the Saved menu is focused in the Main menu.
    Section is Focused    DIC_MAIN_MENU_SAVED    textKey

Recordings Collection screen is not empty
    [Documentation]    This keyword verifies that the empty Recordings screen is not shown.
    Wait Until Keyword Succeeds    10 times    300 ms    I do not expect page contains 'textKey:DIC_RECORDINGS_EMPTY_TITLE'

Watchlist is empty
    [Documentation]    This keyword verifies that the empty Watchlist screen is shown.
    Saved is shown
    wait until keyword succeeds    10 times    200 ms    I expect page contains 'textKey:DIC_WATCHLIST_EMPTY_TITLE'

Watchlist empty screen is shown
    [Documentation]    This keyword verifies that the empty Watchlist screen is shown and no assets are shown.
    Watchlist is empty
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:NavigableGrid'

Recordings collection is shown
    [Documentation]    This keyword verifies that the Recordings collection is being shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_RECORDING_LABEL_RECORDED'

Planned recordings collection is shown
    [Documentation]    This keyword verifies that the Planned recordings collection is being shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ENTRY_TILE_PLANNED_REC'

Adult entry tile is shown
    [Documentation]    This keyword verifies that the Adult entry tile is being shown.
    ${is_on_demand}    Is 'ON DEMAND' page
    run keyword if    ${is_on_demand}    run keywords    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'image:.*${ADULT_IMAGE_ID}.png.*' using regular expressions
    ...    AND    return from keyword
    repeat keyword    2 times    I press    DOWN
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:(DIC_ADULT_RECORDINGS_BTN|DIC_ADULT_RENTED_BTN)' using regular expressions

I focus Adult entry tile
    [Documentation]    This keyword focuses the Adult entry tile in the Recordings screen in Saved/On Demand.
    ${is_on_demand}    Is 'ON DEMAND' page
    run keyword if    ${is_on_demand}    Move to element assert focused elements using regular expression    id:^.*CollectionsBrowser_collection_\\\\d_tile_0    8    DOWN
    ...    ELSE    Move to element assert focused elements using regular expression    textKey:(DIC_ADULT_RECORDINGS_BTN|DIC_ADULT_RENTED_BTN)    8    DOWN
    Adult entry tile is focused

Adult Section Pin Entry Modal Is Shown    #USED
    [Documentation]    This keyword verifies the Pin Entry popup has the correct title and text for the Adult section.
    Pin Entry popup is shown
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:pinEntryModalPopupTitle' contains 'textKey:DIC_ADULT_SECTION'
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:pinEntryModalPopupBody' contains 'textKey:DIC_PIN_BODY_ADULT_SECTION'

Replay tile is shown
    [Documentation]    This keyword verifies if the Replay tile that contains the title saved in
    ...    the ${REPLAY_TILE_TITLE} variable is shown.
    Variable should exist    ${REPLAY_TILE_TITLE}    Title of the Replay tile was not saved.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textValue:.*${REPLAY_TILE_TITLE}.*' using regular expressions

I added one VOD episode to Watchlist
    [Documentation]    This keyword adds one VOD episode to the Watchlist and verifies
    ...    the 'Add to Watchlist' action changes in the Details Page.
    I focus a VOD episode tile
    I open VOD Detail Page
    I open Add To Watchlist

I added one VOD movie to Watchlist
    [Documentation]    Adds one VOD movie to the Watchlist and verifies
    ...    the 'Add to Watchlist' action changes in the Details Page.
    I open On Demand through Main Menu
    I focus a VOD movie tile
    I open VOD detail Page
    I open Add To Watchlist

I focus a VOD movie tile
    [Documentation]    This keyword opens the 'Movies' VOD section in On Demand and focuses a VOD movie tile,
    ...    saving the title of the asset in the ${TILE_TITLE} variable.
    ...    Precondition: On Demand screen should be open.
    I open 'Movies'
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${movie_details}    Get Content    ${LAB_CONF}    Movies    ASSET    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}
    ...    ${CUSTOMER_ID}    all
    ${movie_title}    Get TVOD non-entitled asset title    ${movie_details}
    set test variable    ${TILE_TITLE}    ${movie_title}
    VOD tiles are shown
    I press    DOWN
    I focus '${TILE_TITLE}' tile

I rent one adult asset
    [Documentation]    This keyword opens the 'Erotiek' VOD section in On Demand and rents one adult asset,
    ...    saving the title of the asset in the ${RENTED_ADULT_ASSET} variable.
    I open On Demand through the remote button
    I open 'Erotiek'
    I press    DOWN
    I press    OK
    Adult section pin entry modal is shown
    I enter a valid pin
    Pin Entry popup is not shown
    wait until keyword succeeds    10 times    200 ms    I do not expect page contains 'id:menuContainer'
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    &{movie_details}    Get Content    ${LAB_CONF}    Passion    ASSET    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}
    ...    ${CUSTOMER_ID}
    Should Not Be Empty    &{movie_details}[title]
    I focus '&{movie_details}[title]' tile
    I open VOD Detail Page
    I select valid rent option
    wait until keyword succeeds    10 times    1 sec    I expect page contains 'textKey:DIC_PURCHASE_PIN_ENTRY_MESSAGE'
    I enter a valid pin for VOD Rent
    wait until keyword succeeds    20 times    1 sec    I expect page contains 'textKey:DIC_ABOUT_TO_START_HEADER'
    Exit player if turned on
    set test variable    ${RENTED_ADULT_ASSET}    &{movie_details}[title]

Adult grid page is shown
    [Documentation]    This keyword verifies that the Adult grid page is shown.
    wait until keyword succeeds    20 times    1 sec    I expect page contains 'textKey:DIC_GENRE_ADULT'

Adult grid page is not shown
    [Documentation]    This keyword verifies that the Adult grid page is not shown.
    wait until keyword succeeds    20 times    1 sec    I do not expect page contains 'textKey:DIC_GENRE_ADULT'

Unlocked adult asset is shown
    [Documentation]    This keyword verifies that an unlocked adult asset is shown.
    wait until keyword succeeds    10 times    1 s    I expect page contains 'id:^.*CollectionsBrowser_collection_\\\\d+.*' using regular expressions
    ${focused_title}    Get Focused Tile    title
    ${focused_id}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    textValue:.*${focused_title}*    id    ${True}
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:${focused_id}' contains 'iconKeys:OPEN_LOCK'

I added one Replay boxset episode to Watchlist
    [Documentation]    This keyword adds one Replay boxset episode to the Watchlist
    ...    saving the asset title in the ${TILE_TITLE} variable.
    I tune to channel    ${BOXSET_CHANNEL}
    I open Linear Detail Page
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_GENERIC_EP_NUMBER'
    I open Add To Watchlist
    ${TILE_TITLE}    I retrieve value for key 'textValue' in element 'id:title'
    set test variable    ${TILE_TITLE}

I focus Replay boxset series tile
    [Documentation]    This keyword focuses the first Replay boxset episode added to the Watchlist.
    ...    Precondition: Watchlist screen should be open.
    I press    DOWN
    Replay tile is focused

Replay boxset Details page is shown
    [Documentation]    This keyword verifies if a replay boxset Details Page is shown.
    Wait Until Keyword Succeeds    10 times    500 ms    I expect page contains 'id:DetailPage.View'
    Wait Until Keyword Succeeds    10 times    500 ms    I expect page element 'id:replayIconprimaryMetadata' contains 'textValue:G'
    Wait Until Keyword Succeeds    10 times    500 ms    I expect page contains 'textKey:DIC_GENERIC_EP_NUMBER'

I added one Replay tv show episode to Watchlist
    [Documentation]    This keyword adds one Replay TV show episode to the Watchlist through the Details Page and
    ...    saves the asset's title in the ${TILE_TITLE} variable.
    I tune to channel    ${REPLAY_EVENTS_CHANNEL}
    Channel Bar is shown
    Focus non-episode event
    I open Linear Detail Page
    Wait Until Keyword Succeeds    10 times    500 ms    I expect page element 'id:replayIconprimaryMetadata' contains 'textValue:G'
    I open Add To Watchlist
    ${TILE_TITLE}    I retrieve value for key 'textValue' in element 'id:title'
    set test variable    ${TILE_TITLE}

Replay tv show series tile is shown
    [Documentation]    This keyword verifies if the replay series tile saved in the ${TILE_TITLE} variable is shown.
    Replay series tile is shown

Replay boxset series tile is shown
    [Documentation]    This keyword verifies if the replay series tile saved in the ${TILE_TITLE} variable is shown.
    Replay series tile is shown

I focus Replay tv show series tile
    [Documentation]    This keyword focuses the first Replay tv show series tile added to the Watchlist.
    ...    Precondition: Watchlist screen should be open.
    I press    DOWN
    Replay tile is focused

Replay tv show Details page is shown
    [Documentation]    This keyword verifies if a replay boxset Details Page is shown.
    Wait Until Keyword Succeeds    10 times    500 ms    I expect page contains 'id:DetailPage.View'
    Wait Until Keyword Succeeds    10 times    500 ms    I expect page element 'id:replayIconprimaryMetadata' contains 'textValue:G'
    Wait Until Keyword Succeeds    10 times    500 ms    I do not expect page contains 'textKey:DIC_GENERIC_EP_NUMBER'

I focus SAVED through Contextual Main Menu      #USED
    [Documentation]    This keyword opens the Main Menu from anywhere and focuses Saved.
    I open Main Menu
    Move Focus to Section    DIC_MAIN_MENU_SAVED    textKey

I open Recorded tile
    [Documentation]    This keyword opens the Details Page of the first Recorded tile in the Main Menu.
    ...    Precondition: Main Menu should be opened and the Saved section focused, ${EVENT_NAME} variable must exist in this scope.
    variable should exist    ${EVENT_NAME}    Suite variable EVENT_NAME has not been set.
    I expect page contains 'id:contextualMainMenu-navigationContainer-SAVED_elements_container'
    I Press    DOWN
    Move to element assert focused elements    id:${EVENT_NAME}    4    RIGHT
    I Press    OK
    linear details page is shown
    Wait Until Keyword Succeeds    10 times    200 ms    I expect page contains 'id:recordingTextInfoprimaryMetadata'

Recorded is shown
    [Documentation]    This keyword verifies the Recorded label is shown in the Main Menu
    Wait Until Keyword Succeeds    10 times    500 ms    I expect page contains 'textKey:DIC_CONTEXTUAL_MAIN_MENU_RECORDED'

Recording asset is available
    [Arguments]    ${channel}=${SINGLE_EVENT_CHANNEL}
    [Documentation]    This keyword checks if there is atleast one recording available.
    ...    If not records the current event in the LCN ${channel} using appservices.
    ${recording_collection_details}    get recording collection via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${recordings_count}    set variable    ${recording_collection_details.recordings.totalRecordings}
    run keyword if    ${recordings_count} == 0    Record current event in channel    ${channel}

Record current event in channel
    [Arguments]    ${channel}
    [Documentation]    This keyword opens the channel bar, gets the name of the current event, records it using appservices
    ...    and saves the event name in the ${EVENT_NAME} variable.
    ${channel_id}    Get channel ID using channel number    ${channel}
    @{current_event}    Get current channel event via as    ${channel_id}
    ${event_data}    get current event    ${channel_id}    ${CPE_ID}
    Create event recording    ${channel_id}    @{current_event}[0]    @{current_event}[1]
    set suite variable    ${EVENT_NAME}    ${event_data[0]}

I focus Recording tile
    [Documentation]    This keyword focuses the first Recording tile in Saved.
    ...    Precondition: Recordings screen in Saved should be open.
    I focus the first asset in recorded collection

I added one VOD asset to Watchlist
    [Documentation]    This keyword adds one VOD asset to the Watchlist
    I added one VOD movie to Watchlist

I focus Rented tile
    [Documentation]    This keyword verifies that there are tiles in the Rented area and if any of them contains the
    ...    the title saved in the ${NON_ADULT_RENTED_TILE_TITLE} variable, then focuses that tile.
    ...    Precondition: Rented screen in Saved should be open.
    variable should exist    ${NON_ADULT_RENTED_TILE_TITLE}    A non adult movie has not been rented. NON_ADULT_RENTED_TITLE_TITLE does not exist.
    wait until keyword succeeds    10    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:.*CollectionsBrowser' using regular expressions
    ${is_tile_present}    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    id:.*CollectionsBrowser
    ...    textValue:.*${NON_ADULT_RENTED_TILE_TITLE}.*    ${EMPTY}    ${True}
    Should Be True    ${is_tile_present}    Item 'textValue:.*${NON_ADULT_RENTED_TILE_TITLE}.*' was not found in 'id:.*CollectionsBrowser'
    I focus '${NON_ADULT_RENTED_TILE_TITLE}' tile in Rented area

I open Rented tile
    [Documentation]    This keyword opens a Rented tile in the Rented section in Saved.
    I focus Rented tile
    I press    OK

I open VOD tile
    [Documentation]    This keywords opens a VOD tile in the current screen.
    I focus VOD tile
    I press    OK

I open a poster tile
    [Documentation]    This keyword opens a poster tile in the current screen.
    I focus a poster tile
    I press    OK

I open Recording tile
    [Documentation]    This keyword opens a Recording tile in the current screen.
    I focus Recording tile
    I press    OK

Adult entry tile is focused
    [Documentation]    This keyword verifies that the Adult entry tile is focused in Saved/On Demand.
    ${is_on_demand}    Is 'ON DEMAND' page
    run keyword if    ${is_on_demand}    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused element 'id:^.*CollectionsBrowser_collection_\\\\d_tile_0' contains 'opacity:255' using regular expressions
    ...    ELSE    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'textKey:(DIC_ADULT_RECORDINGS_BTN|DIC_ADULT_RENTED_BTN)' using regular expressions

Currently recording icon is shown in secondary string
    [Documentation]    This keyword verifies the currently recording icon is shown
    ...    in the secondary string of a recording tile.
    ${rec_event_data}    Get Recorded event container    ${event_name}
    ${rec_icon_shown}    Is In Json    ${rec_event_data}    ${EMPTY}    textValue:^.*>M<.*$    ${EMPTY}    ${True}
    Should Be True    ${rec_icon_shown}

'Now recording' is shown in secondary string
    [Documentation]    This keyword verifies the Now recording label is shown in the secondary string of a recording tile.
    ${rec_event_data}    Get Recorded event container    ${event_name}
    ${now_rec_shown}    Is In Json    ${rec_event_data}    ${EMPTY}    textKey:DIC_GENERIC_AIRING_TIME_REC
    Should Be True    ${now_rec_shown}

Default Poster tile is displayed
    [Documentation]    This keyword verifies that the default poster tile is displayed.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'image:/usr/share/.+/default_linear_collection.png' using regular expressions

I focus the Adult recordings section in Saved
    [Documentation]    This keyword navigates to Saved and then focuses the Adult recordings tile in Recordings.
    I open Saved through Main Menu
    I focus Adult entry tile

I focus Continue watching in Saved
    [Documentation]    This keyword navigates to Saved and then focuses the Continue Watching section.
    I open Saved through Main Menu
    Move Focus to Section    DIC_SECTION_NAV_CONTINUEWATCHING    textKey

I focus the currently recording tile in Saved
    [Documentation]    This keyword opens the Recordings screen in Saved and focuses the currently recording tile.
    I open Recordings through Saved
    I focus Recording tile

I open the Adult Recording collection in Saved by entering pin
    [Documentation]    This keyword navigates through Saved to focus and opens the Adult recording collection list.
    I focus the Adult recordings section in Saved
    I press    OK
    pin entry popup is shown
    I enter a valid pin
    wait until keyword succeeds    10 times    1 sec    I expect page contains 'textKey:DIC_CRUMBTRAIL_ADULT_RECORDINGS'

Adult Recording list is not empty
    [Documentation]    This keyword verifies the Adult recording list is shown and it's not empty.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_CRUMBTRAIL_ADULT_RECORDINGS'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:listItemPrimaryInfo-ListItem'

Recorded event is shown
    [Documentation]    This keyword verifies a partially or fully recorded tile is shown in Recordings
    ...    and focuses the first partially or fully recorded tile in the Recordings collection.
    I focus recording collection
    Focus partially or fully recorded tile
    Recordings collection is shown

I have rented assets
    [Documentation]    This keyword checks if there are any rented assets. If not, rents a non-adult asset.
    I retrieve rentals from purchase service
    ${rented_count}    Get Length    ${RENTED_ASSETS}
    return from keyword if    ${rented_count}!=0
    ${current_country_code}    Read current country code
    ${movies_section_name}    set variable if    "${current_country_code}"=="nl"    films    Movies
    I rent a non-adult asset    ${movies_section_name}

I retrieve rentals from purchase service
    [Documentation]    This keyword retrieves the rental details from purchase service saving
    ...    them to the ${RENTED_ASSETS} variable.
    ${rented}    Get Vod Rentals Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    set test variable    ${RENTED_ASSETS}    ${rented}

Displayed rentals match retrieved rentals
    [Documentation]    This keyword verifies the displayed rentals match the retrieved rentals.
    ...    Precondition: Rented screen in Saved should be open.
    Variable should exist    ${RENTED_ASSETS}    The list of rented assets has not been saved. RENTED_ASSETS does not exist.
    ${rented_count}    Get Length    ${RENTED_ASSETS}
    : FOR    ${i}    IN RANGE    ${0}    ${rented_count}
    \    ${rented_crid}    Fetch From Left    ${rented_assets[${i}]}    -tvod
    \    ${rented_info}    Get asset info    ${rented_crid}
    \    continue for loop if    ${rented_info['isAdult']} == True
    \    ${json_object}    get ui json
    \    ${is_present}    Is In Json    ${json_object}    ${EMPTY}    textValue:.*${rented_info['title']}.*    ${EMPTY}
    \    ...    ${True}
    \    Should be true    ${is_present}    Asset ${rented_info['title']} not found in rented area

Continue Watching collection screen on Saved view is empty      #USED
    [Documentation]    This keyword verifies that the empty Continue Watching screen is shown.
    Saved is shown
    wait until keyword succeeds    10 times    1 s    I expect page contains 'textKey:DIC_CONTINUE_WATCHING_EMPTY_TITLE'

I start playback of VOD movie added to Watchlist
    [Documentation]    This keyword starts the playback of the tile with name ${TILE_TITLE},
    ...    first opening its Detail Page, and then initiating the Rent flow if needed or
    ...    selecting the 'WATCH' action, verifying the playback starts.
    ...    Precondition: ${TILE_TITLE} variable must exist in this scope.
    ...    Precondition: Watchlist screen in Saved should be open.
    variable should exist    ${TILE_TITLE}    Title of VOD movie added to watchlist was not saved.
    I focus '${TILE_TITLE}' tile
    I press    OK
    VOD Details Page is shown
    ${is_entitled}    run keyword and return status    'PLAY FROM START' action is shown
    run keyword if    ${is_entitled}    I press    PLAY-PAUSE
    ...    ELSE    I rent asset
    About to start screen is shown

Adult recordings button is not shown
    [Documentation]    Verifies if 'Adult recordings' button is not shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textKey:DIC_ADULT_RECORDINGS_BTN'

Back to Top button is not shown
    [Documentation]    Verifies if 'Back to Top' button is not shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textKey:DIC_BACK_TO_TOP'

Adult recordings button is shown
    [Documentation]    Verifies if 'Adult recordings' button is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ADULT_RECORDINGS_BTN'

I continue watching the partially watched VOD movie asset
    [Documentation]    This keyword focuses the tile with name ${TITLE_TITLE} and starts the playback of the partially
    ...    asset, saving the asset's bookmark in the ${PREVIOUSLY_FETCHED_BOOKMARK} variable before starting playing the asset.
    ...    Precondition: ${TILE_TITLE} variable must exist in this scope.
    ...    Precondition: A screen with poster tiles (On Demand, Saved) should be open.
    variable should exist    ${TILE_TITLE}    Title of VOD movie added to watchlist was not saved.
    I focus '${TILE_TITLE}' tile
    I open VOD Detail Page
    Entitled VOD asset is partially watched

Get The List Of Assets Displayed In Contextual Main Menu For Saved      #USED
    [Documentation]    This keyword navigates to Contextual Main Menu of Saved and retrieves the recording
    ...    names of the tiles displayed.
    I focus SAVED through Contextual Main Menu
    ${saved_recording_list_element}    I retrieve json ancestor of level '1' for element 'id:contextualMainMenu-navigationContainer-SAVED_elements_container'
    ${saved_recording_list_element}    set variable    ${saved_recording_list_element['children']}
    ${saved_recording_list_count}      Get Length      ${saved_recording_list_element}
    Log     ${saved_recording_list_element}
    @{contextual_menu_saved_recording_list}    Create List
    : FOR    ${index}    IN RANGE    ${0}    ${saved_recording_list_count}
    \   ${recording_title}      set variable    ${saved_recording_list_element[${index}]['children'][3]['textValue']}
    \   Append To List    ${contextual_menu_saved_recording_list}       ${recording_title}
    Log     ${contextual_menu_saved_recording_list}
    [Return]    ${contextual_menu_saved_recording_list}

Get The Recordings Listed In Saved Section Of Contextual Main Menu      #USED
    [Documentation]    This keyword navigates to Saved section in Contextual Main Menu and retrieves the recordings
    ...    names of the tiles displayed and set the list to a suite variable.
    @{saved_recordings_list}    Get The List Of Assets Displayed In Contextual Main Menu For Saved
    Set Suite Variable  ${CONTEXTUAL_MAIN_MENU_SAVED_RECORDINGS}     ${saved_recordings_list}

Check the Recordings Listed In Contextual Main Menu For Saved       #USED
    [Arguments]    ${saved_recordings_list}=${CONTEXTUAL_MAIN_MENU_SAVED_RECORDINGS}
    [Documentation]  This keyword navigates to SAVED Section in of Contextual Main Menu and checks if all the
    ...     items mentioned in ${saved_recordings_list} are displayed. ${CONTEXTUAL_MAIN_MENU_SAVED_RECORDINGS}  is suite
    ...     variable which contains the saved recordings title.
    @{saved_recordings_displayed}   Get The List Of Assets Displayed In Contextual Main Menu For Saved
    Lists Should Be Equal   ${saved_recordings_displayed}     ${saved_recordings_list}

Check that Contextual Main Menu For Saved Recordings Is Not Empty       #USED
    [Documentation]  This keyword navigates to SAVED Section in of Contextual Main Menu and checks
    ...     that Saved recordings is not empty
    Get The Recordings Listed In SAVED Section Of Contextual Main Menu
    Should Not Be Empty     ${CONTEXTUAL_MAIN_MENU_SAVED_RECORDINGS}

I Navigate to 'Continue Watching' On Saved And Check That The Collection Is Empty        #USED
    [Documentation]     This keyword navigates to 'Continue Watching' in SAVED and Checks that
    ...     the Collection is Empty
    I open Continue Watching through Saved
    Continue Watching collection screen on Saved view is empty

I Check That '${tile_title}' Is Available In 'Continue Watching' Collection On Saved      #USED
    [Documentation]     This keyword navigates to 'Continue Watching' in SAVED and Checks that
    ...     the Tile Name ${tile_title} is available in the collection
    I open Continue Watching through Saved
    I focus '${tile_title}' tile

I Navigate To A Random VOD Asset In Rented Section    #USED
    [Documentation]    This keyword navigates to a random VOD asset from the Rented Section if it is not empty.
    ...    Sets the title and crid id of that asset in a suite variable.
    ${collections_empty}    Run Keyword And Return Status    Rented Collection screen on Saved view is empty
    Should Not Be True    ${collections_empty}    'No Rented Asset Available'
    I Press    DOWN
    ${focused_elements}    Get Ui Focused Elements
    ${elem_is_focused}    Is In Json    ${focused_elements}    ${EMPTY}    id:shared-CollectionsBrowser_collection_\\d+    ${EMPTY}    ${True}
    Should Be True    ${elem_is_focused}    'Unable to navigate to a rented collection'
    ${vod_title}    ${vod_crid_id}    Return Random VOD Title In VOD Grid Page
    Set Suite Variable    ${LAST_FETCHED_VOD_ASSET}    ${vod_crid_id}
    Set Suite Variable    ${LAST_FETCHED_RENTED_VOD_TITLE}    ${vod_title}
    Move Focus to Tile in Grid Page    ${vod_title}    title

Verify Bookmark Of An Asset Titled '${title}' In Position '${position}' From Time '${progressbar_time}' In Continue Watching Section    #USED
    [Documentation]    This keyword verifies that the last watched asset is present as the first tile in the
    ...    continue watching section or navigates to asset with given title in saved page.It is verified that when being played, the asset starts from where it has stopped
    ...    precondition: continue watching section is open
    ...    PARAMETERS title: title of the asset for which bookmark has to be verified
    ...    position: if 1, verifies bookmark for the first tile in continue watching section, otherwise navigates to given title
    ...    in saved page and verifies bookmark
    Verify Bookmark Of An Asset Based On Position In Saved Page    ${title}    ${progressbar_time}    ${position}

Validate Asset '${asset_title}' In Watchlist For Content Type '${content_type}'    #USED
    [Documentation]    This keyword validates that given asset is present in Watchlist and validate the detailpage
    Should Not Be Empty  ${asset_title}    Variable ${asset_title} is not present
    Should Not Be Empty  ${content_type}    Variable ${content_type} is not present
    Move Focus to Collection Browser
    I focus '${asset_title}' tile
    I press    OK
    Common Details Page elements are shown
    Run Keyword If    '${content_type}' == 'REPLAY'    I expect page contains 'id:replayIconprimaryMetadata'

Validate Replay Icon Of The '${asset_title}' Asset In Saved Page    #USED
    [Documentation]    This keyword will validate the replay icon of the selected asset in watchlist section
    ${ancestor}    I retrieve json ancestor of level '3' in element 'textValue:^.*${asset_title}*' for element 'color:${HIGHLIGHTED_NAVIGATION_COLOUR}' using regular expressions
    ${result}    Is In Json    ${ancestor}    ${EMPTY}    iconKeys:REPLAY
    Should Be True    ${result}    replay icon not present for selected replay asset

Verify Bookmark Of An Asset Titled '${title}' In Position '${position}' From Time '${progressbar_time}' Not Present In Continue Watching Section    #USED
    [Documentation]  The keyword validates the asset with title : ${title} is not present at position ${position} with a progress time of ${progressbar_time}
    ${status}   Run Keyword And Return Status  Verify Bookmark Of An Asset Titled '${title}' In Position '${position}' From Time '${progressbar_time}' In Continue Watching Section
    Should Not Be True     ${status}    'Following asset - ${title} is present in continue watching section'

Validate Asset '${asset_title}' Not In Watchlist For Content Type '${content_type}'    #USED
    [Documentation]   Validates whether an asset is not present in watchlist
    ${status}   Run Keyword And Return Status    Validate Asset '${asset_title}' In Watchlist For Content Type '${content_type}'
    Should Not Be True   ${status}   'Following asset - ${asset_title} is present in watchlist'

#******************************************CPE PERFORMANCE*****************************************************

SAVED Grid Screen for given section is shown
    [Documentation]    This keyword asserts the SAVED grid screen for the given setion is shown.
    [Arguments]  ${only_highlight_check}=False    ${highlight_check}=True
    ${json_object}    Get Ui Json
    ${vod_grid_view}    Is In Json    ${json_object}    ${EMPTY}    id:OnDemand.View|Saved.View|Recordings.View    ${EMPTY}    ${true}
    Should Be True    ${vod_grid_view}  "SAVED Grid View is not Shown"
#    ${focused_section}    Get Enclosing Json    ${json_object}    ${EMPTY}    textValue:${section_name}    ${1}    ${EMPTY}
#    ${text_color}    Extract Value For Key    ${focused_section}    ${EMPTY}    color
#    run keyword if  ${highlight_check} == True    should be equal    '${text_color}'    '${HIGHLIGHTED_NAVIGATION_COLOUR}'
#    ...    Focused Section isn't correctly highlighted
#    return from keyword if    ${only_highlight_check} == True
     ${vod_tile_posters}    Is In Json    ${json_object}    ${EMPTY}
     ...   id:shared-CollectionsBrowser_collection_[\\d]+_tile_[\\d]+_poster    ${EMPTY}    ${True}
     Should Be True    ${vod_grid_view}  "SAVED Grid tile Posters are not Shown"