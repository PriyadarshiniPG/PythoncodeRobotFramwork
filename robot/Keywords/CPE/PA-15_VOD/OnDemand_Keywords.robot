*** Settings ***
Documentation     Keywords concerning the On Demand menu
Resource          ../PA-15_VOD/OnDemand_Implementation.robot

*** Keywords ***
I focus a VOD asset in On Demand
    [Documentation]    This keyword opens the automation section and focus VOD asset
    I open On Demand through Main Menu
    I open 'Automation'
    I focus entitled VOD movie asset

I open On Demand    #USED
    [Documentation]    This keyword opens the On Demand screen.
    ...    Precondition: Main Menu should be open.
    I focus On Demand
    I Press    OK
    On Demand is shown
#    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'id:scCo_.*' using regular expressions
#    Generate OnDemand category dictionary

I open On Demand through Main Menu    #USED
    [Documentation]    This keyword opens the On Demand screen via the Main Menu.
    I open Main Menu
    I open On Demand

I focus On Demand    #USED
    [Documentation]    This keyword focuses the 'On Demand' element in the Main Menu.
    Move Focus to Section    DIC_MAIN_MENU_MOVIES_AND_SERIES    textKey

Section Navigation is shown
    [Documentation]    This keyword asserts that the section navigation is shown.
    Wait Until Keyword Succeeds    10 times    1 s    I expect page contains 'id:SectionNavigationScrollContainershared-SectionNavigation'

I focus Providers
    [Documentation]    This keyword iterates over the VOD section navigation in order to focus Providers section.
    Move Focus to Section    ${ON_DEMAND_PROVIDERS_SECTION_ID}

Providers is shown
    [Documentation]    This keyword asserts that the Providers content is shown.
    Wait Until Keyword Succeeds    10 times    1 s    I expect page contains 'id:providerGridTile-.*' using regular expressions

I open On Demand through the remote button
    [Documentation]    This keyword opens the On Demand screen through the RCU from anywhere, produces a warning if
    ...    the On Demand screen is not shown, and populates the ${VOD_SECTION_IDS_DICTIONARY} variable.
    I open Channel Bar
    I Press    VOD
    On Demand is shown
    Generate OnDemand category dictionary

On Demand is shown    #USED
    [Documentation]    This keyword verifies that the On Demand screen is shown.
    I Wait For 2 Second
    Error popup is not shown
    Wait Until Keyword Succeeds    10 times    2 sec    I expect page contains 'id:CollectionsBase.View|VodCollections.View' using regular expressions

On Demand is not shown
    [Documentation]    This keyword verifies that the On Demand screen is not shown.
    ${textKey}    I retrieve value for key 'textKey' in element 'id:mastheadScreenTitle'
    Should Not Be Equal    ${textKey}    DIC_MAIN_MENU_MOVIES_AND_SERIES

I open '${category}'    #USED
    [Documentation]    This keyword opens the VOD category '${category}' in the VOD screen.
    ...    Precondition: VOD screen should be open.
    ${section_id}    wait until keyword succeeds    5 times    1 s    Get On Demand Section Id    ${category}
    Move Focus to Section    ${section_id}
    I wait for ${MOVE_ANIMATION_DELAY} ms
    Run keyword if    "${category}" != "Providers"    Wait Until Keyword Succeeds    10 times    300 ms    I expect page contains 'id:${COLLECTIONS_BROWSER_NODE_ID}' using regular expressions

Rent is shown
    [Documentation]    This keyword asserts rent content is shown.
    Rent is focused
    I expect page contains 'id:^.*CollectionsBrowser' using regular expressions

First section in Section Navigation is focused
    [Documentation]    This keyword asserts the first section in the VOD screen is focused.
    Section Position is Focused    1

VOD tiles are shown
    [Documentation]    This keyword asserts VOD tiles are shown.
    Wait Until Keyword Succeeds    5 times    1 s    Verify if vod tiles are shown by scrolling down

I focus First section in Section Navigation
    [Documentation]    This keyword iterates over the VOD section navigation in order to focus the First section.
    ...    Precondition: VOD screen should be open.
    Move Focus to Section Position    1

Second section in Section Navigation is focused
    [Documentation]    This keyword asserts the second section in the VOD screen is focused.
    Section Position is Focused    2

Search icon in Section Navigation is focused
    [Documentation]    This keyword asserts the Search icon in the VOD screen is focused.
    Section Position is Focused    0

I focus Search icon in Section Navigation
    [Documentation]    This keyword iterates over the VOD section navigation in order to focus the Search icon.
    ...    Precondition: VOD screen should be open.
    Move Focus to Section Position    0

Last section in Section Navigation is focused
    [Documentation]    This keyword asserts the last section in the VOD screen is focused.
    ${sections}    ${number_of_sections}    Get Current Sections
    Section Position is Focused    ${number_of_sections-1}

I focus Last section in Section Navigation
    [Documentation]    This keyword focuses the last section of the section navigation in the VOD screen.
    ...    Precondition: VOD screen should be open.
    ${sections}    ${number_of_sections}    Get Current Sections
    Move Focus to Section Position    ${number_of_sections-1}

Recordings collection screen is shown    #USED
    [Documentation]    This keyword verifies if the Recordings collection screen is shown - with assets or empty.
    Wait Until Keyword Succeeds    10 times    300 ms    Recordings collection screen is shown implementation

Watchlist grid screen is shown
    [Documentation]    This keyword verifies if the Watchlist grid screen is shown - with assets or empty.
    Wait Until Keyword Succeeds    10 times    300 ms    Watchlist grid screen is shown implementation

Rented grid screen is shown
    [Documentation]    This keyword verifies if the Rented grid screen is shown
    Wait Until Keyword Succeeds    20 times    1 s    Rented grid screen is shown implementation

I focus a VOD tile in section
    [Arguments]    ${section}=Movies    ${min_duration}=${VOD_ASSET_MIN_DURATION}    ${max_duration}=${VOD_ASSET_MAX_DURATION}    ${video_resolution}=Any
    ...    ${only_with_recommendations}=Any    ${duration_filter}=${True}
    [Documentation]    This keyword focuses an entitled VOD asset within duration ${min_duration} and ${max_duration} in the '${section}' from anywhere.
    ...    ${video_resolution} is the video quality of entitled asset to be selected. It can be Any/SD/HD.
    I open On Demand through Main Menu
    Get Entitled VOD Asset Titles From A Section In On Demand    ${section}    ${min_duration}    ${max_duration}    ${video_resolution}
    ...    ${only_with_recommendations}    ${duration_filter}

I focus a VOD tile from On Demand    #USED
    [Arguments]    ${min_duration}=${VOD_ASSET_MIN_DURATION}    ${max_duration}=${VOD_ASSET_MAX_DURATION}    ${video_resolution}=Any
    ...    ${only_with_recommendations}=Any    ${duration_filter}=${True}
    [Documentation]    This keyword focuses the entitled movie asset tile within duration ${min_duration} and ${max_duration} from the ${section}
    ...    If $only_with_recommendations is True, only the entitled asset with recommendations is returned.
    ...    ${video_resolution} is the video quality of entitled asset to be selected. It can be Any/SD/HD.
    ...    If ${duration_filter} is True, the filter is applied based on duration, otherwise just checks duration > 0
    ...    Precondition: VOD screen should be open.
    ${vod_asset_list}    Create List
    :FOR    ${section_name}    IN    @{VOD_SECTION_IDS_DICTIONARY.keys()}
    \    Continue For Loop If  '''${section_name}''' == '''x'''
    \    Continue For Loop If  '''${section_name}''' == '''series'''
    \    ${provider_name}    Get Tenant Specific Name For Providers Section    ${False}
    \    ${provider_name}    Run Keyword If    '''${provider_name}'''!='''${None}'''    Convert To Lowercase    ${provider_name}
    \    Run Keyword If    '''${provider_name}'''!='''${None}'''    Continue For Loop If    '''${section_name}'''=='''${provider_name}'''
    \    ${section}    Set Variable    ${section_name}
    \    ${vod_asset_list}    Get Entitled VOD Asset Titles From A Section In On Demand    ${section_name}
    ...    ${min_duration}    ${max_duration}    ${video_resolution}    ${only_with_recommendations}    ${duration_filter}
    \    ${assets_found}    Run Keyword And Return Status    Should Not Be Empty    ${vod_asset_list}
    \    Exit For Loop If    ${assets_found}
    Should Not Be Empty    ${vod_asset_list}    VOD asset with given duration is not found
    ${random_vod_details}    Get Random Element From Array    ${vod_asset_list}
    Set Suite Variable    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}    ${random_vod_details}
    Set Suite Variable    ${TILE_TITLE}    ${random_vod_details['title']}
    Set Suite Variable    ${VOD_SECTION_WITH_REQUIRED_ASSET}    ${section}
    I open '${section}'
    I press    DOWN
    I focus '${TILE_TITLE}' tile
    ${crid_id}    Get Asset Crid From Vodscreen Response Of An Asset    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}
    Set Suite Variable    ${TILE_CRID}    ${crid_id}
    Identify Promotional Tile And Get Detailscreen Title    ${section_name}    ${TILE_TITLE}    ${TILE_CRID}

