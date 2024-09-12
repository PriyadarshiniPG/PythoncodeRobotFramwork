*** Settings ***
Documentation     Apps Keywords
Resource          ../Common/Stbinterface.robot
Resource          ../Common/Common.robot
Resource          ../PA-04_User_Interface/MainMenu_Keywords.robot
Resource          ../PA-26_Applications/Apps_Implementation.robot

*** Variables ***
${FOR_YOU_LIST_ITEM_ID}    ForYou
${ALL_APPS_LIST_ITEM_ID}    All Apps
${APPS_STORE_LIST_ITEM_ID}    AppStore
${COUNTRIES_LIST_ITEM_ID}    Countries
${EDITORIAL_COLLECTION}    id:CollectionContainer_TileCollection_4
${IS_GRID_COLLECTION}    ${False}
${FOCUSED_GRID_TILE_COUNT}    ${0}
${MAX_TILES_COUNT}    ${20}
${MAX_COLLECTIONS_COUNT}    ${10}
${EMPTY_JSON_ANCESTOR_RETRY_COUNT}    ${20}
${URL_REGEX}      ^'https?://[^/]+\\.\\w+(/.*)?'
${USER_AGENT_REGEX}    ^'Mozilla/5\.0 \\((\\w+; )*Linux \\w+\\).*Gecko.*'
${BBC_TRIGGER_APP_URL}    http://hbbtv-exploration.s3-website-eu-west-1.amazonaws.com/
${METROLOGICAL_BOOT_URL}    https://widgets.metrological.com/liberty/nl/omw-development#boot!\\\\w{2}-\\\\w{2}
${ALL_COUNTRIES_TITLE}    MVP All Countries

*** Keywords ***
I open Apps     #USED
    [Documentation]    Opens apps screen
    I focus Apps
    I Press    OK
    Apps is shown

I focus Apps        #USED
    [Documentation]    Focus the Apps section in the Main Menu
    Move to element assert focused elements    textKey:DIC_MAIN_MENU_APPS    7    RIGHT

I focus For You
    [Documentation]    This keyword iterates over the Apps section navigation in order to focus For You section
    Move Focus to Section    ${FOR_YOU_LIST_ITEM_ID}

Apps is shown       #USED
    [Documentation]    This keyword asserts apps screen is shown
    Wait Until Keyword Succeeds    10 times    2 sec    I expect page element 'id:mastheadPrimaryTitle' contains 'textKey:DIC_MAIN_MENU_APPS'

Apps is not shown
    [Documentation]    Asserts apps screen is not shown
    I do not expect page element 'id:mastheadScreenTitle' contains 'textKey:DIC_MAIN_MENU_APPS'

For You is focused
    [Documentation]    Checks if For You header is focused
    Section is Focused    ${FOR_YOU_LIST_ITEM_ID}

I focus the first app tile
    [Documentation]    This keyword focuses the first app tile in app section
    For You is focused
    app tiles are shown
    I press    DOWN
    ${app_tile_id}    Get focused App
    Set Suite Variable    ${first_app_by_going_down}    ${app_tile_id}

I focus the last app tile
    [Documentation]    This keyword focuses the last app tile in app section
    I focus the first app tile
    I press    LEFT
    ${app_tile_id}    Get focused App
    Set Suite Variable    ${last_app_by_going_left}    ${app_tile_id}

I focus Netflix channel through Channel Bar
    [Documentation]    This keyword focuses Netflix channel in Channel Bar
    I open Channel Bar
    Skip Error popup
    Move to element and assert    viewStateKey:selectedProgramme    viewStateValue    Netflix    10    UP

app tiles are shown
    [Documentation]    Asserts app tiles count is greater than 0
    ${tiles_per_collection}    Get app tiles count
    @{keys}    Get Dictionary Keys    ${tiles_per_collection}
    ${tiles_are_shown}    Set Variable    ${False}
    : FOR    ${key}    IN    @{keys}
    \    ${val}    Get From Dictionary    ${tiles_per_collection}    ${key}
    \    ${tiles_are_shown}    Evaluate    ${True} if ${val}>0 else ${False}
    \    Exit For Loop If    ${val} > 0
    Should Be True    ${tiles_are_shown}

I have only one collection on the For You screen
    [Documentation]    Asserts only one collection is visible
    ${visible}    Retrieve collections
    ${visible_count}    Get Length    ${visible}
    Should Be Equal As Integers    1    ${visible_count}

