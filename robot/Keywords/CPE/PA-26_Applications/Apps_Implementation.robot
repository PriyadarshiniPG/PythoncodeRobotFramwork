*** Settings ***
Documentation     Apps Implementation keywords
Resource          ../CommonPages/CollectionBrowser_Keywords.robot
Resource          ../PA-04_User_Interface/MainMenu_Keywords.robot

*** Keywords ***
Get app id
    [Arguments]    ${app_name}
    [Documentation]    Returns the application id from its name
    ${app_id}    set variable if    '${app_name}' == 'YouTube'    com.libertyglobal.app.youtube    '${app_name}' == 'Netflix'    com.libertyglobal.app.netflix    '${app_name}' == 'euronews'
    ...    com.metrological.app.euronews    '${app_name}' == 'Picasa'    com.metrological.app.Picasa    '${app_name}' == 'Flickr'    com.metrological.app.Flickr    '${app_name}' == 'Web TV'
    ...    com.frequency.app.FrequencyTELENET    '${app_name}' == 'WikiTivia'    com.metrological.widgets.tv.Wikipedia    '${app_name}' == 'AccuWeather'    com.metrological.widgets.tv.AccuWeather    '${app_name}' == 'XITE'
    ...    nl.xite.myxite    '${app_name}' == 'TV Shop'    com.telenet.app.tvshop    '${app_name}' == 'Stingray Music'    ca.stingraydigital.www.widget.galaxie    '${app_name}' == 'Web TV Player'
    ...    com.frequency.app.FrequencyPlayerTELENET
    [Return]    ${app_id}

app window is shown
    [Arguments]    ${type}    ${window}
    [Documentation]    Verifies if the given application window process is shown
    ${is_native}    Evaluate    ${True} if '${type}' == 'Native' else ${False}
    : FOR    ${key}    IN    @{window.keys()}
    \    ${value}    Set Variable    ${window['${key}']}
    \    ${checking_run_id}    Evaluate    ${True} if '${key}' == 'runId' else ${False}
    \    # The application process name must only be 'nfx' (netflix) if its type is Native
    \    ${verify_is_native}    Evaluate    ${checking_run_id} if '${value}' == 'nfx' else ${False}
    \    # The application process name must always be 'browser' when the application type is not Native
    \    ${verify_is_browser_process}    Evaluate    ${checking_run_id} if ${is_native} == ${False} else ${False}
    \    Run Keyword If    '${key}' == 'visible'    Should be True    ${value} == ${True}
    \    ...    ELSE IF    '${key}' == 'pid'    Should be True    ${value} > 0
    \    ...    ELSE IF    '${key}' == 'surfaceId'    Should be True    ${value} > 0
    \    ...    ELSE IF    '${key}' == 'width'    Should be True    ${value} > 0
    \    ...    ELSE IF    '${key}' == 'height'    Should be True    ${value} > 0
    \    ...    ELSE IF    ${verify_is_native}    Should be True    ${is_native}
    \    ...    ELSE IF    ${verify_is_browser_process}    Should be True    '${value}' == 'browser'

Retrieve collections
    [Documentation]    Retrieves all visible collections on screen
    @{collection_browser}    I retrieve value for key 'children' in element 'id:^.*CollectionsBrowser' using regular expressions
    Should Not Be Empty    ${collection_browser}
    &{dict} =    Create Dictionary
    : FOR    ${child}    IN    @{collection_browser}
    \    Set To Dictionary    ${dict}    ${child['id']}=${child}
    [Return]    ${dict}

Get visible app tiles from ${collection_id}
    [Documentation]    This keyword retrieves visible app tiles from collection with given part of id
    ${collection_id_full}    Catenate    SEPARATOR=_    CollectionContainer    ${collection_id}
    Set Suite Variable    ${suite_collection_id}    ${collection_id}
    ${json_object}    Get Ui Json
    ${is_collection_visible}    Is In Json    ${json_object}    ${EMPTY}    id:${collection_id_full}
    return from keyword if    ${is_collection_visible} == ${False}    ${None}
    ${tiles_browser}    I retrieve value for key 'children' in element 'id:${collection_id_full}'
    ${tiles_count}    Get Length    ${tiles_browser}
    @{only_visible_tiles}    Create List
    : FOR    ${index}    IN RANGE    ${0}    ${tiles_count}
    \    ${tile_visible}    Set Variable If    ${tiles_browser[${index}]}    ${True}    ${False}
    \    Run Keyword If    ${tile_visible}    Append To List    ${only_visible_tiles}    ${tiles_browser[${index}]}
    [Return]    ${only_visible_tiles}