I Focus A VOD Tile From On Demand With Resolution '${video_resolution}'    #USED
    [Documentation]    This keyword focuses the entitled movie asset tile from any section in on demand
    ...    ${video_resolution} is the video quality of entitled asset to be selected. It can be Any/SD/HD
    ...    Precondition: VOD screen should be open.
    I focus a VOD tile from On Demand    ${VOD_ASSET_MIN_DURATION}    ${VOD_ASSET_MAX_DURATION}    ${video_resolution}
    ...    Any    ${False}

Get Entitled VOD Asset Titles From A Section In On Demand    #USED
    [Documentation]    This Kewyord will get SVOD Or Already Purchased TVOD Asset Titles for a given ${section} from On Demand. Unentitled TVOD assets
    ...    and assets with 4K resolution are excluded.
    ...    If $only_with_recommendations is True, only the entitled asset with recommendations is returned.
    ...    ${video_resolution} is the video quality of entitled asset to be selected. It can be Any/SD/HD
    ...    If ${duration_filter} is True, the filter is applied based on duration, otherwise just checks duration > 0
    [Arguments]    ${section}    ${min_duration}=${VOD_ASSET_MIN_DURATION}    ${max_duration}=${VOD_ASSET_MAX_DURATION}    ${video_resolution}=Any
    ...    ${only_with_recommendations}=Any    ${duration_filter}=${True}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${vod_asset_list}    Create List
    @{movie_details}    Get Content    ${LAB_CONF}    ${section}    ASSET    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}    ${ROOT_ID}
    ...    ${CUSTOMER_ID}    all
    : FOR    ${movie}    IN    @{movie_details}
    \    ${crid_id}    Get Asset Crid From Vodscreen Response Of An Asset    ${movie}
    \    ${asset_details}    I Get Details Of A VOD Asset With Given Crid Id    ${crid_id}    ${cpe_profile_id}
    \    ${is_rental}    Check Whether VOD Asset Is Unentitled From Asset Details    ${asset_details}
    \    Continue For Loop If    ${is_rental}
    \    ${response}    Get All Recommendations For The Selected Asset    ${2}    ${crid_id}
    \    Run Keyword If    "${only_with_recommendations}"!="Any"    Continue For Loop If    ${response}==None or len(${response})==0
    \    ${is_4K}    Run Keyword If    "${video_resolution}"=="Any"
    ...    Check Whether VOD Asset Has Multiple Instances From Asset Details    ${asset_details}    ${True}
    \    Continue For Loop If    "${video_resolution}"=="Any" and ${is_4K}
    \    ${is_multiple_quality}   Check Whether VOD Asset Has Multiple Instances From Asset Details    ${asset_details}
    \    Run Keyword If    "${video_resolution}"!="Any"    Continue For Loop If    ${is_multiple_quality}
    \    ${resolution}    Extract Value For Key    ${asset_details}    ${EMPTY}    resolution    ${False}
    \    Continue For Loop If    "${resolution}"=="4K"
    \    Run Keyword If    "${video_resolution}"!="Any"    Continue For Loop If    "${video_resolution}"!="${resolution}"
    \    ${movie_duration}    Set Variable    ${asset_details['duration']}
    \    ${is_entitled}    Is In Json    ${asset_details}    ${EMPTY}    entitled:true    ${EMPTY}
    \    Continue For Loop If  ${is_entitled} == False
    \    ${duration_filter_valid}    Set Variable If    ${movie_duration} > ${min_duration} and ${movie_duration} < ${max_duration}
    ...    ${True}    ${False}
    \    ${duration_valid}    Set Variable If    ${movie_duration} > ${0}    ${True}    ${False}
    \    ${title}    Set Variable If    ${duration_filter} and ${duration_filter_valid}    ${movie['title']}
    ...    ${duration_filter}==${False} and ${duration_valid}    ${movie['title']}    ${EMPTY}
    \    ${title_is_not_empty}    Run Keyword And Return Status    Should Not Be Empty    ${title}    VOD asset with given duration is not found
    \    Run Keyword If    ${title_is_not_empty}    Append To List    ${vod_asset_list}    ${movie}
    [Return]    ${vod_asset_list}

I focus the second tile from 'MOVIES' section in On Demand
    [Documentation]    This keyword focuses the second tile of any type from the 'Movies' section
    ...    Precondition: VOD screen should be open.
    I open 'Movies'
    Move to element assert focused elements using regular expression    id:shared-CollectionsBrowser_collection_\\\\d+_tile_0    4    DOWN
    I press    RIGHT

I select a VOD tile from On Demand    #USED
    [Documentation]    This keyword opens an entitled VOD asset from any section in On Demand
    I focus a VOD tile from On Demand
    I press    INFO

I Focus a VOD tile from On Demand Which Has Recommendations    #USED
    [Documentation]    This keyword opens the first asset tile from the 'Movies' section which has recommendation
    I focus a VOD tile from On Demand    ${VOD_ASSET_MIN_DURATION}    ${VOD_ASSET_MAX_DURATION}    Any    True

I focus a VOD Asset detail page with Multiple languages
    [Documentation]    This keyword opens Movies section and focus the asset tile
    ...    saved in the ${MULTIPLE_LANGUAGES_VOD_MOVIE} variable
    I open 'Movies'
    I focus '${MULTIPLE_LANGUAGES_VOD_MOVIE}' tile

I focus a series tile in Series section
    [Documentation]    This keyword focuses any tile in the 'Series' section.
    ...    Precondition: VOD screen should be open.
    I focus a VOD episode tile

I make sure budget limit is set to
    [Arguments]    ${budget}=${BUDGET_HIGH}
    [Documentation]    This keyword sets the budget via itfaker to the given ${budget} and
    ...    immediately verifies the budget was set to the given value.
    ${status}    run keyword and return status    I set budget limit to    ${budget}
    run keyword unless    ${status}    Log    Set budget reported failure    WARN
    ${budget_limit}    get budget limit    ${LAB_TYPE}    ${CPE_ID}    ${CA_ID}
    run keyword unless    '${budget_limit}'=='${budget}'    fail    failed to set budget to ${budget}

Asset is playing in player
    [Documentation]    This keyword verifies content is being played. After that, it attempts to show the Details Page
    ...    by pressing the BACK button.
    ...    Precondition: Player is displayed to play VOD asset
    ${resume}    run keyword and return status    'Continue Watching' popup is shown
    run keyword if    ${resume}==${True}    I select the 'Continue Watching' action
    wait until keyword succeeds    5times    3s    I expect page contains 'id:Player.View'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I prevent vod player progress bar from disappearing
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:playerControlsPanel-Player'
    content available
    : FOR    ${i}    IN RANGE    5
    \    I Press    BACK
    \    ${status}    run keyword and return status    Linear Details Page is shown
    \    run keyword if    ${status}==${True}    Exit For Loop

Validate Asset is Playing in Player And Exit Playback    #USED
    [Documentation]    This keyword verifies content is being played. After that, it attempts to show the Details Page
    ...    by pressing the BACK button.
    ...    Precondition: Player is displayed to play VOD asset
    Run Keyword And Ignore Error    About to start screen is shown
    Error popup is not shown
    Wait Until Keyword Succeeds    5times    3s    I expect page contains 'id:Player.View'
    Show Video Player bar
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    1 s    I expect page element 'id:trickPlayIcon-(Linear|NonLinear)InfoPanel' contains 'iconKeys:TRICKPLAY_PLAY' using regular expressions
    Exit VOD Playback

Exit VOD Playback    #USED
    [Documentation]    This keyword exit the playback by pressing the BACK button.
    Error popup is not shown
    : FOR    ${i}    IN RANGE    5
    \    I Press    BACK
    \    ${status}    Run Keyword And Return Status    Linear Details Page is shown
    \    Run Keyword If    ${status}==${True}    Exit For Loop

VOD movie tile is shown
    [Documentation]    This keyword verifies that a VOD movie is present in the Watchlist screen.
    Watchlist is focused
    Wait Until Keyword Succeeds    40 times    1 s    Watchlist collection is visible
    wait until keyword succeeds    10 times    1 s    I do not expect page contains 'textKey:DIC_GENERIC_EPISODE_NUMBER'
    wait until keyword succeeds    20 times    1 s    I expect page contains 'textKey:DIC_GENERIC_(MULTI_)?PRICE' using regular expressions