the first app tile is focused
    [Documentation]    This checks which app is focused and compares it's title with the first app title
    ${focused_app_tile_id}    Get focused App
    Should Be Equal As Strings    ${first_app_by_going_down}    ${focused_app_tile_id}

the last app tile is focused
    [Documentation]    This checks which app is focused and compares it's title with the last app title
    ${focused_app_tile_id}    Get focused App
    Should Be Equal As Strings    ${last_app_by_going_left}    ${focused_app_tile_id}

I open Apps under Countries
    [Documentation]    Opens all Apps under countries section in apps
    I open Countries
    Move Focus to Collection named    ${ALL_COUNTRIES_TITLE}
    I press    OK

I open Countries
    [Documentation]    Opens countries section in apps
    I focus Countries
    I press    OK

I Open '${app_name}' App       #USED
    [Documentation]    Opens the app in 'app_name'
    ...    'app_name' should contain the app's name as is in the UI
    ...    Precondition: the app collection and the app view Id should be mapped in 'Get {app_name} location' and 'Get {app_name} page id' keywords
    I open Apps through Main Menu
    I focus App Store
    I Select App    ${app_name}
    I wait for 1 minutes
    App Is Shown    ${app_name}

I have selected app
    [Arguments]    ${app_name}
    [Documentation]    This keyword focues and selects an app in App Store
    I Select App    ${app_name}    ${USE_DEEPLINKS}

I Select App      #USED
    [Arguments]    ${app_name}    ${via_deeplink}=${False}
    [Documentation]    Focus and select the specific app under App Store
    I have agreed with Apps Opt-In conditions
    Run keyword If    ${via_deeplink}    I launch the ${app_name} application through DeepLink
    ...    ELSE    Run Keywords    I focus App    ${app_name}
    ...    AND    I Press    OK
    Set Suite Variable    ${LAST_OPENED_APP}    ${app_name}

I focus App Store       #USED
    [Documentation]    Focuses the App Store tab in Apps section
    ${current_country_code}    Get Country Code From Stb
    ${current_country_code}     Convert To Uppercase    ${current_country_code}
    Run Keyword If    '${current_country_code}' == 'GB'     Move Focus to Section    ${ALL_APPS_LIST_ITEM_ID}
    ...    ELSE    Move Focus to Section    ${APPS_STORE_LIST_ITEM_ID}
    Wait Until Keyword Succeeds    10 times    300 ms    App store content has loaded

App Store is focused
    [Documentation]    Check if the App store is currently focused
    Section is Focused    ${APPS_STORE_LIST_ITEM_ID}

I focus Countries
    [Documentation]    Focuses the Countries tab in Apps section
    Move Focus to Section    ${COUNTRIES_LIST_ITEM_ID}

I focus App
    [Arguments]    ${app_name}
    [Documentation]    focuses the app '{app_name}'
    ...    Precondition: the app collection and the app view Id should be mapped
    ...    in 'Get {app_name} location' and 'Get {app_name} page id' keywords
    ${app_id}    Get app id    ${app_name}
    Move Focus to Collection with Tile    ${app_id}
    Move Focus to Tile    ${app_id}
    ${focused_app}    Get focused App
    Should be true    "${focused_app}" == "${app_name}"    ${app_name} App is not present in this section