Get app tiles per visible collection
    [Documentation]    Gets tiles for visible collection
    ${visible_collections}    Retrieve collections
    @{keys}    Get Dictionary Keys    ${visible_collections}
    ${tiles_per_collection}    Create Dictionary
    : FOR    ${key}    IN    @{keys}
    \    ${children}    Get visible app tiles from ${key}
    \    Run Keyword If    ${children} != ${None}    Set To Dictionary    ${tiles_per_collection}    ${key}    ${children}
    [Return]    ${tiles_per_collection}

Get app tiles count
    [Documentation]    Gets number of tiles per collection
    ${tiles_per_collection}    Get app tiles per visible collection
    ${number_of_tiles_per_collection}    Create Dictionary
    @{keys}    Get Dictionary Keys    ${tiles_per_collection}
    : FOR    ${key}    IN    @{keys}
    \    ${children}    Get From Dictionary    ${tiles_per_collection}    ${key}
    \    ${child_count}    Get Length    ${children}
    \    Set To Dictionary    ${number_of_tiles_per_collection}    ${key}    ${child_count}
    [Return]    ${number_of_tiles_per_collection}

Get focused App
    [Documentation]    Returns the App Tile where the focus is.
#    ${app_name}    Get Focused Tile    title
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:^.*CollectionsBrowser' using regular expressions
    Get Ui Focused Elements
    ${is_focused_grid_link}    Is In Json    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${EMPTY}    ${GRID_LINK_NODE_ID_PATTERN}    ${EMPTY}    ${True}
    Return from Keyword if    ${is_focused_grid_link}    GridLink
    ${current_tile_json}    Get From List    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${-1}
    ${tile_data}    Extract Value For Key    ${current_tile_json}    ${EMPTY}    data    ${True}
    ${current_tile_title}    Extract Value For Key    ${tile_data}    ${EMPTY}    title
    log to console     ${current_tile_title}
    [Return]    ${current_tile_title}

I have agreed with Apps Opt-In conditions    #USED
    [Documentation]    Keyword disable App opt-in modal by setting customer agreement through app-service
    ...    See: https://wikiprojects.upc.biz/display/CTOM/settings
    set application services setting    customer.appsOptIn    ${True}

App store content has loaded
    [Documentation]    This keyword asserts app store content has loaded
    ${collection_browser}    I retrieve value for key 'children' in element 'id:^.*CollectionsBrowser' using regular expressions
    Should Not Be Empty    ${collection_browser}    Collection container is empty
    [Return]    ${collection_browser}

App process is in the foreground
    [Documentation]    This keyword gets the app processes status from testtools and returns True if an Application is
    ...    visible, and False otherwise. An Application is considered visible if it's state is 'RUNNING' and it's visibility
    ...    is set to True, and the url parameter is not the boot url for metrological apps.
    ${apps_processes}    Get Ui App Processes
    ${app_is_shown}    Set Variable    ${False}
    : FOR    ${app}    IN    @{apps_processes}
    \    ${app_is_running}    Evaluate    '${app['state']}' == 'RUNNING'
    \    ${is_boot_url}    Is In Json    ${app}    ${EMPTY}    url:^[^\#]+\#boot(!\\w{2}-\\w{2})?$    ${EMPTY}
    \    ...    ${True}
    \    ${app_is_transparent}    run keyword and return status    Dictionary should contain item    ${app}    opacity    0
    \    ${app_is_shown}    Evaluate    (${app_is_running} and (${app['visible']} and not ${app_is_transparent})) and not ${is_boot_url}
    \    exit for loop if    ${app_is_shown}
    [Return]    ${app_is_shown}

Reset recently used applications
    [Documentation]    This keyword resets the recently used applications using personalization services
    ${cpe_profile_id}    get_current_profile_id_via_as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    reset recently used apps via personalization service    ${CUSTOMER_ID}    ${cpe_profile_id}

Retrieve Netflix Channel Number    #USED
    [Documentation]    This keyword will retrieve Neflix channel number using linear service
    ${app_bound_channels}    I Fetch All C2A App Bound Channels From Linear Service    'name'
    :FOR    ${channel_name}    IN    @{app_bound_channels}
    \    ${channel_number}    get channel number by name    ${CITY_ID}    ${channel_name}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    \    ${is_netflix}    Run Keyword And Return Status    Should Contain    ${channel_name}    Netflix
    \    Exit For Loop If    ${is_netflix}
    [Return]    ${channel_number}

Get List Of Apps From App Service    #USED
    [Documentation]    Gets list of Apps
    ${apps}    Get List Of Apps    ${LAB_CONF}    ${CPE_ID}
    Should Not Be Empty    ${apps}    Unable to get the apps present in app store
    [Return]    ${apps}