Adult area is shown
    [Documentation]    This keyword gets the title of the first asset in the Adult VOD section and
    ...    verifies if it's present in the current screen.
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    &{movie_details}    Get Content    ${LAB_CONF}    Passion    ASSET    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}
    ...    ${CUSTOMER_ID}
    Should Not Be Empty    &{movie_details}[title]
    wait until keyword succeeds    10 times    3 sec    I expect page contains 'textValue:.*&{movie_details}[title].*' using regular expressions

'WATCH' or 'PLAY FROM START' actions are shown
    [Documentation]    This keyword verifies if 'Watch' or 'Play from start' option is shown on Details Page.
    wait until keyword succeeds    5s    0    I expect page contains 'textKey:(DIC_ABOUT_TO_START_HEADER|DIC_ACTIONS_PLAY_FROM_START|DIC_ACTIONS_WATCH)' using regular expressions

I rent a VOD movie
    [Documentation]    This keyword rents a movie from the 'Movies' VOD section in On Demand from anywhere.
    I try to rent a VOD movie
    Pin Entry popup is dismissed

I try to rent VOD assets for '${amount}' budget
    [Documentation]    This keyword attempts to rent a movie from the rental VOD section
    ...    of the On Demand screen menu up to ${amount} budget.
    I open On Demand through Main Menu
    I open rental category in vod
    I navigate to all genres vod screen
    ${max_assets}    retrieve asset count in open vod grid
    ${count}    set variable    0
    ${amount}    convert to integer    ${amount}
    : FOR    ${i}    IN RANGE    ${1}    ${max_assets}
    \    wait until keyword succeeds    3 times    100 ms    I open VOD Detail Page
    \    ${json_object}    Get Ui Json
    \    ${rent_for_presence}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_ACTIONS_RENT
    \    run keyword if    ${rent_for_presence}==False    run keywords    I press    INFO
    \    ...    AND    wait until keyword succeeds    20 times    100 ms    VOD Detail Page is not shown
    \    ...    AND    set test variable    ${old_json}    Get Ui Json
    \    ...    AND    I press    RIGHT
    \    ...    AND    wait until keyword succeeds    10 times    1s    Assert json changed
    \    ...    ${old_json}
    \    ...    AND    continue for loop
    \    ${rental_string}    I retrieve value for key 'textValue' in element 'textKey:DIC_ACTIONS_RENT'
    \    @{splitted_string_fore}    Split String    ${rental_string}    separator=RENT FOR €
    \    @{splitted_string_back}    Split String    @{splitted_string_fore}[1]    separator=.00
    \    ${rental_value}    set variable    @{splitted_string_back}[0]
    \    ${projected_budget}    set variable    ${${count} + ${rental_value}}
    \    ${is_budget_still_available}    evaluate    ${projected_budget} <= ${amount}
    \    run keyword if    ${projected_budget} > ${amount}    run keywords    I press    INFO
    \    ...    AND    wait until keyword succeeds    20 times    100 ms    VOD Detail Page is not shown
    \    ...    AND    set test variable    ${old_json}    Get Ui Json
    \    ...    AND    I press    RIGHT
    \    ...    AND    wait until keyword succeeds    10 times    1s    Assert json changed
    \    ...    ${old_json}
    \    ...    AND    return from keyword
    \    Move Focus to Section    DIC_ACTIONS_RENT    textKey
    \    I press    OK
    \    I enter a valid pin for VOD Rent
    \    ${is_error_reported}    run keyword and return status    Usage limit error popup is shown
    \    run keyword if    ${is_error_reported}    return from keyword
    \    wait until keyword succeeds    20 times    1 sec    I expect page contains 'textKey:DIC_ABOUT_TO_START_HEADER'
    \    I press    RIGHT
    Fail    not able to book all required assets

Option '${option}' is shown in Contextual key menu
    [Documentation]    This keyword verifies if the ${option} option is shown in the Contextual key menu.
    Run Keyword If    '${option}' == 'Add to Watchlist'    wait until keyword succeeds    ${JSON_MAX_RETRIES}    1s    I expect page contains 'textKey:DIC_ACTIONS_CTXK_ADD_TO_WATCHLIST'
    ...    ELSE IF    '${option}' == 'Rent for'    wait until keyword succeeds    ${JSON_MAX_RETRIES}    1s    I expect page contains 'textKey:DIC_ACTIONS_RENT'

Contextual key menu is shown
    [Documentation]    This keyword verifies if the Contextual key menu is shown.
    ${picker_displayed}    Run Keyword And Return Status    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:value-picker'
    Run Keyword If    not ${picker_displayed}    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:ValuePicker'

I focus rented VOD movie
    [Documentation]    This keyword attempts to navigate to the 'Movies' VOD section of the On Demand screen,
    ...    and focuses the movie tile of the asset title saved in the ${RENTED_MOVIE_TITLE} variable.
    Variable should exist    ${RENTED_MOVIE_TITLE}    A movie has not been rented. RENTED_MOVIE_TITLE does not exist.
    I open 'Movies'
    I press    DOWN
    I focus '${RENTED_MOVIE_TITLE}' tile

I focus fourth section in Section Navigation
    [Documentation]    This keyword focuses the fourth section of the section navigation in the VOD screen.
    ...    Precondition: VOD screen should be open.
    Move Focus to Section Position    4

I open the adult entry tile in the Erotiek section of OnDemand
    [Documentation]    This keyword attempts to navigate to the 'Erotiek' VOD section of the On Demand screen,
    ...    and focuses and select the Adult entry tile.
    ...    Precondition: STB language should be set to NL.
    I open On Demand through Main Menu
    I open 'Erotiek'
    I focus adult entry tile
    I press    OK

Adult section in On Demand is shown
    [Documentation]    This keyword gets the title of the first asset in the Adult section and
    ...    verifies if it's present in the current screen.
    Adult area is shown

Adult section in On Demand is not shown
    [Documentation]    This keyword gets the title of the first asset in the Adult section and
    ...    checks if it isn't present in the current screen.
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    &{movie_details}    Get Content    ${LAB_CONF}    Passion    ASSET    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}
    ...    ${CUSTOMER_ID}
    Should Not Be Empty    &{movie_details}[title]
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textValue:.*&{movie_details}[title].*' using regular expressions

I focus a Series tile
    [Documentation]    This keyword attempts to navigate to the 'Series' VOD section of the On Demand screen,
    ...    gets the title of the first asset in the Series section and focuses the corresponding tile, saving
    ...    the title in the ${TILE_TITLE} variable.
    I open 'Series'
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    &{series_details}    Get Content    ${LAB_CONF}    Series    SERIES    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}
    ...    ${CUSTOMER_ID}
    Should Not Be Empty    &{series_details}[title]
    set test variable    ${TILE_TITLE}    &{series_details}[title]
    I press    DOWN
    I focus '${TILE_TITLE}' tile

Series title is shown on VOD Detail Page
    [Documentation]    This keyword verifies if the series title saved in the ${TILE_TITLE} variable
    ...    is shown on the VOD Detail Page.
    ...    Precondition: A VOD Details Page screen should be open.
    Variable should exist    ${TILE_TITLE}    The title of a VOD asset tile has not been saved. TILE_TITLE does not exist.
    Wait Until Keyword Succeeds    5 times    1s    I expect page contains 'id:DetailPagePosterBackground'
    ${title_container}    I retrieve json ancestor of level '1' for element 'id:title'
    ${text_title}    Is In Json    ${title_container}    ${EMPTY}    textValue:^.*${TILE_TITLE}.*$    ${EMPTY}    ${True}
    ${image}    Extract Value For Key    ${title_container}    id:title    image
    ${image_title}    run keyword and return status    Should Not Contain    ${image}    emptypixel.png
    ${is_title_present}    Evaluate    True if ${text_title} or ${image_title} else False
    Should Be True    ${is_title_present}

Series title is shown on Saved view
    [Documentation]    This keyword verifies if the series title saved in the ${TILE_TITLE} variable is
    ...    shown on the Saved view.
    wait until keyword succeeds    40 times    1 s    Series title is shown on Saved view implementation

I open details page for series asset
    [Documentation]    This keyword focuses a series title and opens the Details Page.
    I open the Details Page of a series asset with episodes in VOD

I Add The Asset To Watchlist    #USED
    [Documentation]    This keyword adds the current asset to the Watchlist
    ...    Precondition: A VOD Details Page screen should be open.
    ${is_already_added}    Run Keyword And Return Status    'REMOVE FROM WATCHLIST' action is shown
    Run Keyword If    ${is_already_added}    I select 'Remove from watchlist' in a Detail Page
    I Wait For 2 Seconds
    I open Add To Watchlist
    'ADD TO WATCHLIST' Toast message is shown