app is launched    #USED
    [Arguments]    ${app_name}
    [Documentation]    Expect both a right runId and correct running state
    ${run_id}    Set Variable If    '${app_name}' == 'Netflix'    nfx    '${app_name}' == 'Prime Video'    ignition    browser
    ${status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    5 times    100 ms    I expect page contains 'textKey:DIC_OPTIN_APPS_MESSAGE'
    Run Keyword If    ${status}    I Press    OK
    Error Popup Is Not Shown
    Wait Until Keyword Succeeds And Verify Status    10 times    300ms    Run Id could not be validated    I expect page contains 'runId:${run_id}'
    ${running_state}    Get Enclosing Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    viewStateKey:state    ${1}
    ${is_running}    Is In Json    ${running_state}    ${EMPTY}    viewStateValue:RUNNING
    Should be True    ${is_running}    Running state should be 'RUNNING' but is not: ${running_state}

App Is Shown    #USED
    [Arguments]    ${app_name}    ${retries}=10 times    ${delay}=1 sec
    [Documentation]    Verifies if the app '{app_name}' is shown in a running state, with valid applied settings,
    ...    and without any other unexpected node.
    wait until keyword succeeds    ${retries}    ${delay}    app is launched    ${app_name}
    ${app_id}    Get app id    ${app_name}
    ${app_view}    Set Variable If    '${app_name}' in ['Netflix', 'Prime Video']    Native.View    WebApp.View
    wait until keyword succeeds    ${retries}    ${delay}    I expect page element 'viewStateKey:window' contains 'visible:true'
    ${app_view_state}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:${app_view}    viewState
    Should Not Be Equal    ${app_view_state}    None    Expected UI application page '${app_view}' is not shown with a viewState
    ${app_type}    Set Variable    ${app_view_state[0]['viewStateValue']}
    : FOR    ${element}    IN    @{app_view_state}
    \    ${key}    Set Variable    ${element['viewStateKey']}
    \    ${value}    Set Variable    ${element['viewStateValue']}
    \    Run Keyword If    '${key}' == 'id'    Should be True    '${value}' == '${app_id}'    Wrong application id: ${value}
    \    ...    ELSE IF    '${key}' == 'state'    Should be True    '${value}' == 'RUNNING'    State is '${value}' instead of 'RUNNING'
    \    ...    ELSE IF    '${key}' == 'window'    app window is shown    ${app_type}    ${value}
    \    ...    ELSE IF    '${key}' == 'url'    Should Match Regexp    '${value}'    ${URL_REGEX}
    \    ...    Wrong URL: ${value}
    \    ...    ELSE IF    '${key}' == 'userAgent'    Should Match Regexp    '${value}'    ${USER_AGENT_REGEX}
    \    ...    Wrong User-Agent: ${value}
    ${layers}    Set Variable    ${LAST_FETCHED_JSON_OBJECT.keys()}
    : FOR    ${layer}    IN    @{layers}
    \    Run Keyword If    '${layer}' != 'MAIN_LAYER'    Layer is empty    ${layer}    ${True}
    ${application_node_count}    Get Length    ${LAST_FETCHED_JSON_OBJECT['MAIN_LAYER']['children']}
    Should be true    ${application_node_count} == ${1}    Application should only contain the application view

app is shown within 2 seconds
    [Arguments]    ${app_name}
    [Documentation]    Verifies if the app '{app_name}' is shown in a running state within 2 seconds
    App Is Shown    ${app_name}    10 times    0.2 sec

app is left
    [Arguments]    ${app_name}    ${retries}=10 times    ${delay}=1 sec
    [Documentation]    This keyword left App if it's present
    ${app_view}    Set Variable If    '${app_name}' == 'Netflix'    Netflix.View    WebApp.View
    Wait Until Keyword Succeeds    ${retries}    ${delay}    I do not expect page contains 'id:${app_view}'

App Is Left Within 2 Seconds    #USED
    [Arguments]    ${app_name}
    [Documentation]    This keyword left App if it's present within 2 seconds
    app is left    ${app_name}    5 times    0.4s

I Open The Apps Store In Apps    #USED
    [Documentation]    Open Apps and move focus to the Apps Store
    I open Apps through Main menu
    I focus App Store

I have opened the Apps Store in Apps
    [Documentation]    Open Apps and move focus to the Apps Store
    Run keyword If    ${USE_DEEPLINKS} == ${False}    Run Keywords    I Open The Apps Store In Apps
    ...    AND    Return from keyword
    I open the Apps Menu through DeepLink
    I focus App Store

I navigate to Editorial collection
    [Documentation]    Move to the editorial collection in the app store page
    Move Focus to Editorial Collection

I focus the rightmost tile in the editorial collection
    [Documentation]    Focus to the rightmost tile in the editorial collection
    Get Current Collection Tiles
    Should be True    ${IS_EDITORIAL_TILE}    Current Collection is not an Editorial collection
    ${rightmost_tile_position}    Evaluate    (${LAST_EVALUATED_TOTAL_TILES_NUMBER} - ${1})
    Move Focus to Tile Position    ${rightmost_tile_position}

I focus the leftmost tile in the editorial collection
    [Documentation]    Focus to the leftmostmost tile in the editorial collection
    Get Current Collection Tiles
    Should be True    ${IS_EDITORIAL_TILE}    Current Collection is not an Editorial collection
    Move Focus to Tile Position    ${0}

I focus the tile to the right of the leftmost tile in the editorial collection
    [Documentation]    Put the focus on the tile to the right of the leftmost tile
    Move Focus to Tile Position    1

I focus the tile to the left of the rightmost tile in the editorial collection
    [Documentation]    Put the focus on the tile to the left of the rightmost tile
    Get Current Collection Tiles
    Move Focus to Tile Position    ${LAST_EVALUATED_TOTAL_TILES_NUMBER-2}

Focus is on the rightmost tile in the editorial collection
    [Documentation]    Assess the focus is on the rightmost tile in the collection
    Get Current Collection Tiles
    Should be True    ${IS_EDITORIAL_TILE}    Current Collection is not an Editorial collection
    ${tile_position}    Get Focused Tile Position
    ${expected_tile_position}    Evaluate    (${LAST_EVALUATED_TOTAL_TILES_NUMBER} - ${1})
    Should be Equal    ${tile_position}    ${expected_tile_position}    Focus is not on the expected tile

Focus is on the leftmost tile in the editorial collection
    [Documentation]    Assess the focus is on the leftmost tile in the collection
    Get Current Collection Tiles
    Should be True    ${IS_EDITORIAL_TILE}    Current Collection is not an Editorial collection
    ${tile_position}    Get Focused Tile Position
    Should be Equal    ${tile_position}    ${0}    Focus is not on the expected tile

Focus is on tile to the right of the leftmost tile in the editorial collection
    [Documentation]    Assess the focus is on the tile to the right of the leftmost tile in the collection
    Get Current Collection Tiles
    Should be True    ${IS_EDITORIAL_TILE}    Current Collection is not an Editorial collection
    ${tile_position}    Get Focused Tile Position
    Should be Equal    ${tile_position}    ${1}    Focus is not on the expected tile

Focus is on tile to the left of the rightmost tile in the editorial collection
    [Documentation]    Assess the focus is on the tile to the left of the rightmost tile in the collection
    Get Current Collection Tiles
    Should be True    ${IS_EDITORIAL_TILE}    Current Collection is not an Editorial collection
    ${tile_position}    Get Focused Tile Position
    ${expected_tile_position}    Evaluate    (${LAST_EVALUATED_TOTAL_TILES_NUMBER} - ${2})
    Should be Equal    ${tile_position}    ${expected_tile_position}    Focus is not on the expected tile

I have recently used apps    #USED
    [Documentation]    Keyword focus and open the specific app under App Store
    I Open The Apps Store In Apps
    I Select App    YouTube
    App Is Shown    YouTube
    I Press    CHANNELUP
    Channel Bar is present
    Set Suite Variable    ${LAST_OPENED_APP}    YouTube

Contextual main menu displays combination of recently used apps and recommended apps
    [Documentation]    Keyword verifies that recently used apps and most popular apps are displayed under contextual main menu
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_CONTEXTUAL_MAIN_MENU_RECENTLY_USED'
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_CONTEXTUAL_MAIN_MENU_FEATURED'

I open any not previously open app
    [Documentation]    open a new app which have not been opened before
    I Open The Apps Store In Apps
    I Select App    YouTube
    App Is Shown    YouTube

The last opened app is shown on the first position of Recently used apps        #USED
    [Documentation]    verifies that the last opened app is displayed as recently used in the first position under contextual main menu
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'title:DIC_CONTEXTUAL_MAIN_MENU_RECENTLY_USED'
    ${sub_sections}    Extract Value For Key    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${EMPTY}    data
    ${focused_app}    I retrieve json ancestor of level '1' for focused element 'id:contextualMainMenu-navigationContainer-APPS_element_.+' using regular expressions
    ${node_id}    Set Variable    ${focused_app['id']}
    @{words}    Split String    ${node_id}    _
    ${app_position}    Set Variable    @{words}[2]
    Should Be Equal    ${app_position}    0    First app tile is not focused in CTXTMM
    ${current_sub_section}    Set Variable    ${sub_sections[${app_position}]}
    Should Be Equal    ${current_sub_section['title']}    DIC_CONTEXTUAL_MAIN_MENU_RECENTLY_USED    First focused app tile is not in recently used section
    ${app_data}    Extract Value For Key    ${focused_app}    ${EMPTY}    data
    ${last_app_id}    get app id    ${LAST_OPENED_APP}
    Should Be Equal    ${app_data['id']}    ${last_app_id}    Wrong app shown in first position: ${LAST_OPENED_APP}

I Play Any YouTube Video    #USED
    [Documentation]    Wait until the content of youtube to be ready and play any video
    I wait for 10 seconds
    I Press    OK
    # wait for video to start playing
    I wait for 5 seconds

TV channel is opened
    [Documentation]    Check if a tuned channel is still opened
    ...    used in combination with "linear tv is shown" which tune to FREE_CHANNEL_2
    Make sure that channel tuned to    ${FREE_CHANNEL_2}

I tune to a Netflix channel via numeric keys
    [Documentation]    Presses the Netflix channel number
    I tune to channel '${NETFLIX_CHANNEL}' using numeric keys

I tuned to Netflix channel
    [Documentation]    Verifies if the current Channel is a Netflix Channel
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:(NowAndNext|FullScreen).View' using regular expressions
    content unavailable

I tune to a Netflix channel via CHANNELUP
    [Documentation]    Verifies the ability to go to next channel via CHANNELUP press
    Skip Error popup
    And I Press    CHANNELUP

I tune to a Netflix channel via CHANNELDOWN
    [Documentation]    Verifies the ability to go to preceeding channel via CHANNELDOWN press
    Skip Error popup
    And I Press    CHANNELDOWN

I tune to BBC channel
    [Documentation]    Tune to a BBC channel
    I tune to channel    ${BBC_CHANNEL}

I exit app through
    [Arguments]    ${remote_key}
    [Documentation]    This keyword exits player if it's present
    ${json_object}    Get Ui Json
    ${is_youtube}    Is In Json    ${json_object}    ${EMPTY}    id:YoutubeView.View
    Run Keyword if    '${is_youtube}'== '${True}' and '${remote_key}'=='BACK'    I exit popup in youtube
    ...    ELSE    I press    ${remote_key}

I exit popup in youtube     #USED
    [Documentation]    This keyword exit youtube by selecting the EXIT option from the popup window
    I press BACK 3 times
    I press    RIGHT
    I press    OK

I wait '${seconds}' seconds, close '${app_name}' with '${remote_key}', relaunching it via Contextual Menu '${retries}' times
    [Documentation]    This kayword verify the ability to launch YouTube Several Times
    ${status}    run keyword and return status    App Is Shown    YouTube
    run keyword if    ${status}    repeat keyword    ${retries} times    I wait '${seconds}' seconds, close '${app_name}' with '${remote_key}', re-launch it via Contextual Menu

I wait '${seconds}' seconds, close '${app_name}' with '${remote_key}', re-launch it via Contextual Menu
    [Documentation]    this keyword open and close App via Contextual Menu
    I wait for ${seconds} seconds
    I exit app through    ${remote_key}
    I Launch App via Contextual Menu

I Launch App via Contextual Menu
    [Documentation]    This keyword launches App through contextual menu
    I open contextual main menu
    I focus Apps
    I Press    DOWN
    The last opened app is shown on the first position of Recently used apps
    I press    OK
    App Is Shown    YouTube

Application '${application_name}' is presented in the current Apps Page section With ${app_id}   #USED
    [Documentation]    This Keyword verifies that the Stingray app is displayed
    ...    by moving the focus to the app tile
    Move Focus to Collection with Tile    ${app_id}
    Move Focus to Tile    ${app_id}

'BBC Trigger App' is started
    [Documentation]    This keyword verifies that BBC Trigger App is started by using Ui Browser Processes
    ${json_object}    Get Ui Browser Processes
    ${app_url}    run keyword and return status    wait until keyword succeeds    5 times    1 s    I expect UI browser processes json contains 'url:${BBC_TRIGGER_APP_URL}'
    ${app_is_running}    Is In Json    ${LAST_FETCHED_PROCESS_JSON}    ${EMPTY}    state:RUNNING
    ${app_is_visible}    Is In Json    ${LAST_FETCHED_PROCESS_JSON}    ${EMPTY}    visible:true
    ${app_opacity_is_0}    Is In Json    ${LAST_FETCHED_PROCESS_JSON}    ${EMPTY}    opacity:0
    Should Be True    ${app_url} and ${app_is_running} and ${app_is_visible} and (${app_opacity_is_0} == ${False})    BBC Trigger App url is not found

'BBC Trigger App' is stopped
    [Documentation]    This keyword verifies that BBC Trigger App is stopped by using Ui Browser Processes
    ${json_object}    Get Ui Browser Processes
    ${app_boot_url}    run keyword and return status    wait until keyword succeeds    5 times    1 s    I expect UI browser processes json contains 'url:${METROLOGICAL_BOOT_URL}' using regular expressions
    ${app_is_not_visible}    Is In Json    ${LAST_FETCHED_PROCESS_JSON}    ${EMPTY}    visible:false
    ${app_opacity_is_0}    Is In Json    ${LAST_FETCHED_PROCESS_JSON}    ${EMPTY}    opacity:0
    Should Be True    ${app_boot_url} and (${app_is_not_visible} or ${app_opacity_is_0})    BBC Trigger App BOOT url is not found

Make sure application is closed
    [Documentation]    This keyword tries to exit any application using the most common ways to do so. It checks
    ...    the state of the app process to see if an application is in the foreground. If so, it tries to exit the
    ...    current application using known exit keys. If after all the attempts the app is still visible
    ...    the UI is restarted as a last resort.
    ${app_is_shown}    App process is in the foreground
    return from keyword if    not ${app_is_shown}
    @{exit_keys}    Create List    LIVETV    MENU    CHANNELUP    GUIDE
    : FOR    ${key}    IN    @{exit_keys}
    \    I exit app through    ${key}
    \    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Assert json changed    ${LAST_FETCHED_JSON_OBJECT}
    \    ${app_is_shown}    App process is in the foreground
    \    exit for loop if    not ${app_is_shown}
    run keyword if    ${app_is_shown}    Restart UI via command over SSH

App Exit Specific Teardown
    [Documentation]    This teardown closes any Application currently open and calls the Default Suite Teardown
    Make sure application is closed
    Default Suite Teardown

App store is shown
    [Documentation]    This keyword verifies that APP STORE is focused and contents are loaded
    App Store is focused
    App store content has loaded

Verify Netflix App Is Launched    #USED
    [Documentation]    This keyword verifies that Netflix App is launched
    App Is Launched    Netflix

Verify '${app_title}' App Is Launched    #USED
    [Documentation]    This keyword verifies that the specified App is launched
    App Is Launched    ${app_title}

I Expect '${app_name}' In Recently Used Apps In App Store   #USED
    [Documentation]     This keyword checks whether the app is present in Recently Used apps in App Store
    I open Apps through Main Menu
    I expect page element 'id:shared-CollectionsBrowser_collection_4_tile_0_primaryTitle' contains 'textValue:${app_name}'
    I expect page element 'id:shared-CollectionsBrowser_collection_4_title' contains 'textValue:Recently Used'

Exit The '${app_name}' App    #USED
    [Documentation]     This keyword exit the '${app_name}' by pressing MENU and validate app exit
    I Long Press MENU for 1 seconds
    App Is Left Within 2 Seconds    ${app_name}

Check Youtube Content Playback Via XAP      #USED
    [Documentation]    Keyword to make sure that video playback for any youtube content can be validated using XAP
    ...    and checks if video is RUNNING and url is a youtube url using XAP UI state.
    ...    with PRE-CONDITION: YouTube is already launched.
    I Play Any YouTube Video
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'viewStateValue:com.libertyglobal.app.youtube'
    ${video_url}    I retrieve value for key 'viewStateValue' in element 'viewStateKey:url' using regular expressions
    ${video_running}    I retrieve value for key 'viewStateValue' in element 'viewStateKey:state' using regular expressions
    should contain    ${video_url}    youtube
    should contain    ${video_running}    RUNNING
    #log to console  \n ${video_url} is ${video_running}
    I wait for 5 seconds

Get List Of Apps Present In App Store In CPE    #USED
    [Documentation]    Returns the list of Apps present in the CPE
    ${apps}    Get List Of Apps From App Service
    ${apps_in_appstore}    Extract Value For Key    ${apps}    id:(AppStore|All Apps)   collections    ${True}
    [Return]    ${apps_in_appstore}

Validate List Of Apps In Each Section Of App Store    #USED
    [Documentation]    validate the list of apps passed present in the current page
    [Arguments]     ${apps}
    :For    ${app}    IN    @{apps}
    \    ${is_present}    Run Keyword And Return Status    Application '${app['title']}' is presented in the current Apps Page section With ${app['id']}

Validate The List Of Apps Present In APP Store    #USED
    [Documentation]    Gets the collection of different sections of apps, validates each section of apps
    ...    present in the app store
    ${app_list}    Get List Of Apps Present In App Store In CPE
    :For    ${section}    IN    @{app_list}
    \    ${section_apps}    Extract Value For Key    ${section}    ${EMPTY}   applications
    \    Validate List Of Apps In Each Section Of App Store    ${section_apps}

Get List Of App Ids For A Section In App Store    #USED
    [Documentation]    Retreive the app ids for the apps present in a section in App store
    [Arguments]     ${apps}
    ${app_ids}    Create List
    :For    ${app}    IN    @{apps}
    \    ${app_id}    Extract Value For Key    ${app}    ${EMPTY}   id
    \    Append To List    ${app_ids}    ${app_id}
    [Return]    ${app_ids}

I Add 'num' Apps To Recently Used   #USED
    [Documentation]    Add '${num}' apps to contextual main menu as recently used
    ${app_ids}    Create List
    ${app_list}    Get List Of Apps Present In App Store In CPE
    :For    ${section}    IN    @{app_list}
    \    ${section_apps}    Extract Value For Key    ${section}    ${EMPTY}   applications
    \    ${app_ids}    Get List Of App Ids For A Section In App Store    ${section_apps}
    \    Exit For Loop If    ${app_ids}
    Should Not Be Empty    ${app_ids}    'No apps available to add as recently used apps'
    ${app_list}    Get Slice From List    ${app_ids}    0    ${num}
    ${list_length}    Get Length    ${app_list}
    Should Be True   ${list_length} == ${num}    'List doesn't have enough apps to add to recently used'
    ${app_list}    Evaluate    ",".join($app_list)
    Set Recently Used Apps    ${app_list}

Get Title Of A Random App Present In App Store From Backend    #USED
    [Documentation]    This keyword retrieves title of a random app present in app store of cpe from backend
    ${apps}    Get List Of Apps Present In App Store In CPE
    Should Not Be Empty    ${apps}    Could not fetch list of apps from backend
    ${section}    Get Random Element From Array    ${apps}
    ${application}    Get Random Element From Array    ${section['applications']}
    Set Suite Variable    ${LAST_FETCHED_APP_TITLE}    ${application['title']}


# ********************CPE PERFORMANCE TESTING*************

I check if TV APPS is opened
    [Documentation]    This keyword checks if TV APPS is opened and APPS are loaded.
    wait until keyword succeeds    10 times    0    TV APPS is shown

TV APPS is shown
    [Documentation]    This keyword checks if TV APPS is opened and APPS are loaded.
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    id:mastheadPrimaryTitle    textKey:DIC_MAIN_MENU_APPS
    Should Be True    ${result}    TV Apps is not opened
    ${collection_browser}    Extract Value For Key    ${json_object}    children    id:^.*CollectionsBrowser    ${True}
    Should Not Be Empty    ${collection_browser}    Apps section is empty
    ${apps_store_view}    Is In Json    ${json_object}    ${EMPTY}    id:AppStore.View
    Should Be True    ${apps_store_view}    Apps store view is not loaded

I focus TV APPS Section
    [Documentation]    This keyword focuses the TV APPS section and checks if content is loaded.
    [Arguments]  ${section_name}    ${key}=textValue    ${only_highlight_check}=False
    wait until keyword succeeds    10 times    0    TV APPS Screen for given section is shown    ${section_name}    ${key}    ${only_highlight_check}

TV APPS Screen for given section is shown
    [Documentation]    This keyword focuses the TV APPS section and checks if content is loaded.
    [Arguments]  ${section_name}    ${key}=textValue    ${only_highlight_check}=False
    ${json_object}    Get Ui Json
    ${elem}    set variable    ${key}:${section_name}
    ${elem_is_focused}    set variable    ${False}
    ${elem_is_focused}    run keyword and return status    i expect focused elements contains '${elem}'
    return from keyword if    ${only_highlight_check} == True
    ${collection_browser}    Extract Value For Key    ${json_object}    children    id:^.*CollectionsBrowser    ${True}
    Should Not Be Empty    ${collection_browser}    Apps section is empty

I check '${app_name}' App is loaded
    [Documentation]    This keyword checks if app is launched and content is loaded
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    APP is launched and loaded    ${app_name}

APP is launched and loaded
    [Documentation]    This keyword checks if app is launched and content is loaded
    [Arguments]  ${app_name}
    ${json_object}    Get Ui Json

    #Check if APP run ID is avaliable
    ${run_id}    Set Variable If    '${app_name}' == 'Netflix'    nfx    '${app_name}' == 'Netflix 300'    nfx    '${app_name}' == 'Prime Video'    ignition    '${app_name}' == 'prime video'    ignition    browser|cobalt|thunderwpe
    ${result}    Is In Json    ${json_object}    ${EMPTY}    runId:${run_id}    ${EMPTY}    ${True}
    ${result}    Set Variable If    ('${COUNTRY}'=='nl' and '${app_name}' == 'YouTube')     ${True}    ${result}
    Should Be True    ${result}    APP run ID is not avaliable

    #Check if app running status is "RUNNING"
    ${running_state}    Get Enclosing Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    viewStateKey:state    ${1}
    ${is_running}    Is In Json    ${running_state}    ${EMPTY}    viewStateValue:STARTED
    Should be True    ${is_running}    Running state should be 'RUNNING' but is not: ${running_state}

    #Check if window is visible or not
    ${result}    Is In Json    ${json_object}    viewStateKey:window    visible:true
    Should Be True    ${result}    APP window is not visible

    #Check app splash screen is closed and app content is shown
    ${result}    Is In Json    ${json_object}    ${EMPTY}    image:.*Splash.*
    Should Not Be True    ${result}    APP Splash screen is not removed

I Select TV App
    [Arguments]    ${app_name}    ${via_deeplink}=${False}
    [Documentation]    Focus and select the specific app under App Store
    I have agreed with Apps Opt-In conditions
    Run keyword If    ${via_deeplink}    I launch the ${app_name} application through DeepLink
    ...    ELSE    Run Keywords    I get app id and focus App    ${app_name}
    ...    AND    I Press    OK
    Set Suite Variable    ${LAST_OPENED_APP}    ${app_name}

I get app id and focus App
    [Arguments]    ${app_name}
    [Documentation]    focuses the app '{app_name}'
    ...    Precondition: the app collection and the app view Id should be mapped
    ...    in 'Get {app_name} location' and 'Get {app_name} page id' keywords
    ${app_id}    Get app id for tv app    ${app_name}
    Move Focus to Collection with Tile    ${app_id}
    run keyword if    '${COUNTRY}' == 'nll'    I Press    RIGHT
#    Move Focus to Tile    ${app_id}
    : For    ${Index}    IN RANGE    1    50
     \    Get Ui Focused Elements
     \    ${current_tile_json}    Get From List    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${-1}
     \    ${tile_data}    Extract Value For Key    ${current_tile_json}    ${EMPTY}    data    ${True}
     \    ${current_tile_id}    Extract Value For Key    ${tile_data}    ${EMPTY}    id
     \    log to console     ${current_tile_id}
     \    exit for loop if    "${current_tile_id}" == "${app_id}"
     \    I Press    RIGHT
     \    I wait for 1 seconds
    ${focused_app}    Get focused App
    Should be true    "${focused_app}" == "${app_name}"    ${app_name} App is not present in this section

I focus App Store in TV APPS      #USED
    [Documentation]    Focuses the App Store tab in Apps section
    ${current_country_code}    get country code from stb
    ${COUNTRY}    convert to lowercase    ${current_country_code}
    ${app_store_id}    get app store id for country    ${COUNTRY}
    Move Focus to Section    ${app_store_id}
    Wait Until Keyword Succeeds    10 times    300 ms    App store content has loaded
    I press    OK

I focus App Store in TV APPS for app      #USED
    [Documentation]    Focuses the App Store tab in Apps section
    ${code}    set variable    ${COUNTRY}_${PRODUCT}
    ${app_store_id}    get app store id for country    ${code}
    run keyword if    not ('${COUNTRY}' == 'nl' or '${COUNTRY}' == 'pl' or '${COUNTRY}' == 'be' or '${COUNTRY}' == 'ch' or '${COUNTRY}' == 'ie')
    \     ...   Move Focus to Section for app    ${app_store_id}    textValue
    run keyword if   not ('${COUNTRY}' == 'nl' or '${COUNTRY}' == 'pl' or '${COUNTRY}' == 'be' or '${COUNTRY}' == 'ch' or '${COUNTRY}' == 'ie')
    \     ...   Wait Until Keyword Succeeds    10 times    300 ms    App store content has loaded
    run keyword if   not ('${COUNTRY}' == 'nl' or '${COUNTRY}' == 'pl' or '${COUNTRY}' == 'be' or '${COUNTRY}' == 'ch' or '${COUNTRY}' == 'ie')
    \     ...   I press    OK

Get TV APPS Section Json
    [Documentation]    This keyword return json for the TV APPS sections
    @{cleaned_sections}    create list
    ${rotate}    Set Variable        ${-1}
    I wait for 2 seconds
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