Entire series is added to watchlist
    [Documentation]    This keyword opens the Watchlist and verifies the series asset saved in the ${TILE_TITLE}
    ...    variable has been added to the Watchlist.
    I open Saved through Main Menu
    I focus Watchlist
    I do not expect page contains 'textKey:DIC_WATCHLIST_EMPTY_TITLE'
    I focus the first asset in the Watchlist
    I press    INFO
    Series title is shown on VOD Detail Page
    'Episodes' action is shown

VOD series tile is shown
    [Documentation]    This keyword verifies that VOD series tile of the series asset title saved in
    ...    the ${TILE_TITLE} is shown in the current screen.
    Variable should exist    ${TILE_TITLE}    The title of a VOD asset tile has not been saved. TILE_TITLE does not exist.
    Wait Until Keyword Succeeds    40 times    1 s    Watchlist collection is visible
    ${TILE_TITLE}    convert to lowercase    ${TILE_TITLE}
    ${TILE_TITLE}    Replace String    ${TILE_TITLE}    ${SPACE}    _
    ${json_object}    Get Ui Json
    ${json_string}    Read Json As String    ${json_object}
    @{collecion_containers}    get regexp matches    ${json_string}    shared-CollectionsBrowser_collection_\\d+
    wait until keyword succeeds    10 times    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:@{collecion_containers}[0]_tile_\\\\d+' using regular expressions
    ${background}    I retrieve value for key 'background' in element 'id:@{collecion_containers}[0]_tile_\\d+' using regular expressions
    should contain    ${background['image']}    ${TILE_TITLE}

I focus a Season tile
    [Documentation]    This keyword opens the 'Series' VOD section of the On Demand screen,
    ...    focuses a season tile saving the series title in the ${TILE_TITLE} variable.
    ...    Precondition: VOD screen should be open.
    I open 'Series'
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    &{season}    Get Content    ${LAB_CONF}    Series    SEASON    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}
    ...    ${CUSTOMER_ID}
    Should not be empty    &{season}[seriesTitle]
    set test variable    ${TILE_TITLE}    &{season}[seriesTitle]
    I press    DOWN
    I focus '${TILE_TITLE}' tile

I focus an Episode tile
    [Documentation]    This keyword opens the 'Films_PM_NL' VOD section of the On Demand screen, focuses
    ...    an episode with seasons saving the series title in the ${TILE_TITLE} variable.
    ...    Precondition: STB language should be set to NL.
    I open 'Series'
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    &{episode_details}    Get Content    ${LAB_CONF}    Movies    EPISODE    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}
    ...    ${CUSTOMER_ID}
    Should Not Be Empty    &{episode_details}[seriesTitle]
    I press    DOWN
    set test variable    ${TILE_TITLE}    &{episode_details}[seriesTitle]
    I focus '${TILE_TITLE}' tile

I focus VOD series tile
    [Documentation]    This keyword focuses a VOD series tile in the 'Watchlist' section in Saved.
    Wait Until Keyword Succeeds    40 times    1 s    Watchlist collection is visible
    I press    DOWN
    VOD series tile is focused

I focus ON DEMAND through Contextual Main Menu
    [Documentation]    This keyword opens the Main Menu, and focuses the On Demand navigation item.
    I open Main Menu
    wait until keyword succeeds    3 times    1 s    Contextual Main Menu is shown
    I focus On Demand

I open On Demand through contextual main menu
    [Documentation]    This keyword opens the On Demand screen via Contextual Main Menu.
    I focus ON DEMAND through Contextual Main Menu
    I press    OK
    On Demand is shown
    Generate OnDemand category dictionary

I open '${times}' times On Demand through contextual main menu
    [Documentation]    This keyword opens '${times}' times the On Demand screen via Contextual Main Menu.
    I focus ON DEMAND through Contextual Main Menu
    : FOR    ${_}    IN RANGE    ${times} - 1
    \    I press    OK
    \    On Demand is shown
    \    And VOD tiles are shown
    \    I press    BACK
    \    wait until keyword succeeds    3 times    1 s    Contextual Main Menu is shown
    I press    OK
    On Demand is shown
    And VOD tiles are shown
    Generate OnDemand category dictionary

I open first tile for Recently Added
    [Documentation]    This keyword attempts to open the first tile on 'Recently Added'
    ...    and verifies the Details Page is shown.
    ...    Precondition: The Main Menu should be open and the On Demand section focused.
    I Press    DOWN
    I press    LEFT
    I Press    OK
    Linear Details Page is shown

I open first tile for Recomended for you
    [Documentation]    This keyword attempts to open the first tile on 'Recomended for you'
    ...    and verifies the Details Page is shown.
    ...    Precondition: The Main Menu should be open and the On Demand section focused.
    I Press    DOWN
    I Press    OK
    Linear Details Page is shown

Recently Added Is Shown    #USED
    [Documentation]    This keyword verifies if the 'Recently Added' label is shown. Precondition: CMM is opened as per country.
    ${current_country_code}    get country code from stb
    ${current_country_code}     Convert To Uppercase    ${current_country_code}
    Run Keyword if    '${current_country_code}' != 'CH' and '${current_country_code}' != 'CL'    Wait Until Keyword Succeeds    10sec    0s    I expect page contains 'id:contextualMainMenu-navigationContainer-MOVIES_SERIES_title_1'
    ...   ELSE    Run Keyword    Wait Until Keyword Succeeds    10sec    0s    I do not expect page contains 'id:contextualMainMenu-navigationContainer-MOVIES_SERIES_title_1'

Recommended For You Is Shown    #USED
    [Documentation]    This keyword verifies if the 'Recomended for you' label is shown as per country
    ${current_country_code}    get country code from stb
    ${current_country_code}     Convert To Uppercase    ${current_country_code}
    Run Keyword if    '${current_country_code}' != 'CH' and '${current_country_code}' != 'CL'    Wait Until Keyword Succeeds    10sec    0s    I expect page contains 'id:contextualMainMenu-navigationContainer-MOVIES_SERIES_title_0'

I open a grid screen
    [Documentation]    This keyword opens the 'All' grid screen of the 'Series' VOD section in
    ...    the On Demand screen, and verifies the VOD grid screen is shown.
    I focus Grid entry tile in 'Series' in 'All'
    I press    OK
    VOD Grid Screen is shown

I open an editorial grid screen
    [Documentation]    This keyword opens the 'Telenet' editorial grid screen of the 'Films_PM_NL' VOD section in
    ...    the On Demand screen, and verifies an editorial grid screen is shown.
    I focus Grid entry tile in 'Films_PM_NL' in 'Telenet'
    I press    OK
    Editorial grid screen is shown
    Dismiss Tips and Tricks screen

I open a second level editorial grid screen
    [Documentation]    This keyword opens a second level editorial grid screen from the
    ...    'Providers' section, saving the title of the second level screen in
    ...    the ${EDITORIAL_GRID_SCREEN_TITLE} variable and setting the ${SECOND_LEVEL_EDITORIAL_GRID} to true.
    I open 'Providers'
    ${old_json}    Get Ui Json
    I press    DOWN
    Assert json changed    ${old_json}
    Set Test Variable    ${EDITORIAL_GRID_SCREEN_TITLE}    SBS6
    I focus '${EDITORIAL_GRID_SCREEN_TITLE}' in providers section
    I press    OK
    Second level collections screen with section navigation is shown
    Set Test Variable    ${SECOND_LEVEL_EDITORIAL_GRID}    ${True}
    Wait until keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:^.*CollectionsBrowser' using regular expressions
    ${old_json}    Get Ui Json
    I press    DOWN
    wait until keyword succeeds    10 times    1 sec    Assert json changed    ${old_json}
    Move Focus to Grid Collection
    Move Focus to Grid Link
    I press    OK
    wait until keyword succeeds    10 times    1 sec    I expect page contains 'id:.*CollectionsBrowser' using regular expressions

Series VOD is available
    [Documentation]    This keyword focuses a series tile in the 'Series' VOD section of the On Demand screen.
    I focus a series tile in Series section

I select an asset available for renting
    [Documentation]    This keyword searches and focuses a non entitled (not rented)
    ...    and unwatched asset from the rental category.
    I open rental category in vod
    I navigate to all genres vod screen
    ${rental_action}    I open non-entitled asset in current grid
    Move Focus to Section    ${rental_action}    textKey
    I press    OK
    # If DIC_GENERIC_AMOUNT_HOUR is highlighted, need to press OK again to open the pip entry popup, otherwise, the popup is already opened
    ${status}    run keyword and return status    wait until keyword succeeds    5 times    100 ms    I expect page contains 'id:interactiveModalPopup'
    run keyword if    ${status}    I press    OK
    Pin Entry popup is shown

I rent a non-adult asset
    [Arguments]    ${section_name}=Ontdek_ext
    [Documentation]    This keyword opens the On Demand screen from anywhere and rents one non-adult asset, saving
    ...    the asset's title in the ${NON_ADULT_RENTED_TILE_TITLE} variable.
    I open On Demand through the remote button
    run keyword if    '${section_name}' != 'Ontdek_ext'    run keywords    rented VOD asset is available
    ...    AND    return from keyword
    #The below section is to keep compatibility with Helmond profile based tests
    I open '${section_name}'
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    &{movie_details}    Get Content    ${LAB_CONF}    ${section_name}    ASSET    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}
    ...    ${CUSTOMER_ID}
    Should Not Be Empty    &{movie_details}[title]
    Set Test Variable    ${NON_ADULT_RENTED_TILE_TITLE}    &{movie_details}[title]
    I press    DOWN
    I focus '${NON_ADULT_RENTED_TILE_TITLE}' tile
    I open VOD Detail Page
    I select valid rent option
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_PURCHASE_PIN_ENTRY_MESSAGE'
    I enter a valid pin for VOD Rent
    Purchase flow continues

'About to start' screen is shown
    [Documentation]    This keyword verifies if the message 'About to start' is shown.
    Wait until keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ABOUT_TO_START_HEADER'

Contextual key menu is closed
    [Documentation]    This keyword verifies that the contextual key menu is closed.
    Wait until keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textKey:DIC_ACTIONS_ADD_TO_WATCHLIST'
    Wait until keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textKey:DIC_ACTIONS_RENT'

'Subscribe' option is focused
    [Documentation]    This keyword verifies if the 'Subscribe' is focused.
    Option is Focused in Value Picker    textKey:DIC_ACTIONS_SUBSCRIBE

I Open any VOD Asset detail page
    [Documentation]    This keyword focuses a VOD tile in the On Demand screen,
    ...    opens a VOD asset Details Page, and verifies the Details Page is shown.
    I focus a VOD tile from On Demand
    I press    OK
    VOD Details Page is shown

I Open Any VOD Asset    #USED
    [Documentation]    This keyword focuses a VOD tile in the On Demand screen,
    ...    opens a VOD asset Details Page, and verifies the Details Page is shown.
    I focus a VOD tile from On Demand
    I press    OK

Validate Vod Detail Page    #USED
    [Documentation]    This keyword verifies the Details Page of VOD.
    VOD Details Page is shown
    Genre and Subgenre are shown in Primary metadata
    Synopsis is shown on the Detail Page
    Duration is shown in Primary metadata
    Year of production is shown in Primary metadata
    Poster Is Shown In DetailPage

First action is focused    #USED
    [Documentation]    This keyword verifies the first action is focused.
    Section Position is Focused    0

Partially watched Adult asset is available
    [Documentation]    This keyword purchases an adult asset, partially watches the same, and then stops the playback.
    I make sure budget limit is set to    ${BUDGET_HIGH}
    I rent one adult asset
    'About to start' screen is shown
    wait until keyword succeeds    20s    1s    Player is in PLAY mode
    I wait for 5 seconds
    I press    STOP
    'WATCH' or 'PLAY FROM START' actions are shown

Adult VOD asset is not shown
    [Documentation]    This keyword verifies the rented adult asset
    ...    title saved in the ${RENTED_ADULT_ASSET} variable is not shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textValue:${RENTED_ADULT_ASSET}'

'Subscribe' modal popup is shown in On Demand
    [Documentation]    This keyword verifies the subscribe option is shown in the subscribe modal popup.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:interactiveModalPopupTitle' contains 'textKey:DIC_INFO_HEADER_SUBSCRIBE_PRODUCT'

I navigate to unsubscribed boxset series svod tile
    [Documentation]    This keyword opens a second level grid screen and attempts to
    ...    focus the asset tile saved in the ${SVOD_SUBSCRIBE_BOXSET_SERIES_TILE} variable.
    ...    Precondition: VOD screen should be open.
    I focus '${SVOD_SUBSCRIBE_BOXSET_SERIES_TILE}' tile

I navigate to non-entitled boxset series tvod tile
    [Documentation]    This keyword opens a second level grid screen and attempts to
    ...    focus the asset tile saved in the ${TVOD_RENT_TILE_BOXSET_SERIES_TILE} variable.
    ...    Precondition: VOD screen should be open and the tile should be non-entitled
    I focus '${TVOD_RENT_BOXSET_SERIES_TILE}' tile

I navigate to subscribed boxset series svod tile
    [Documentation]    This keyword opens a second level grid screen and attempts to
    ...    focus the asset tile saved in the ${SVOD_SUBSCRIBE_BOXSET_SERIES_TILE} variable.
    ...    Precondition: VOD screen should be open and the method "I am subscribed to SVOD products"
    ...    should be already called
    I focus '${SVOD_SUBSCRIBE_BOXSET_SERIES_TILE}' tile

I navigate to unsubscribed TV Show series svod tile
    [Documentation]    This keyword opens a second level grid screen and attempts to
    ...    Precondition: The ${SVOD_SUBSCRIBE_TV_SHOW_SERIES_TILE} variable should exist.
    variable should exist    ${SVOD_SUBSCRIBE_TV_SHOW_SERIES_TILE}    SVOD_SUBSCRIBE_TV_SHOW_SERIES_TILE does not exist
    I focus '${SVOD_SUBSCRIBE_TV_SHOW_SERIES_TILE}' tile

I navigate to non-entitled TV Show series tvod tile
    [Documentation]    This keyword opens a second level grid screen and attempts to
    ...    Precondition: The ${TVOD_RENT_TV_SHOW_SERIES_TILE} variable should exist
    ...    Precondition: VOD screen should be open and the tile should be non-entitled
    variable should exist    ${TVOD_RENT_TV_SHOW_SERIES_TILE}    TVOD_RENT_TV_SHOW_SERIES_TILE does not exist
    I focus '${TVOD_RENT_TV_SHOW_SERIES_TILE}' tile

I Navigate to VOD grid through Series section
    [Documentation]    This keyword opens a VOD grid via a 'Show all' tile
    ...    in the 'Series' VOD section in the On Demand screen.
    ...    Precondition: VOD screen should be open.
    I open 'Series'
    I focus Show all in VOD
    I press    OK

I navigate to svod tile in movies section
    [Documentation]    This keyword navigates in movies section looking for SVOD movie tile
    ${nodes}    Get Ui Focused Elements
    ${collections_data}    Extract Value For Key    ${nodes}    id:^.*CollectionsBrowser    data    ${True}
    ${number_of_collections}    Get Length    ${collections_data}
    : FOR    ${_}    IN RANGE    ${number_of_collections}
    \    Skip A-Spot collection
    \    Skip promotional and editorial tiles
    \    ${found}    Find SVOD Tile in Collection
    \    Skip grid entry tiles
    \    Exit For Loop If    ${found}
    \    Press Key    DOWN
    \    ${end_of_section_reached}    Is Back to top focused
    \    Exit For Loop If    ${end_of_section_reached}
    Should be true    ${found}    Svod Movie is not found

I add TVOD movie with no trailer to Watchlist
    [Documentation]    This keyword opens the 'Movies' VOD section in the On Demand screen, focuses the
    ...    asset tile with the title saved in the ${TVOD_NO_TRAILER} variable and adds it to the Watchlist.
    I open On Demand through Main Menu
    I open 'Movies'
    I navigate to all genres vod screen
    I focus '${TVOD_NO_TRAILER}' tile
    I open VOD detail Page
    I open Add To Watchlist

I select 'Remove from watchlist' in the Contextual key menu
    [Documentation]    This keyword verifies the 'Remove from watchlist' action is shown in the Contextual key menu,
    ...    and focuses and select it.
    Move Focus to Option in Value Picker    textKey:DIC_ACTIONS_CTXK_REMOVE_FROM_WATCHLIST    DOWN    8
    I press    OK

I rent a short VOD asset
    [Documentation]    This keyword searches for the VOD assets saved in the ${SHORT_DURATION_VOD_ASSETS} variable,
    ...    focuses one of them, and rents the focused asset from the Details Page.
    ${length}    Get Length    ${SHORT_DURATION_VOD_ASSETS}
    : FOR    ${index}    IN RANGE    ${0}    ${length}
    \    set test variable    ${TILE_TITLE}    ${SHORT_DURATION_VOD_ASSETS[${index}]}
    \    I open Search through Main Menu
    \    I search for VOD
    \    ${is_found}    run keyword and return status    Series VOD is shown in search results
    \    run keyword if    ${is_found}==False    run keywords    I press    MENU
    \    ...    AND    Main Menu is shown
    \    ...    AND    set test variable    ${TILE_TITLE}    ${EMPTY}
    \    ...    AND    continue for loop
    \    ON DEMAND source is shown
    \    I press    OK
    \    linear details page is shown
    \    exit for loop
    run keyword if    '${TILE_TITLE}'=='${EMPTY}'    fail test    Unable to find short assets via Search
    I rent the focused asset

Remaining rental time for current rented asset ends
    [Documentation]    This keyword waits until the remaining rental
    ...    duration saved in the ${EXPIRY_DURATION} variable expires.
    variable should exist    ${EXPIRY_DURATION}    Variable EXPIRY_DURATION is not set for the focused asset
    I wait for ${EXPIRY_DURATION + 10} seconds

The asset is removed from the Rented list
    [Documentation]    This keyword verifies that no assets are available in the rented list by navigating
    ...    to Rented in Saved and verifying the list is empty in the UI.
    ...    In future, extend this to verify that ${TILE_TITLE} is not present.
    I open Rented through Saved
    wait until keyword succeeds    10s    200ms    I expect page contains 'textKey:DIC_RENTED_EMPTY_TITLE'

Entitled VOD asset for partial watched status is available
    [Documentation]    This keyword verifies that non adult entitled VOD asset are available
    ...    to verify partial watched status, saving the assets' CRID in the ${REAL_CONTENT_ASSETS} variable,
    ...    and the focused asset in the ${TILE_TITLE} variable.
    I make sure budget limit is set to    ${BUDGET_HIGH}
    I open On Demand through Main Menu
    ${current_country_code}    Read current country code
    ${current_country_code_uppercase}    convert to uppercase    ${current_country_code}
    ${length}    Get Length    ${REAL_CONTENT_ASSETS}
    I open rental category in vod
    I press    DOWN
    I navigate to all genres vod screen
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    : FOR    ${index}    IN RANGE    ${0}    ${length}
    \    ${crid}    set variable    ${REAL_CONTENT_ASSETS[${index}]}
    \    ${item}    get asset by crid    ${LAB_CONF}    ${LAB_CONF}    ${crid}    ${current_country_code_uppercase}    ${OSD_LANGUAGE}    ${cpe_profile_id}
    \    ...    ${CUSTOMER_ID}    ${CPE_ID}
    \    ${asset_is_focused}    run keyword and return status    I focus '${item['title']}' tile
    \    set test variable    ${TILE_TITLE}    ${item['title']}
    \    run keyword if    ${asset_is_focused}    run keywords    I open VOD Detail Page
    \    ...    AND    exit for loop

Entitled VOD asset is partially watched
    [Documentation]    This keyword ensures that the entitled VOD asset saved in the ${TILE_TITLE} variable
    ...    is partially watched.
    ...    Precondition: A VOD Details Page screen should be open.
    Variable should exist    ${TILE_TITLE}    The title of a VOD asset tile has not been saved. TILE_TITLE does not exist.
    ${json_object}    get ui json
    ${hours_duration_present}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_GENERIC_DURATION_HRS_MIN
    ${mins_duration_present}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_GENERIC_DURATION_MIN
    should be true    ${hours_duration_present} or ${mins_duration_present}    Duration is not defined in details page for asset: ${TILE_TITLE}
    ${duration_textkey}    set variable if    ${hours_duration_present}    DIC_GENERIC_DURATION_HRS_MIN    DIC_GENERIC_DURATION_MIN
    ${duration_str}    Extract Value For Key    ${json_object}    textKey:${duration_textkey}    textValue
    @{duration_split}    Split String    ${duration_str}    separator=<
    ${duration_str}    set variable    @{duration_split}[0]
    ${timedelta}    Convert Time    ${duration_str}    timedelta
    ${minimum_view_time}    evaluate    ${timedelta.total_seconds()}/10
    should be true    ${minimum_view_time}<=${900}    Asset 10% duration exceeds 15 mins
    ${is_watch_present}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_ACTIONS_WATCH
    ${is_play_from_start_present}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_ACTIONS_PLAY_FROM_START
    ${focus_option}    set variable if    ${is_watch_present}    DIC_ACTIONS_WATCH    ${is_play_from_start_present}    DIC_ACTIONS_PLAY_FROM_START    ${EMPTY}
    Move Focus to Section    ${focus_option}    textKey
    I press    OK
    Purchase flow continues
    I press    OK
    wait until keyword succeeds    20s    1s    Player is in PLAY mode
    make sure Playout continues for the duration    ${minimum_view_time}s
    I prevent vod player progress bar from disappearing
    ${CONTINUE_WATCHING_PROGRESS_TIME}    ${_}    Get viewing progress indicator data
    I press    STOP
    Set Test Variable    ${CONTINUE_WATCHING_PROGRESS_TIME}
    'WATCH' or 'PLAY FROM START' actions are shown

I see continue watching tile in On Demand Discover screen
    [Documentation]    This keyword opens the On demand Discover screen,
    ...    and verifies 'Continue Watching' section is shown.
    I open On Demand through Main Menu
    I see 'Continue Watching' listed in Discover section of Ondemand screen

Partially watched asset is shown
    [Documentation]    This keyword verifies that the partially watched asset saved in the ${CONTINUE_WATCHING_JSON}
    ...    variable is shown in the On Demand screen.
    Variable should exist    ${CONTINUE_WATCHING_JSON}    Continue Watching collection was not saved. CONTINUE_WATCHING_JSON does not exist.
    ${tiles_browser}    Extract Value For Key    ${CONTINUE_WATCHING_JSON}    id:CollectionContainer_BasicCollection_ContinueWatching_\\d+    children    ${True}
    ${tiles_count}    Get Length    ${tiles_browser}
    should not be true    ${tiles_count}==0    Zero entries in Continue watching section

Partially watched VOD series asset is available
    [Documentation]    This keyword rents the first episode of a series VOD asset title, partially plays it by
    ...    fast forwarding, and then stops playing it going back to the Details Page.
    I open On Demand through Main Menu
    I focus full-length series asset via 'Series' all genres
    I press    OK
    I rent the multioffer asset
    'About to start' screen is shown
    I wait for 10 seconds
    I long Press FFWD for 2 seconds
    Player is in PLAY mode
    I press    STOP
    Linear Details Page is shown

I rent the selected asset    #USED
    [Documentation]    This keyword rents an asset from the currently opened Details Page,
    ...    selecting any of the rent options available.
    ...    Precondition: A VOD Details Page screen should be open.
    I focus any rent option
    I press    OK
    ${status}    run keyword and return status    'Rent' interactive modal is shown
    run keyword if    ${status}    I press    OK
    Pin Entry popup is shown
    I enter a valid pin ensuring the rental process succeeds
    sleep  5
    Error popup is not shown
    #wait until keyword succeeds    20s    1s    Player is in PLAY mode

Adult On Demand Area is shown for language
    [Arguments]    ${language}
    [Documentation]    Asserts on demand screen is shown
    run keyword if    '${language}' == 'NL'    On Demand is shown
    ...    ELSE    VOD Grid Screen is shown

Collection tiles are shown
    [Documentation]    This keyword verifies the current VOD screen contains collection tiles
    wait until keyword succeeds    10times    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:^.*CollectionsBrowser_collection_\\\\d+' using regular expressions

Back Office is unavailable
    [Documentation]    This keyword simulates the back office is unavailable by login into the STB via SSH and setting up
    ...    iptables rules to block the traffic.
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}    ${username}    ${password}
    Remote.execute command    ${STB_IP}    ${ssh_handle}    /usr/sbin/iptables -I INPUT 1 -s localhost -d localhost -p tcp --dport 81 -j DROP
    Remote.close connection    ${STB_IP}    ${ssh_handle}

I open On Demand through Main Menu expecting to fail
    [Documentation]    This keyword opens the On Demand screen via the Main Menu, but expects it to not load because
    ...    the Back Office is not available
    I open Main Menu
    run keyword and expect error    *    I open On Demand

Error screen '${error_code}' is shown    #USED
    [Documentation]    This keyword verifies the modal popup containing the error '${error_code}' is shown
    ...    in the current screen.
    ${wait_time}    Set Variable If    '${error_code}' == 'CS2004'    20ms    1s
    Wait Until Keyword Succeeds    15 times    ${wait_time}    I expect page contains 'id:Widget.ModalPopup'
    @{regexp_matches}    get regexp matches    ${error_code}    CS(\\d{4})    1
    should not be empty    ${regexp_matches}    Error code '${error_code}' is not correctly formatted
    ${is_correct_error}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    id:infoScreenErrorCode    textKey:DIC_ERROR_${regexp_matches[0]}_CODE
    Should be true    ${is_correct_error}    Error '${error_code}' is not being shown

Asset starts playing from where it stopped
    [Documentation]    This keyword verifies the currently playing asset starts at the time where it was stopped, stored
    ...    in the ${CONTINUE_WATCHING_PROGRESS_TIME} variable.
    ...    Precondition: The ${CONTINUE_WATCHING_PROGRESS_TIME} variable must have been set before.
    Variable should exist    ${CONTINUE_WATCHING_PROGRESS_TIME}    No progress time saved for the asset playing
    'About to start' screen is shown
    wait until keyword succeeds    6times    0s    Player is in PLAY mode
    ${progress_time}    ${_}    Get viewing progress indicator data
    ${CONTINUE_WATCHING_PROGRESS_TIME}    robot.libraries.DateTime.Convert Time    ${CONTINUE_WATCHING_PROGRESS_TIME}
    ${progress_time}    robot.libraries.DateTime.Convert Time    ${progress_time}
    ${time_difference}    Evaluate    abs(${CONTINUE_WATCHING_PROGRESS_TIME} - ${progress_time})
    Should Be True    ${time_difference} < ${CONTINUE_WATCHING_TOLERANCE_VALUE_SECONDS}    'Continue Watching' asset didn't start playing where it was stopped

I select the 'Continue watching' action
    [Documentation]    This keyword focuses the 'Continue Watching' action and selects it.
    I focus the 'Continue watching' action
    I Press    OK

Partially watched VOD movie asset is available
    [Documentation]    This keyword opens the 'Automation' section in On Demand, focuses an entitled VOD movie asset in
    ...    that section and starts playing it, making sure the asset is played for at least 10% of it's runtime. After
    ...    that it stops the player, going back to the Details Page.
    ...    Precondition: The customer must have the correct products from the ${AUTOMATION_NEEDED_PRODUCTS} variable
    ...    entitled for the 'Automation' section to appear.
    I focus a VOD tile in section    Automation    60    240
    I open VOD Detail Page
    Entitled VOD asset is partially watched

Bookmark state of the asset is displayed correctly
    [Arguments]    ${title}=${TILE_TITLE}
    [Documentation]    This keyword verifies that the asset with title ${title} is present in the current screen
    ...    and the tile contains a progress indicator below showing where the asset was stopped last time it was played.
    ...    Precondition: A screen with asset tiles must be already opened (i.e. VOD or Replay in Saved section),
    should not be empty    ${title}    The title of the partially watched asset was not saved.
    Move Focus to Collection with Tile    ${title}    title
    Move Focus to Tile    ${title}    title
    ${tile_id}    Extract Value For Key    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${TILE_NODE_ID_PATTERN}    id    ${True}
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:.*${tile_id}_watchIndicator_progressbar' contains 'id:progressBar' using regular expressions

I open a grid screen with at least '${num}' items
    [Documentation]    This keyword opens the 'All series' grid screen of the 'Series' VOD section in
    ...    On Demand, verifies the VOD grid screen is shown and if the grid page has at least '${num}' items.
    I open a grid screen
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:gridNavigation_gridCounter' contains 'textValue:^.+$' using regular expressions
    ${counter}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:gridNavigation_gridCounter    textValue
    ${total_tiles}    Fetch From Right    ${counter}    /
    Should Be True    ${total_tiles} >= ${num}    The page has less items than expected.

BACK TO TOP is focused
    [Documentation]    This keyword verifies if BACK TO TOP button is focused.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    BACK TO TOP is focused implementation

VOD asset with SD HD video format is focused
    [Documentation]    This keyword focuses the asset with SD and HD video format from 'Automation' section
    I open the 'Automation' section in On Demand
    Move to element assert focused elements using regular expression    id:shared-CollectionsBrowser_collection_\\\\d+_gridEntryTile    8    DOWN
    I press    OK
    Grid Page is opened
    Move Focus to Tile in Grid Page    ${VOD_HD_SD_ASSET}    title
    Tile is Focused    ${VOD_HD_SD_ASSET}    title

Video format is
    [Arguments]    ${format}
    [Documentation]    This keyword verifies if the current playing asset video format is of format ${format}
    ...    Precondition: Video asset should be playing
    ${format}    Convert To uppercase    ${format}
    ${current_asset_resolution}    Get source resolution
    ${current_asset_format}    Set Variable If    '1080' in '${current_asset_resolution}'    HD    '720' in '${current_asset_resolution}'    SD    '2160' in '${current_asset_resolution}'
    ...    4K    UNKNOWN
    should be equal    ${format}    ${current_asset_format}    Current playing asset format is '${current_asset_format}' not '${format}'

VOD asset playback is initiated
    [Documentation]    This keyword makes sure that VOD asset playback is initiated
    'About to start' screen is shown
    wait until keyword succeeds    5 times    1 s    I do not expect page contains 'id:ContentLoading.View'
    Player is in PLAY mode

I open a series tile from On Demand
    [Documentation]    This keyword opens the 'Automation' VOD section from On Demand, focuses a VOD series tile and opens it,
    ...    saving the title of the asset in the ${TILE_TITLE} variable.
    ...    Precondition: On Demand screen should be open.
    I open 'Automation'
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    @{series_list}    Get Content    ${LAB_CONF}    Automation    SERIES    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}
    ...    ${CUSTOMER_ID}    count=all
    : FOR    ${series_item}    IN    @{series_list}
    \    ${is_title_in_series_item}    evaluate    True if 'title' in ${series_item} else False
    \    &{series_item}    Set Variable if    ${is_title_in_series_item}==${True}    ${series_item}
    \    exit for loop if    ${is_title_in_series_item}
    set test variable    ${TILE_TITLE}    &{series_item}[title]
    I press    DOWN
    I focus '${TILE_TITLE}' tile
    I open VOD Detail Page

I watch last episode in last season
    [Documentation]    This keyword navigates to last episode in last season and then watches it to the end.
    ...    Precondition: Episode picker screen should be open.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    2s    I expect focused elements contains 'id:EzyListepisodeList'
    Move focus to last episode in last season
    I press    OK
    Wait Until Keyword Succeeds    5 times    1s    Wait for Details page elements
    ${episode_duration}    Get VOD duration
    I rent the focused asset
    Make sure playout continues for the duration    ${episode_duration}min
    The VOD playout has finished

I open same series through On Demand
    [Documentation]    This keyword goes back to the On Demand screen and then opens the tile with name ${TILE_TITLE}.
    ...    Precondition: ${TILE_TITLE} variable must exist in this scope and detail page screen should be open.
    variable should exist    ${TILE_TITLE}    Title ${TILE_TITLE} of VOD series was not saved.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'id:detailPageList'
    I Press    BACK
    On Demand is shown
    I focus '${TILE_TITLE}' tile
    I open VOD Detail Page

First episode in first season is the most relevant
    [Documentation]    This keyword checks if the first episode in first season is the most relevant episode shown.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textValue:^.+1, .+1.+$' using regular expressions

I Navigate to unentitled TVOD asset    #USED
    [Documentation]    This keyword attempts to navigate to a single TVOD asset from the VOD section
    Navigate to unentitled TVOD asset

I Navigate To VOD Asset With Trailer    #USED
    [Documentation]    This keyword attempts to navigate to a single VOD asset with trailer from the VOD section
    Navigate To VOD Asset With Trailer

I Navigate To Age Rated Vod Asset With Tvod '${only_tvod}'    #USED
    [Documentation]    This keyword searches an age rated single VOD asset as per the requirement of ${only_tvod} inside On demand
    ...    eg. if ${only_tvod} is True then this keyword will return the Age rated Tvod(un-rented) asset
    ...    else then this keyword will return the Age rated asset that can be SVOD or asset which is already been purchased
    Navigate To Age Rated Vod Asset    ${only_tvod}

'WATCH AGAIN' Action Is Shown    #USED
    [Documentation]    This keyword verifies if 'Watch Again' option is shown on Details Page.
    wait until keyword succeeds    5s    0    I expect page contains 'textKey:(DIC_ACTIONS_WATCH_AGAIN)' using regular expressions

I Validate The First Genre Tile In On Demand Section    #USED
    [Documentation]    This keyword selects and validates genre tile from any on demand section and verifies filter results in All Genres Page
    Retrieve VOD Root Category Structure From Backend
    :FOR    ${section_name}    IN    @{VOD_SECTIONS_DICTIONARY.keys()}
    \    Log    ${section_name}
    \    Continue For Loop If  '''${section_name}''' == '''x'''
    \    Continue For Loop If  '''${section_name}''' == '''series'''
    \    ${provider_name}    Get Tenant Specific Name For Providers Section    ${False}
    \    ${provider_name}    Run Keyword If    '''${provider_name}'''!='''${None}'''    Convert To Lowercase    ${provider_name}
    \    Run Keyword If    '''${provider_name}'''!='''${None}'''    Continue For Loop If    '''${section_name}'''=='''${provider_name}'''
    \    I open '${section_name}'
    \    ${genre_tile_found}    Run Keyword And Return Status    Validate The First Genre Tile In On Demand Section
    \    Exit For Loop If    ${genre_tile_found}
    \    I Press    MENU
    Should Be True    ${genre_tile_found}    Genre Tiles Not Found In Any Of On Demand Sections

I Validate Filter Results For Selected Genre Tile    #USED
    [Documentation]    This keyword validates filter results for selected genre in All Genres Page
    Validate Genre Filter For The Selected Genre

I Select A Genre Randomly From Genre Picker    #USED
    [Documentation]    This keyword selects a genre randomly from genre picker
    Select A Genre Randomly From Genre Picker

I Validate Filter Results For Selected Genre From The Genre Picker    #USED
    [Documentation]    This keywords validates the filter results for a randomly selected genre from the genre picker
    Validate Genre Filter For The Selected Genre

I Select A Sort Option Randomly From All Genres Page    #USED
    [Documentation]    This keyword selects a sort option randomly from All Genres page
    Select A Sort Option Randomly From All Genres Page

I Validate Sort Results For The Selected Sort Option    #USED
    [Documentation]    This keyword validates sort results for the selected sort option
    Validate Sort Results For The Selected Sort Option

I Play Already Purchased VOD Asset And Verify Playback    #USED
    [Documentation]    This keyword plays an already purchased VOD and verifies playback. Pin entry popup is handled for age restricted VOD
    ...    and Continue Watching Popup is handled to play from start. Precondition: VOD Details page is opened
    Play Already Purchased VOD Asset And Verify Playback

I Play Already Purchased VOD Asset Which Is Not Watched And Verify Playback    #USED
    [Documentation]    This keyword plays an already purchased VOD that has not been watched and verifies playback. Pin entry popup is handled for age restricted VOD
    ...    and Continue Watching Popup is handled to play from start. Precondition: VOD Details page is opened
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'textKey:DIC_ACTIONS_PLAY_FROM_START'
    Play Already Purchased VOD Asset And Verify Playback

I Play Completely Watched Already Purchased VOD Asset And Verify Playback    #USED
    [Documentation]    This keyword plays a completely watched already purchased VOD and verifies playback. Pin entry popup is handled for age restricted VOD
    ...    and Continue Watching Popup is handled to play from start. Precondition: VOD Details page is opened
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'textKey:DIC_ACTIONS_WATCH_AGAIN'
    Play Already Purchased VOD Asset And Verify Playback

I Set Profile Bookmarks For A VOD Asset With Crid Id '${crid}' And Percentage '${percentage}'    #USED
    [Documentation]    This keyword sets bookmark based on profile id for VOD Asset whose crid id is saved in LAST_FETCHED_VOD_ASSET
    ...   or provided explicitly by calculating bookmark_position based on asset duration.
    Set Profile Bookmarks For A VOD Asset With Given Percentage    ${percentage}    ${crid}

I Play Partially Watched Already Purchased VOD Asset And Verify Playback    #USED
    [Documentation]    This keyword plays a partially watched already purchased VOD and verifies playback. Pin entry popup is handled for age restricted VOD
    ...    and Continue Watching Popup is handled to play from start. Precondition: VOD Details page is opened
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'textKey:DIC_ACTIONS_WATCH'
    Play Already Purchased VOD Asset And Verify Playback

I Continue Watching Selected VOD Asset And Get Progress Bar Indicator Data    #USED
    [Documentation]    This keyword ensures that selected VOD  asset is partially watched. If its a TVOD asset, it is rented.
    ...    Rental and age restricted pin entry popup are handled. 'Continue Watching' is selected when prompted. Plays out the video for 30 seconds.
    ...    Time where playout is stopped is saved. Precondition: VOD details page is opened.
    Continue Watching Selected VOD Asset And Get Progress Bar Indicator Data

I Validate Purchase Of TVOD Asset With Crid '${tvod_asset_crid}'    #USED
    [Documentation]    This keyword validates the purchase of last purchased TVOD Asset whose crid id is given.
    I retrieve rentals from purchase service
    List Should Contain Value    ${RENTED_ASSETS}    ${tvod_asset_crid}    Could not validate purchase of the TVOD asset with given crid id

I Verify Provider Tiles In Providers Section    #USED
    [Documentation]    This keyword navigates to every provider tile in providers section and checks whether
    ...    appropriate second level screen is opened with no error popup. Precondition: Providers section is open
    Verify Provider Tiles In Providers Section

I Verify VOD Catalogue    #USED
    [Documentation]    This keyword checks that vod section details obtained from backend is relevant by
    ...    ensuring that those sections are displayed in UI without any errors and assets are displayed
    ...    inside the section
    Verify VOD Catalogue

I Navigate To A Random Asset In Second Level Screen Of Providers Section    #USED
    [Documentation]    This keyword navigates to any random asset in second level screen of providers section
    ...    based on information of vod sections from the backend saved in VOD_SECTION_DETAILS_DICTIONARY
    ...    Precondition: on Demand is opened
    Variable Should Exist    ${VOD_SECTION_DETAILS_DICTIONARY}    vod section details not saved in VOD_SECTION_DETAILS_DICTIONARY
    Navigate To A Random Asset In Second Level Screen Of Providers Section    ${VOD_SECTION_DETAILS_DICTIONARY}

I Navigate To VOD Assets In Rent Section Having Multiple Instances    #USED
    [Documentation]    This keyword fetches title and instances of a VOD Asset with multiple instances
    ...    Precondition: Ondemand Section Is Open.
    Get Root Id From Purchase Service
    Navigate to unentitled TVOD asset    True

I Rent A VOD Instance Of An Asset With Multiple Instances    #USED
    [Documentation]    This keyword rents a VOD Instance of a specific VOD Asset
    ...    Precondition: VOD details page is opened.
    Variable Should Exist    ${VOD_INSTANCES}    Instance list of VOD Asset not saved.
    Rent A Specific VOD Instance Of An Asset    ${VOD_INSTANCES}

I Extract Recently Added Section Of On Demand CMM From Backend    #USED
    [Documentation]    This keyword fetches data of recently added section of on demand CMM from backend
    Extract Recently Added Section Of On Demand CMM From Backend

I Extract Recommended For You Section Of On Demand CMM From Backend    #USED
    [Documentation]    This keyword fetches data of recommended for you section of on demand CMM from backend
    Extract Recommended For You Section Of On Demand CMM From Backend

I Navigate To A Random Episode Of A VOD Series Asset    #USED
    [Documentation]    This keyword fetches season details of a series VOD asset from backend and navigates to a
    ...    random episode in a random season for the series
    ${section_name}    ${series_list}    Get VOD Series Assets Belonging To A Section From Backend
    ${selected_series}    Get Random Element From Array    ${series_list}
    ${nav_dict}    Get Random Episode From VOD Series Details    ${selected_series}
    Log    ${nav_dict}
    Navigate To Given VOD Series Asset And Focus Given Episode    ${section_name}    ${nav_dict['seriesTitle']}    ${nav_dict['seasonNumber']}
    ...    ${nav_dict['seasonsInSeries']}     ${nav_dict['episodePickerTitle']}    ${nav_dict['seriesTitle']}
    ...    ${nav_dict['episodesInSeason']}

I focus CatchUP    #USED
    [Documentation]    This keyword focuses the 'On Demand' element in the Main Menu.
    Move Focus to Section    DIC_MAIN_MENU_TV_REPLAY    textKey

#*********************************************** CPE PERFORMANCE ******************************************************

Catchup Catalog for ${channel} is shown    #USED
    [Documentation]    This keyword verifies that the CatchUP screen is shown for given channel.
    ${json_object}    Get Ui Json
    ${rcs_view}    Is In Json    ${json_object}    ${EMPTY}    id:CatchupCatalog.View|ReplayCatalog.View    ${EMPTY}    ${True}
    ${channel_catalog_status}    Is In Json    ${json_object}    id:gridNavigation_filterButton_1    textValue:${channel}
    ${tiles_status}    Is In Json    ${json_object}    ${EMPTY}    id:^.*CollectionsBrowser_collection_[\\w]+
    ...     ${EMPTY}    ${True}
    Should Be True    ${rcs_view}    Replay Catalog Screen is not shown
    #Should be true    ${channel_catalog_status}    Replay Catalog for ${channel} is not Shown
    Should be true    ${tiles_status}    Tiles are not loaded for replay catalog

CatchUP is shown    #USED
    [Documentation]    This keyword verifies that the CatchUP screen is shown.
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    I expect page contains 'id:CatchupCatalog.View|ReplayCatalog.View' using regular expressions
    #wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    I expect focused elements contains 'id:shared-CollectionsBrowser_collection_*' using regular expressions

I open CatchUP through Main Menu    #USED
    [Documentation]    This keyword opens the On Demand screen via the Main Menu.
    I open Main Menu
    I open CatchUP

I open CatchUP    #USED
    [Documentation]    This keyword opens the On Demand screen.
    ...    Precondition: Main Menu should be open.
    I focus CatchUP
    I Press    OK
    CatchUP is shown
